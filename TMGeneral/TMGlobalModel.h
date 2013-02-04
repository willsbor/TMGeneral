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
- (void) showWaitingView:(BOOL)aShow AtPoint:(CGPoint)aPoint withText:(NSString *)aText;

@end
