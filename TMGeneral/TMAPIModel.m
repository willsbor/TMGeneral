/*
 TMAPIModel.m
 
 Copyright (c) 2012 willsbor Kang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "TMAPIModel.h"
#import "TMGeneralDataManager.h"
#import "TMApiData.h"
#import "TMTools.h"

static dispatch_queue_t tm_api_model_operation_processing_queue;
static dispatch_queue_t api_model_operation_processing_queue() {
    if (tm_api_model_operation_processing_queue == NULL) {
        tm_api_model_operation_processing_queue = dispatch_queue_create("com.thinkermobile.api_model.processing", 0);
    }
    
    return tm_api_model_operation_processing_queue;
}


@interface TMAPIModel ()
{
    NSLock *myLock;
    
    int _retryCount;
}
@end

@implementation TMAPIModel
@synthesize inputParam = _inputParam;
static NSTimer *g_checkCacheAPITimer = nil;

#pragma mark - static
static NSMutableArray *g_apiIdentifyList = nil;

+ (NSMutableArray *) apiIdentifyList
{
    if (g_apiIdentifyList) {
        return g_apiIdentifyList;
    }
    
    g_apiIdentifyList = [[NSMutableArray alloc] init];
    return g_apiIdentifyList;
}

+ (void) switchAPIDataStateFromInvalidDoing2Pending
{
    /// 將 不在執行列表中的物件 且 cachetype 是 TMAPI_Cache_Type_EveryActive
    /// 狀態如果是doing 就轉換成 pending  (先不包含 TMAPI_State_Init)
    
    /// 因為程式有可能中途被強制中段 導致 DB內的狀態還停留在doing
    /// 但是要保證 TMAPI_Cache_Type_EveryActive 能被送出
    /// 所以這標要檢查表留需要被執行的命令
    
    [[TMGeneralDataManager sharedInstance] switchAPIDataStateFromInvalidDoing2Pending:^BOOL(NSString *identify) {
        for (TMAPIModel *object in [[self class] apiIdentifyList]) {
            if ([object.actionItem isEqualToString:identify]) {
                return YES;
            }
        }
        
        return NO;
    }];
}

+ (void) switchAPIDataStateFromInvalid2Stop
{
    /// 這個不會管 有沒有正在執行
    /// 會將所有 state != pending 都 將 state 轉換成 stop
    
    /// 所以要先檢查一些不合法的doing 轉成 pending
    [self  switchAPIDataStateFromInvalidDoing2Pending];
    
    [[TMGeneralDataManager sharedInstance] switchAPIDataStateFromInvalid2Stop];
    
}

+ (void) removeAllFinishAPIData
{
    [[TMGeneralDataManager sharedInstance] removeAllFinishAPIData];
}

+ (void) startCheckCacheAPI
{
    @synchronized(self) {
        if (g_checkCacheAPITimer != nil) {
            return;
        }
        
        g_checkCacheAPITimer = [NSTimer scheduledTimerWithTimeInterval:TMAPIMODEL_DEFAULT_CHECK_API_DURATION
                                                                target:[self class]
                                                              selector:@selector(_checkAPIAction:)
                                                              userInfo:nil
                                                               repeats:NO];
    }
}

+ (void) stopCheckCacheAPI
{
    @synchronized(self) {
        [g_checkCacheAPITimer invalidate];
        g_checkCacheAPITimer = nil;
    }
}


+ (void) _checkAPIAction:(id)sender
{
    @synchronized(self) {
        g_checkCacheAPITimer = nil;
    }
    
   [[TMGeneralDataManager sharedInstance] _checkAPIAction:^(TMApiData *object) {
       id apiClass = NSClassFromString(object.objectName);
       id apiModel = [[apiClass alloc] initFromAction:object.identify];
       ((TMAPIModel *)apiModel).thread = TMAPI_Thread_Type_SubThread;  ///< 如果做保證執行的動作 則讓他在sub thread 做
       
       dispatch_async(dispatch_get_main_queue(), ^{
           [apiModel startWithDelegate:nil];
       });
   }];

    
    [[self class] startCheckCacheAPI];
}

#pragma mark - public

- (void) startWithDelegate:(id)aDelegate
{
    [[[self class] apiIdentifyList] addObject:self];  ///< 加入執行列表
    _delegate = aDelegate;
    _errcode = TMAPI_Errcode_Failed;

    [[TMGeneralDataManager sharedInstance] changeApiData:_actionItem Status:TMAPI_State_Doing];
    
    NSNumber *retry = [[TMGeneralDataManager sharedInstance] returnObjectByKey:@"retryTimes" OfIdentify:_actionItem];
    _retryCount = [retry intValue];  ///<開始重新設定retry 次數
    
    //// 如果要背景重傳 .... 就 先存入DB
    //if (( [_actionItem.cacheType intValue] == TMAPI_Cache_Type_ThisActive
    //     || [_actionItem.cacheType intValue] == TMAPI_Cache_Type_EveryActive)) {
        
        //[[TMGeneralDataManager sharedInstance] save];
    //}
    
    
    if (_thread == TMAPI_Thread_Type_MainThread){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self main];
        });
    }
    else if (_thread == TMAPI_Thread_Type_SubThread){
        dispatch_async(api_model_operation_processing_queue(), ^{
            [self main];
        });
    }
    else {
        [self main];
    }
}

- (void) checkRetryAndDoRetryOrFinal
{
    if ([self checkRetry]) {
        [self retry];
    } else {
        _errcode = TMAPI_Errcode_Failed;
        [self final];
    }
}

- (BOOL) retry
{
    if (_retryCount <= 0) {
        ///#warning final?!
        /// 應該不需要final 外面會給
        return NO;
    }
    
    //NSLog(@"start to retry befor %f sec... %d", _retryDelayTime, _retryTimes);
    
    if (_retryCount > 0 ) {
        _retryCount--;
    }
    
    _errcode = TMAPI_Errcode_Failed_And_Retry;
    //_actionItem.state = [NSNumber numberWithInt:TMAPI_State_Doing];
    [[TMGeneralDataManager sharedInstance] changeApiData:_actionItem Status:TMAPI_State_Doing];
    
    NSNumber *retryDelayTime = [[TMGeneralDataManager sharedInstance] returnObjectByKey:@"retryDelayTime" OfIdentify:_actionItem];
    if (_thread == TMAPI_Thread_Type_SubThread){
        int64_t delayInSeconds = [retryDelayTime doubleValue];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        
        dispatch_after(popTime, api_model_operation_processing_queue(), ^(void){
            [self main];
        });
    }
    else {
        /// TMAPI_Thread_Type_Main or other
        int64_t delayInSeconds = [retryDelayTime doubleValue];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self main];
        });
    }
    
    return YES;
}

- (BOOL) checkRetry
{
    if (_retryCount == 0) {
        return NO;
    }
    else if (_retryCount > 0) {
        return YES;
    }
    else {
        ///<  < 0
        return NO;
    }
}

- (void) main
{
    /// initial is empty
    /// need overwrite
}

- (void) final
{
    //// 由於  deleteObject 會讓一個物件移除掉，如果此時CoreData restart 掉物件 就會讓這個物件進入flaut的狀態
    //// 因此 set or get 會讓他flaut掉  (現在還找不到如何 Unit test)
//#warning todo  還沒有修正過
#if 0
    if ([_actionItem isFault]) {
        return;
    }
#endif
    
    NSNumber *state = [[TMGeneralDataManager sharedInstance] returnObjectByKey:@"state" OfIdentify:_actionItem];
    if ([state intValue] == TMAPI_State_Finished) {
        return;
    }
    [myLock lock];
    
    if (_delegate != nil) {
        if ([_delegate respondsToSelector:@selector(apiModel:finishWithErrcode:AndParam:)] ) {
            [_delegate apiModel:self finishWithErrcode:_errcode AndParam:_outputParam];
        }
    }
    
    
    if(_errcode == TMAPI_Errcode_Success || _errcode == TMAPI_Errcode_Cancel) {
        //_actionItem.state = [NSNumber numberWithInt:TMAPI_State_Finished];
        [[TMGeneralDataManager sharedInstance] changeApiData:_actionItem Status:TMAPI_State_Finished];
    } else {
        /// 這次流程失敗 包含重試... 所以... 記錄狀態成 TMAPI_State_Pending
        if ([self checkRetry]) {
            //_actionItem.state = [NSNumber numberWithInt:TMAPI_State_Pending];
            [[TMGeneralDataManager sharedInstance] changeApiData:_actionItem Status:TMAPI_State_Pending];
        } else
            //_actionItem.state = [NSNumber numberWithInt:TMAPI_State_Failed];
            [[TMGeneralDataManager sharedInstance] changeApiData:_actionItem Status:TMAPI_State_Failed];
    }
    
    /// 存入DB
    //[[TMGeneralDataManager sharedInstance] save];
    
    [[[self class] apiIdentifyList] removeObject:self];
    [myLock unlock];
}

- (void) cancel
{
    //// 由於  deleteObject 會讓一個物件移除掉，如果此時CoreData restart 掉物件 就會讓這個物件進入flaut的狀態
    //// 因此 set or get 會讓他flaut掉  (現在還找不到如何 Unit test)
//#warning todo  還沒有修正過
#if 0
    if ([_actionItem isFault]) {
        return;
    }
#endif
    
    NSNumber *state = [[TMGeneralDataManager sharedInstance] returnObjectByKey:@"state" OfIdentify:_actionItem];
    if ([state intValue] == TMAPI_State_Finished
        || [state intValue] == TMAPI_State_Failed) {
        return;
    }
    
    [myLock lock];
    
    
    if (_delegate != nil) {
        if ([_delegate respondsToSelector:@selector(apiModel:finishWithErrcode:AndParam:)] ) {
            [_delegate apiModel:self finishWithErrcode:TMAPI_Errcode_Cancel AndParam:_outputParam];
        }
    }
    
    //_actionItem.state = [NSNumber numberWithInt:TMAPI_State_Finished];
    [[TMGeneralDataManager sharedInstance] changeApiData:_actionItem Status:TMAPI_State_Finished];
    
    /// 修改DB暫存物件的狀態
    //[[TMGeneralDataManager sharedInstance] save];
    
    [[[self class] apiIdentifyList] removeObject:self];
    [myLock unlock];
}

#pragma mark - apis

- (NSDictionary *) inputParam
{
    
    if (_inputParam != nil) {
        return _inputParam;
    }
    
    NSData *content = [[TMGeneralDataManager sharedInstance] returnObjectByKey:@"content" OfIdentify:_actionItem];
    _inputParam = [TMDataManager objectFormNSData:content];
    return _inputParam;
}

- (TMAPI_Mode) mode
{
    if (_actionItem == nil) {
        return 0;
    }
    
    NSNumber *mode = [[TMGeneralDataManager sharedInstance] returnObjectByKey:@"mode" OfIdentify:_actionItem];
    return [mode intValue];
}

- (TMAPI_State) state
{
    if (_actionItem == nil) {
        return 0;
    }
    
    NSNumber *state = [[TMGeneralDataManager sharedInstance] returnObjectByKey:@"state" OfIdentify:_actionItem];
    return [state intValue];
}

- (TMAPI_Cache_Type) cacheType
{
    if (_actionItem == nil) {
        return 0;
    }
    
    NSNumber *cacheType = [[TMGeneralDataManager sharedInstance] returnObjectByKey:@"cacheType" OfIdentify:_actionItem];
    return [cacheType intValue];
}

- (void) setCacheType:(TMAPI_Cache_Type)cacheType
{
    //_actionItem.cacheType = [NSNumber numberWithInt:cacheType];
    [[TMGeneralDataManager sharedInstance] changeApiData:_actionItem CacheType:cacheType];
}

- (int) retryTimes
{
    if (_actionItem == nil) {
        return 0;
    }
    
    NSNumber *retryTimes = [[TMGeneralDataManager sharedInstance] returnObjectByKey:@"retryTimes" OfIdentify:_actionItem];
    return [retryTimes intValue];
}

- (void) setRetryTimes:(int)retryTimes
{
    //_actionItem.retryTimes = [NSNumber numberWithInt:retryTimes];
    [[TMGeneralDataManager sharedInstance] changeApiData:_actionItem RetryTimes:retryTimes];
}

- (double) retryDelayTime
{
    if (_actionItem == nil) {
        return 0;
    }
    
    NSNumber *retryDelayTime = [[TMGeneralDataManager sharedInstance] returnObjectByKey:@"retryDelayTime" OfIdentify:_actionItem];
    return [retryDelayTime doubleValue];
}

- (void) setRetryDelayTime:(double)retryDelayTime
{
    //_actionItem.retryDelayTime = [NSNumber numberWithDouble:retryDelayTime];
    [[TMGeneralDataManager sharedInstance] changeApiData:_actionItem RetryDelayTimes:retryDelayTime];
}

#pragma mark - init

- (id) initWithInput:(NSDictionary *)aInput
{
    self = [super init];
    if (self) {
        myLock = [[NSLock alloc] init];
        _outputParam = [[NSMutableDictionary alloc] init];
        _thread = TMAPI_Thread_Type_Main;
        
        /// 創造一個新的資料物件
        _actionItem = [[TMGeneralDataManager sharedInstance] createTMApiDataWith:^(TMApiData *apidata) {
            apidata.content = [TMDataManager dataFromNSData:aInput];
            
            apidata.objectName = NSStringFromClass([self class]);   ///< 返回執行時要啟動的 object
            NSLog(@"TMAPIModel save in DB and target class [outside] : %@", apidata.objectName);
        }];
        
    }
    return self;
}

- (id) initFromAction:(NSString *)aAction
{
    self = [super init];
    if (self) {
        myLock = [[NSLock alloc] init];
        _outputParam = [[NSMutableDictionary alloc] init];
        _thread = TMAPI_Thread_Type_Main;
        
        /// 因為是從 Action init 所以就直接設定
        _actionItem = aAction;
        
        [[TMGeneralDataManager sharedInstance] changeApiData:_actionItem With:^(TMApiData *apidata) {
            apidata.lastActionTime = [NSDate date];
        }];
        
    }
    
    return self;
}

- (id)init
{
    self = [self initWithInput:nil];
    if (self) {
        
    }
    return self;
}


@end
