//
//  TMAPIModel.m
//  TMGeneral
//
//  Created by mac on 12/10/10.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

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
    [[TMGeneralDataManager sharedInstance].apiIdentifyList addObject:self];  ///< 加入執行列表
    _delegate = aDelegate;
    _errcode = TMAPI_Errcode_Failed;
    //_actionItem.state = [NSNumber numberWithInt:TMAPI_State_Doing];
    [[TMGeneralDataManager sharedInstance] changeApiData:_actionItem Status:TMAPI_State_Doing];
    
    _retryCount = [_actionItem.retryTimes intValue];  ///<開始重新設定retry 次數 
    
    //// 如果要背景重傳 .... 就 先存入DB
    if (( [_actionItem.cacheType intValue] == TMAPI_Cache_Type_ThisActive
         || [_actionItem.cacheType intValue] == TMAPI_Cache_Type_EveryActive)) {

        //[[TMGeneralDataManager sharedInstance] save];
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
    //_actionItem.state = [NSNumber numberWithInt:TMAPI_State_Doing];
    [[TMGeneralDataManager sharedInstance] changeApiData:_actionItem Status:TMAPI_State_Doing];
    
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
    //// 由於  deleteObject 會讓一個物件移除掉，如果此時CoreData restart 掉物件 就會讓這個物件進入flaut的狀態
    //// 因此 set or get 會讓他flaut掉  (現在還找不到如何 Unit test)
    if ([_actionItem isFault]) {
        return;
    }
    
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
    
    [[TMGeneralDataManager sharedInstance].apiIdentifyList removeObject:self];
    [myLock unlock];
}

- (void) cancel
{
    //// 由於  deleteObject 會讓一個物件移除掉，如果此時CoreData restart 掉物件 就會讓這個物件進入flaut的狀態
    //// 因此 set or get 會讓他flaut掉  (現在還找不到如何 Unit test)
    if ([_actionItem isFault]) {
        return;
    }
    
    if ([_actionItem.state intValue] == TMAPI_State_Finished) {
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
    
    [[TMGeneralDataManager sharedInstance].apiIdentifyList removeObject:self];
    [myLock unlock];
}

#pragma mark - apis

- (NSDictionary *) inputParam
{

    if (_inputParam != nil) {
        return _inputParam;
    }
    
    _inputParam = [TMDataManager objectFormNSData:_actionItem.content];
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
    //_actionItem.cacheType = [NSNumber numberWithInt:cacheType];
    [[TMGeneralDataManager sharedInstance] changeApiData:_actionItem CacheType:cacheType];
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
    //_actionItem.retryTimes = [NSNumber numberWithInt:retryTimes];
    [[TMGeneralDataManager sharedInstance] changeApiData:_actionItem RetryTimes:retryTimes];
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
            apidata.type = [NSNumber numberWithInt:TMAPI_Type_General];
            apidata.content = [TMDataManager dataFromNSData:aInput];
            apidata.cacheType = [NSNumber numberWithInt:TMAPI_Cache_Type_None];
            apidata.state = [NSNumber numberWithInt:TMAPI_State_Init];
            apidata.retryTimes = @3;
            apidata.retryDelayTime = @TMAPIMODEL_DEFAULT_RETRY_DELAY_TIME;
            apidata.mode = [NSNumber numberWithInt:TMAPI_Mode_Leave_With_Cancel];
            
            apidata.createTime = _actionItem.lastActionTime = [NSDate date];
            apidata.objectName = NSStringFromClass([self class]);   ///< 返回執行時要啟動的 object
            NSLog(@"TMAPIModel save in DB and target class : %@", apidata.objectName);
            
            apidata.identify = tmStringFromMD5([NSString stringWithFormat:@"%@", apidata.createTime]);
        }];
        
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
        _actionItem = aAction;
        
        _actionItem.lastActionTime = [NSDate date];
        
        //[[TMGeneralDataManager sharedInstance] save];
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
