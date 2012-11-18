//
//  TMAPIModel.m
//  TMGeneral
//
//  Created by mac on 12/10/10.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import "TMAPIModel.h"
#import "TMDataManager.h"
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

#pragma mark - static

static NSMutableArray *g_tempList = nil;
static NSTimer *g_checkCacheAPITimer = nil;

+ (BOOL) isIdentifyInTempList:(NSString *)aIdentify
{
    for (TMAPIModel *object in g_tempList) {
        if ([object.actionItem.identify isEqualToString:aIdentify]) {
            return YES;
        }
    }
    
    return NO;
}

+ (void) switchAPIDataStateFromInvalidDoing2Pending
{
    /// 將 不在執行列表中的物件 且 cachetype 是 TMAPI_Cache_Type_EveryActive
    /// 狀態如果是doing 就轉換成 pending  (先不包含 TMAPI_State_Init)
    
    /// 因為程式有可能中途被強制中段 導致 DB內的狀態還停留在doing
    /// 但是要保證 TMAPI_Cache_Type_EveryActive 能被送出
    /// 所以這標要檢查表留需要被執行的命令
    
    NSManagedObjectContext *manaedObjectContext = [TMDataManager sharedInstance].mainObjectContext;
    NSFetchRequest *fetchReq = [[NSFetchRequest alloc]init];
    [fetchReq setEntity:[NSEntityDescription entityForName:@"TMApiData" inManagedObjectContext:manaedObjectContext]];
    [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"(cacheType == %d) AND (state == %d OR state == %d)",
                            TMAPI_Cache_Type_EveryActive,
                            TMAPI_State_Doing,
                            TMAPI_State_Pending]];
     
    NSArray *resultArray = [manaedObjectContext executeFetchRequest:fetchReq error:nil];
    [fetchReq release];
    
    for (TMApiData *object in resultArray)
    {
        if (NO == [self isIdentifyInTempList:object.identify]) {
            /// 表示在 cache中  但是不再現在的正在執行列表裡  所以要將 doing & pending -> failed
            object.state = [NSNumber numberWithInt:TMAPI_State_Failed];
        }
    }
    
    [[TMDataManager sharedInstance] save];
}

+ (void) switchAPIDataStateFromInvalid2Stop
{
    /// 這個不會管 有沒有正在執行
    /// 會將所有 state != pending 都 將 state 轉換成 stop
    
    /// 所以要先檢查一些不合法的doing 轉成 pending
    [[self class] switchAPIDataStateFromInvalidDoing2Pending];
    
    
    ///
    NSManagedObjectContext *manaedObjectContext = [TMDataManager sharedInstance].mainObjectContext;
    NSFetchRequest *fetchReq = [[NSFetchRequest alloc]init];
    [fetchReq setEntity:[NSEntityDescription entityForName:@"TMApiData" inManagedObjectContext:manaedObjectContext]];
    [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"(state == %d or state == %d)",
                            TMAPI_State_Init,
                            TMAPI_State_Doing]];
    
    NSArray *resultArray = [manaedObjectContext executeFetchRequest:fetchReq error:nil];
    [fetchReq release];
    
    for (TMApiData *object in resultArray)
    {
        object.state = [NSNumber numberWithInt:TMAPI_State_Stop];
    }
    
    [[TMDataManager sharedInstance] save];
}

+ (void) removeAllFinishAPIData
{
    NSManagedObjectContext *manaedObjectContext = [TMDataManager sharedInstance].mainObjectContext;
    NSFetchRequest *fetchReq = [[NSFetchRequest alloc]init];
    [fetchReq setEntity:[NSEntityDescription entityForName:@"TMApiData" inManagedObjectContext:manaedObjectContext]];
    [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"(state == %d or state == %d)",
                            TMAPI_State_Finished,
                            TMAPI_State_Stop]];
    
    NSArray *resultArray = [manaedObjectContext executeFetchRequest:fetchReq error:nil];
    [fetchReq release];
    
    for (TMApiData *object in resultArray)
    {
        [manaedObjectContext deleteObject:object];
    }
    
    [[TMDataManager sharedInstance] save];
}

