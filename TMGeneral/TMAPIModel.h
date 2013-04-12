//
//  TMAPIModel.h
//  TMGeneral
//
//  Created by mac on 12/10/10.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TMAPIMODEL_DEFAULT_RETRY_DELAY_TIME   5.0  /// sec
#define TMAPIMODEL_DEFAULT_CHECK_API_DURATION   30.0 ///< sec

typedef enum
{
    TMAPI_Errcode_Success,
    TMAPI_Errcode_Failed,
    TMAPI_Errcode_Failed_And_Retry,
    TMAPI_Errcode_Cancel,
} TMAPI_Errcode;

typedef enum
{
    TMAPI_Mode_Leave_With_Cancel,
    TMAPI_Mode_Leave_Without_Cancel,
} TMAPI_Mode;

typedef enum
{
    TMAPI_State_Init,
    TMAPI_State_Doing,
    TMAPI_State_Finished,
    TMAPI_State_Pending,  ///< retry : 中途的狀態
    TMAPI_State_Failed,   ///< retry 到最後失敗
    TMAPI_State_Stop,   ///< 被系統強制換狀態
} TMAPI_State;

typedef enum
{
    TMAPI_Type_General,
    TMAPI_Type_Web_Api,
} TMAPI_Type;

typedef enum
{
    TMAPI_Cache_Type_None,
    TMAPI_Cache_Type_ThisActive,
    TMAPI_Cache_Type_EveryActive,
} TMAPI_Cache_Type;

typedef enum
{
    TMAPI_Thread_Type_Main,           ///<  第一次執行時，會做 synchronous，如果retry 則會做 Asynchronous
    TMAPI_Thread_Type_MainThread,
    TMAPI_Thread_Type_SubThread, 
//    TMAPI_Thread_Type_Background,   ///< 跟UIApplication 有關 先不放裡面
} TMAPI_Thread_Type;

@class TMAPIModel;
@class TMApiData;
@protocol TMAPIModelProtocol <NSObject>

@optional
- (void) apiModel:(TMAPIModel *)aModel finishWithErrcode:(int)aErrcode AndParam:(NSDictionary *)aParam;

@end

/**
 * retryTimes:       0:重試0次, 1: 重試1次(一共執行兩次)
 * retryDelayTime   重試間隔時間
 * cacheType        重試結束後  是不是還要保留這個資料 ...以及保留的狀況
 */
@interface TMAPIModel : NSObject
{
    @protected
    TMApiData *_actionItem;
}
/**
 * 如果用這個方法修改Diction內的資料可能無法正確更新到DB中
 * DB中的參數 現在只能用可以被 NSKeyedArchiver
 */
@property (nonatomic, readonly, strong) NSDictionary *inputParam;
@property (nonatomic, copy)     NSMutableDictionary *outputParam;
@property (nonatomic, unsafe_unretained)   id<TMAPIModelProtocol> delegate;
@property (nonatomic)           int errcode;
@property (nonatomic, strong)   NSString *key;
@property (nonatomic          ) TMAPI_Thread_Type thread;   

//// Data
@property (nonatomic, readonly) TMApiData *actionItem;
@property (nonatomic, readonly) TMAPI_Mode  mode;
@property (nonatomic, readonly) TMAPI_State state;
@property (nonatomic)           TMAPI_Cache_Type cacheType;
@property (nonatomic)           int         retryTimes;
@property (nonatomic)           double      retryDelayTime;


//// public

- (id) initFromAction:(TMApiData *)aAction;

- (id) initWithInput:(NSDictionary *)aInput;

- (void) startWithDelegate:(id<TMAPIModelProtocol>)aDelegate;

- (BOOL) checkRetry;

- (BOOL) retry;

/// overwite
- (void) main;
- (void) final;
- (void) cancel;

@end
