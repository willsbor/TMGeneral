/*
 TMGlobalModel.h
 
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define TMGLOBAL_MODEL_KVO_APP_VERSION      @"_appversion"
#define TMGLOBAL_MODEL_KVO_API_VERSION    @"_apiVersion"

typedef enum {
    TMGlobal_WaitingView_Animation_Direction_L2R,
    TMGlobal_WaitingView_Animation_Direction_R2L,
    TMGlobal_WaitingView_Animation_Direction_U2D,
    TMGlobal_WaitingView_Animation_Direction_D2U,
} TMGlobal_WaitingView_Animation_Direction;

typedef enum {
    TMGlobal_AppMode_Release = 0,
    TMGlobal_AppMode_Develop = 1,
    TMGlobal_AppMode_Test = 2,
    TMGlobal_AppMode_Custome_1 = 3,
    TMGlobal_AppMode_Custome_2 = 4,
    TMGlobal_AppMode_Custome_3 = 5,
    TMGlobal_AppMode_Num,
} TMGlobal_AppMode;

@interface TMGlobalModel : NSObject
{
    
}

@property (nonatomic, readonly) NSMutableDictionary* mapKey;

@property (nonatomic, strong) NSString *appversion;
@property (nonatomic, strong) NSString *apiVersion;

- (void) updateDatas:(NSDictionary *) aJSONDic;

+ (void) setWaitingViewBaseView:(UIView *)aView;
+ (void) setWaitingViewAnimationDirection:(TMGlobal_WaitingView_Animation_Direction)aDirection;
+ (void) setWaitingViewWidthMargin:(CGFloat)aWidthMargin;
- (void) cleanWaitingViewForLang;
- (BOOL) isWaitingViewDisplay;
- (void) waitingViewHidden;
- (void) waitingViewShowAtPoint:(CGPoint)aPoint withText:(NSString *)aText;
///   aHiddenTime < =0 is show all the time
- (void) waitingViewShowAtPoint:(CGPoint)aPoint withText:(NSString *)aText withDelayHidden:(NSTimeInterval)aHiddenTime;

- (void) waitingViewShowAtPoint:(CGPoint)aPoint withText:(NSString *)aText withBtnAction:(void (^)(void))aAction;
///   aHiddenTime < =0 is show all the time
- (void) waitingViewShowAtPoint:(CGPoint)aPoint withText:(NSString *)aText withDelayHidden:(NSTimeInterval)aHiddenTime withBtnAction:(void (^)(void))aAction;

/**
 * 設定 檢查一個flag 如果為nil or NO 則會執行 action 然後 將flag設定成 YES;
 */
- (void) setOneTimeForTag:(NSString *)aDefineName withAction:(void (^)(void))aAction;

/**
 * 將一個flag 如果他存在在UserDefault的話， 設定成 NO
 */
- (void) clearOneTimeTag:(NSString *)aDefineName;

/**
 * 設定 檢查一個flag 如果為nil or NO 則會執行 action 
 */
- (void) checkOneTimeForTag:(NSString *)aDefineName withAction:(void (^)(void))aAction;

/**
 * 將一個flag 設定成 YES 且儲存在 UserDefault
 */
- (void) setOneTimeTag:(NSString *)aDefineName;

/**
 * Mode 切換
 */
- (void) setAppMode:(TMGlobal_AppMode)aMode;

- (TMGlobal_AppMode) appMode;

- (void) setDefaultAppMode:(TMGlobal_AppMode)aMode;

- (void) clearAppMode;

/**
 * ex: aModeDic = @{@"Parse":@[@"xxxxxxxxxxxx",
 *                             @"yyyyyyyyyy",
 *                             @"rrrrrrrrrr"],
 *                  @"Flurry":@[@"xxxxxxxxxxxx",
 *                             @"yyyyyyyyyy",
 *                             @"rrrrrrrrrr"]}
 */
- (void) setModeDictionary:(NSDictionary *)aModeDic;

- (id) objectOfClass:(NSString *)aClassName;

@end
