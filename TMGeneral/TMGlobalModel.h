//
//  TMGlobalModel.h
//  TMGeneral
//
//  Created by mac on 12/10/19.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

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
- (void) cleanWaitingViewForLang;
- (BOOL) isWaitingViewDisplay;
- (void) waitingViewHidden;
- (void) waitingViewShowAtPoint:(CGPoint)aPoint withText:(NSString *)aText;
///   aHiddenTime < =0 is show all the time
- (void) waitingViewShowAtPoint:(CGPoint)aPoint withText:(NSString *)aText withDelayHidden:(NSTimeInterval)aHiddenTime;

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