+ (void) _checkAPIAction:(id)sender
{
    @synchronized([self class]) {
        g_checkCacheAPITimer = nil;
    }
    
    NSManagedObjectContext *manaedObjectContext = [TMDataManager sharedInstance].mainObjectContext;
    NSFetchRequest *fetchReq = [[NSFetchRequest alloc]init];
    [fetchReq setEntity:[NSEntityDescription entityForName:@"TMApiData" inManagedObjectContext:manaedObjectContext]];
    [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"(cacheType == %d OR cacheType == %d) AND (state == %d)",
                            TMAPI_Cache_Type_EveryActive,
                            TMAPI_Cache_Type_ThisActive,
                            TMAPI_State_Failed]];
     
    NSArray *resultArray = [manaedObjectContext executeFetchRequest:fetchReq error:nil];
    [fetchReq release];
    
    for (TMApiData *object in resultArray) {
        /// 設後不理
        ////  這裡一直執行可能會有行為上的問題  就是假設一直送不成功 ... 系統可能會很忙 or 煩
        id apiClass = NSClassFromString(object.objectName);
        id apiModel = [[[apiClass alloc] initFromAction:object] autorelease];
        ((TMAPIModel *)apiModel).thread = TMAPI_Thread_Type_SubThread;  ///< 如果做保證執行的動作 則讓他在sub thread 做
        [apiModel startWithDelegate:nil];
    }
    
    [[self class] startCheckCacheAPI];
}

+ (void) startCheckCacheAPI
{
    @synchronized([self class]) {
        if (g_checkCacheAPITimer != nil) {
            return;
        }
        
        g_checkCacheAPITimer = [NSTimer scheduledTimerWithTimeInterval:TMAPIMODEL_DEFAULT_CHECK_API_DURATION target:[self class] selector:@selector(_checkAPIAction:) userInfo:nil repeats:NO];
    }
}

+ (void) stopCheckCacheAPI
{
    @synchronized([self class]) {
        [g_checkCacheAPITimer invalidate];
        g_checkCacheAPITimer = nil;
    }
}

#pragma mark - private

/*
- (void) _threadMain
{

    else if (_thread == TMAPI_Thread_Type_Background) {
     UIApplication *application = [UIApplication sharedApplication]; //Get the shared application instance
     
     __block UIBackgroundTaskIdentifier background_task; //Create a task object
     
     
     background_task = [application beginBackgroundTaskWithExpirationHandler: ^ {
     
     [application endBackgroundTask: background_task]; //Tell the system that we are done with the tasks
     background_task = UIBackgroundTaskInvalid; //Set the task to be invalid
     
     //System will be shutting down the app at any point in time now
     }];
     
     //Background tasks require you to use asyncrous tasks
     
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     //Perform your tasks that your application requires
     
     [application endBackgroundTask: background_task]; //End the task so the system knows that you are done with what you need to perform
     background_task = UIBackgroundTaskInvalid; //Invalidate the background_task
     });
     }
}*/

#pragma mark - public

