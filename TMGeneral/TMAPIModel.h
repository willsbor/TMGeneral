/*
 TMAPIModel.h
 
 Copyright (c) 2012 willsbor Kang at ThinkerMobile
 
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

#import <Foundation/Foundation.h>
#import "TMApiData+Plus.h"

typedef enum
{
    TMAPI_Errcode_Success,
    TMAPI_Errcode_Failed,
    TMAPI_Errcode_Failed_And_Retry,
    TMAPI_Errcode_Cancel,
} TMAPI_Errcode;

typedef enum
{
    TMAPI_Thread_Type_Main,           ///<  第一次執行時，會做 synchronous，如果retry 則會做 Asynchronous
    TMAPI_Thread_Type_MainThread,
    TMAPI_Thread_Type_SubThread,
    //    TMAPI_Thread_Type_Background,   ///< 跟UIApplication 有關 先不放裡面
} TMAPI_Thread_Type;

@class TMAPIModel;
//@class TMApiData;
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
    //TMApiData *_actionItem;
    NSString *_actionItem;  ///< identify
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
@property (nonatomic, readonly) NSString *actionItem;
@property (nonatomic, readonly) TMAPI_Mode  mode;
@property (nonatomic, readonly) TMAPI_State state;
@property (nonatomic)           TMAPI_Cache_Type cacheType;
@property (nonatomic)           int         retryTimes;
@property (nonatomic)           double      retryDelayTime;


+ (void) switchAPIDataStateFromInvalidDoing2Pending;
+ (void) switchAPIDataStateFromInvalid2Stop;

+ (void) startCheckCacheAPI;
+ (void) stopCheckCacheAPI;

+ (void) removeAllFinishAPIData;

//// public

/**
 * initial object by special tag
 * \param aAction special tag
 */
- (id) initFromAction:(NSString *)aAction;

/**
 * initial object by customize input content
 * \param aInput customize input content
 */
- (id) initWithInput:(NSDictionary *)aInput;

/**
 * start to execute the api object, start to execute main function
 * \param aDelegate set the delegate for respone
 */
- (void) startWithDelegate:(id<TMAPIModelProtocol>)aDelegate;

/**
 * check the retry times and to do retry function or final function
 *
 */
- (void) checkRetryAndDoRetryOrFinal;

/// overwite
- (void) main;
- (void) final;
- (void) cancel;

@end