- (void) startWithDelegate:(id)aDelegate
{
    @synchronized(self) {
        if (g_tempList == nil)
            g_tempList = [[NSMutableArray alloc] init];
    }
    
    [g_tempList addObject:self];  ///< 加入執行列表
    _delegate = aDelegate;
    _errcode = TMAPI_Errcode_Failed;
    _actionItem.state = [NSNumber numberWithInt:TMAPI_State_Doing];
    
    _retryCount = [_actionItem.retryTimes intValue];  ///<開始重新設定retry 次數 
    
    //// 如果要背景重傳 .... 就 先存入DB
    if (( [_actionItem.cacheType intValue] == TMAPI_Cache_Type_ThisActive
         || [_actionItem.cacheType intValue] == TMAPI_Cache_Type_EveryActive)) {
        //[self saveTempInDB];
        
        [[TMDataManager sharedInstance] save];
    }
    
    
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
    _actionItem.state = [NSNumber numberWithInt:TMAPI_State_Doing];
    
    
    if (_thread == TMAPI_Thread_Type_SubThread){
        int64_t delayInSeconds = [_actionItem.retryDelayTime doubleValue];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        
        dispatch_after(popTime, api_model_operation_processing_queue(), ^(void){
            [self main];
        });
    }
    else {
        /// TMAPI_Thread_Type_Main or other
        int64_t delayInSeconds = [_actionItem.retryDelayTime doubleValue];
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
    if ([_actionItem.state intValue] == TMAPI_State_Finished) {
        return;
    }
    
    [myLock lock];
    
    if (_delegate != nil) {
        if ([_delegate respondsToSelector:@selector(apiModel:finishWithErrcode:AndParam:)] ) {
            [_delegate apiModel:self finishWithErrcode:_errcode AndParam:_outputParam];
        }
    }
    
   
    if(_errcode == TMAPI_Errcode_Success || _errcode == TMAPI_Errcode_Cancel) {
         _actionItem.state = [NSNumber numberWithInt:TMAPI_State_Finished];
    } else {
        /// 這次流程失敗 包含重試... 所以... 記錄狀態成 TMAPI_State_Pending
        if ([self checkRetry]) {
            _actionItem.state = [NSNumber numberWithInt:TMAPI_State_Pending];
        } else
            _actionItem.state = [NSNumber numberWithInt:TMAPI_State_Failed];
    }
    
    /// 存入DB
    [[TMDataManager sharedInstance] save];
    
    [self retain];
    [g_tempList removeObject:self];
    [myLock unlock];
    [self release];
}

- (void) cancel
{
    if ([_actionItem.state intValue] == TMAPI_State_Finished) {
        return;
    }
    
    [myLock lock];
    

    if (_delegate != nil) {
        if ([_delegate respondsToSelector:@selector(apiModel:finishWithErrcode:AndParam:)] ) {
            [_delegate apiModel:self finishWithErrcode:TMAPI_Errcode_Cancel AndParam:_outputParam];
        }
    }
    
    _actionItem.state = [NSNumber numberWithInt:TMAPI_State_Finished];
    
    /// 修改DB暫存物件的狀態
    [[TMDataManager sharedInstance] save];
    
    [self retain];
    [g_tempList removeObject:self];
    [myLock unlock];
    [self release];
}

#pragma mark - apis

- (NSDictionary *) inputParam
{

    if (_inputParam != nil) {
        return _inputParam;
    }
    
    _inputParam = [[[TMDataManager sharedInstance] objectFormNSData:_actionItem.content] retain];
    return _inputParam;
}

- (TMAPI_Mode) mode
{
    if (_actionItem == nil) {
        return 0;
    }
    
    return [_actionItem.mode intValue];
}

- (TMAPI_State) state
{
    if (_actionItem == nil) {
        return 0;
    }
    
    return [_actionItem.state intValue];
}

- (TMAPI_Cache_Type) cacheType
{
    if (_actionItem == nil) {
        return 0;
    }
    
    return [_actionItem.cacheType intValue];
}

- (void) setCacheType:(TMAPI_Cache_Type)cacheType
{
    _actionItem.cacheType = [NSNumber numberWithInt:cacheType];
}

- (int) retryTimes
{
    if (_actionItem == nil) {
        return 0;
    }
    
    return [_actionItem.retryTimes intValue];
}

- (void) setRetryTimes:(int)retryTimes
{
    _actionItem.retryTimes = [NSNumber numberWithInt:retryTimes];
}

- (double) retryDelayTime
{
    if (_actionItem == nil) {
        return 0;
    }
    
    return [_actionItem.retryDelayTime doubleValue];
}

- (void) setRetryDelayTime:(double)retryDelayTime
{
    _actionItem.retryDelayTime = [NSNumber numberWithDouble:retryDelayTime];
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
        NSManagedObjectContext *manaedObjectContext = [[TMDataManager sharedInstance] mainObjectContext];
        _actionItem = [[NSEntityDescription insertNewObjectForEntityForName:@"TMApiData"
                                                         inManagedObjectContext:manaedObjectContext] retain];
        
        _actionItem.type = [NSNumber numberWithInt:TMAPI_Type_General];
        _actionItem.content = [[TMDataManager sharedInstance] dataFromNSData:aInput];
        _actionItem.cacheType = [NSNumber numberWithInt:TMAPI_Cache_Type_None];
        _actionItem.state = [NSNumber numberWithInt:TMAPI_State_Init];
        _actionItem.retryTimes = @3;
        _actionItem.retryDelayTime = @TMAPIMODEL_DEFAULT_RETRY_DELAY_TIME;
        _actionItem.mode = [NSNumber numberWithInt:TMAPI_Mode_Leave_With_Cancel];
        
        _actionItem.createTime = _actionItem.lastActionTime = [NSDate date];
        _actionItem.objectName = NSStringFromClass([self class]);   ///< 返回執行時要啟動的 object
        NSLog(@"TMAPIModel save in DB and target class : %@", _actionItem.objectName);
        
        _actionItem.identify = tmStringFromMD5([NSString stringWithFormat:@"%@", _actionItem.createTime]);
        
        [[TMDataManager sharedInstance] save];

    }
    return self;
}

- (id) initFromAction:(TMApiData *)aAction
{
    self = [super init];
    if (self) {
        myLock = [[NSLock alloc] init];
        _outputParam = [[NSMutableDictionary alloc] init];
        _thread = TMAPI_Thread_Type_Main;
        
        /// 因為是從 Action init 所以就直接設定
        _actionItem = [aAction retain];
        
        _actionItem.lastActionTime = [NSDate date];
        
        [[TMDataManager sharedInstance] save];
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

- (void)dealloc
{
    
    [_inputParam release];
    [_outputParam release];
    [myLock release];
    
    [_key release];
    [_actionItem release];
    _actionItem = nil;
    
    [super dealloc];
}

@end
