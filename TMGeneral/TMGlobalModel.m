//
//  TMGlobalModel.m
//  TMGeneral
//
//  Created by mac on 12/10/19.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import "TMGlobalModel.h"
#import <QuartzCore/QuartzCore.h>
#import "TMUITools.h"
#import "TMTools.h"

const NSString *TMGlobalAppModeRelease = @"TMG_AppMode_Release";
const NSString *TMGlobalAppModeTest = @"TMG_AppMode_Test";
const NSString *TMGlobalAppModeDevelop = @"TMG_AppMode_Develop";
const NSString *TMGlobalAppModeCustome1 = @"TMG_AppMode_Custome_1";
const NSString *TMGlobalAppModeCustome2 = @"TMG_AppMode_Custome_2";
const NSString *TMGlobalAppModeCustome3 = @"TMG_AppMode_Custome_3";

@interface TMGlobalModel ()
{
    TMGlobal_AppMode _defaultAppMode;
}
@property (nonatomic, strong) NSDictionary *appModeValueMap;
@property (nonatomic, strong) UIView *waitingView;
@property (nonatomic, strong) NSTimer *waitingViewCloseTimer;
@end

@implementation TMGlobalModel

static __weak UIView *g_baseView = nil;
static TMGlobal_WaitingView_Animation_Direction g_waitingDirection = TMGlobal_WaitingView_Animation_Direction_L2R;

+ (void) setWaitingViewBaseView:(UIView *)aView
{
    g_baseView = aView;
}

+ (void) setWaitingViewAnimationDirection:(TMGlobal_WaitingView_Animation_Direction)aDirection
{
    g_waitingDirection = aDirection;
}

- (void) cleanWaitingViewForLang
{
    [self.waitingView removeFromSuperview];
    self.waitingView = nil;
}

- (BOOL) isWaitingViewDisplay
{
    if (self.waitingView != nil && self.waitingView.alpha != 0.0) {
        return YES;
    } else
        return NO;
}

- (void) waitingViewShowAtPoint:(CGPoint)aPoint withText:(NSString *)aText
{
    [self waitingViewShowAtPoint:aPoint withText:aText withDelayHidden:-1];
}

- (void) waitingViewHidden
{
    [self.waitingViewCloseTimer invalidate];
    self.waitingViewCloseTimer = nil;
    
    if (self.waitingView != nil && self.waitingView.alpha != 0.0) {
        __unsafe_unretained TMGlobalModel *selfIem = self;
        [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut) animations:^{
            selfIem.waitingView.transform = CGAffineTransformMakeTranslation(0, 0);
            selfIem.waitingView.alpha = 0.0;
        } completion:^(BOOL finished) {
            //self.waitingView.hidden = YES;
            //self.waitingView.transform = CGAffineTransformMakeTranslation(0, 0);
        }];
    }
}

- (void) waitingViewShowAtPoint:(CGPoint)aPoint withText:(NSString *)aText withDelayHidden:(NSTimeInterval)aHiddenTime
{
    static CGFloat upBottomBuffer = 8;
    static CGFloat defaultActivityIndWidth = 20.0;   /*activityIndicator 要預留的寬度*/
    static CGFloat cBuffer = 5.0;
    static CGFloat tBuffer = 4.0;  ///< 我也忘了這是什麼
    
    if (g_baseView == nil) {
        return;
    }
    
    UIFont *font = [UIFont systemFontOfSize:12.0];
    CGSize textSize = tmStringSize(aText, font, [[ UIScreen mainScreen ] bounds ].size.width
                                   - (defaultActivityIndWidth + cBuffer * 3 + tBuffer));
    NSLog(@"textSize = %@", NSStringFromCGSize(textSize));
    
    UIActivityIndicatorView *pV;
    UILabel *text;
    if (self.waitingView == nil) {
        if (aText == nil) {
            aText = @" ";
        }
        if (aPoint.x == -3333 && aPoint.y == -3333)
        {
            aPoint.x = 0;
            aPoint.y = 240;
        }
        
        CGFloat height = [[ UIScreen mainScreen ] bounds ].size.height;
        self.waitingView = [[UIView alloc] initWithFrame:CGRectMake(0, height - 60, 130, textSize.height + upBottomBuffer + upBottomBuffer)];
        self.waitingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        [self.waitingView.layer setCornerRadius:4.0f];
        [self.waitingView.layer setMasksToBounds:YES];
        [self.waitingView.layer setBorderWidth:1.0f];
        [self.waitingView.layer setBorderColor: [[UIColor grayColor] CGColor]];
        
        pV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhite)];
        pV.tag = 3233;
        [pV startAnimating];
        [self.waitingView addSubview:pV];
        CGRect f = pV.frame;
        f.origin.x = cBuffer;
        f.origin.y = (self.waitingView.frame.size.height - f.size.height) / 2;
        pV.frame = f;
        
        text = [[UILabel alloc] initWithFrame:CGRectMake(pV.frame.size.width + 10, 0, 100, textSize.height + upBottomBuffer + upBottomBuffer)];
        text.numberOfLines = 0;
        text.backgroundColor = [UIColor clearColor];
        text.textColor = [UIColor whiteColor];
        text.font = font;
        text.tag = 24632;
        [self.waitingView addSubview:text];
        
        [g_baseView addSubview:self.waitingView];
        
        self.waitingView.alpha = 0.0;
    } else {
        text = (UILabel *)[self.waitingView viewWithTag:24632];
        pV = (UIActivityIndicatorView *)[self.waitingView viewWithTag:3233];
    }
    
    [self.waitingViewCloseTimer invalidate];
    
    CGRect newf;
    if (aText != nil) {
        text.text = aText;
        CGRect f = text.frame;
        f.size.width = textSize.width + tBuffer;
        f.size.height = textSize.height + upBottomBuffer * 2;
        text.frame = f;
        
        f = self.waitingView.frame;
        f.size.width = cBuffer + defaultActivityIndWidth + cBuffer + text.frame.size.width + cBuffer;
        f.size.height = textSize.height + upBottomBuffer * 2;
        newf = f;
        
        f = pV.frame;
        f.origin.y = (newf.size.height - f.size.height) / 2;
        pV.frame = f;
    }
    
    if (!(aPoint.x == -3333 && aPoint.y == -3333)) {
        CGRect f = newf;
        
        
        switch (g_waitingDirection) {
            default:
            case TMGlobal_WaitingView_Animation_Direction_L2R:
                f.origin.x = aPoint.x - f.size.width;
                f.origin.y = aPoint.y;
                break;
            case TMGlobal_WaitingView_Animation_Direction_R2L:
                f.origin.x = aPoint.x;
                f.origin.y = aPoint.y;
                break;
            case TMGlobal_WaitingView_Animation_Direction_D2U:
                f.origin.x = aPoint.x - f.size.width / 2;
                f.origin.y = aPoint.y;
                break;
            case TMGlobal_WaitingView_Animation_Direction_U2D:
                f.origin.x = aPoint.x - f.size.width / 2;
                f.origin.y = aPoint.y - f.size.height;
                break;
        }
        
        newf = f;
    }
    
    if (self.waitingView.alpha == 0) {
        self.waitingView.transform = CGAffineTransformMakeTranslation(0, 0);
        self.waitingView.frame = newf;
    }
    
    CGFloat nextx, nexty;
    switch (g_waitingDirection) {
        default:
        case TMGlobal_WaitingView_Animation_Direction_L2R:
            nextx = self.waitingView.frame.size.width;
            nexty = 0;
            break;
        case TMGlobal_WaitingView_Animation_Direction_R2L:
            nextx = -self.waitingView.frame.size.width;
            nexty = 0;
            break;
        case TMGlobal_WaitingView_Animation_Direction_D2U:
            nextx = 0;
            nexty = -self.waitingView.frame.size.height;
            break;
        case TMGlobal_WaitingView_Animation_Direction_U2D:
            nextx = 0;
            nexty = self.waitingView.frame.size.height;
            break;
    }
    
    __unsafe_unretained TMGlobalModel *selfIem = self;
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut) animations:^{
        selfIem.waitingView.transform = CGAffineTransformMakeTranslation(nextx, nexty);
        selfIem.waitingView.alpha = 1.0;
    } completion:^(BOOL finished) {
        //self.waitingView.transform = CGAffineTransformMakeTranslation(nextx, nexty);
        
        if (aHiddenTime > 0) {
            selfIem.waitingViewCloseTimer = [NSTimer scheduledTimerWithTimeInterval:aHiddenTime target:selfIem selector:@selector(closeWaitingViewAction:) userInfo:nil repeats:NO];
        }
    }];
}

- (void) closeWaitingViewAction:(id)sender
{
    [self waitingViewHidden];
}

- (void) updateDatas:(NSDictionary *) aJSONDic
{
    for (NSString *key in [aJSONDic allKeys]) {
        NSString *mapKey = [_mapKey objectForKey:key];
        if (mapKey == nil) {
            mapKey = key;
        }
        
        @try {
            id value = [aJSONDic objectForKey:key];
            if ([self validateValue:&value forKey:mapKey error:nil] )
                [self setValue:value forKey:mapKey];
        }
        @catch (NSException *exception) {
            NSLog(@"exception = %@", exception);
        }
    }
}

- (void) clearOneTimeTag:(NSString *)aDefineName
{
    if (aDefineName == nil) {
        return;
    }
    
    NSNumber *v = [[NSUserDefaults standardUserDefaults] objectForKey:aDefineName];
    if (v != nil) {
        if ([v isKindOfClass:[NSNumber class]] && [v boolValue]) {
            [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:aDefineName];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void) setOneTimeForTag:(NSString *)aDefineName withAction:(void (^)(void))aAction
{
    if (aDefineName == nil) {
        return;
    }
    
    NSNumber *v = [[NSUserDefaults standardUserDefaults] objectForKey:aDefineName];
    if (v == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:aDefineName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        aAction();
    } else {
        if ([v isKindOfClass:[NSNumber class]] && [v boolValue] == NO) {
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:aDefineName];
            [[NSUserDefaults standardUserDefaults] synchronize];
            aAction();
        }
    }
}

/**
 * 設定 檢查一個flag 如果為nil or NO 則會執行 action
 */
- (void) checkOneTimeForTag:(NSString *)aDefineName withAction:(void (^)(void))aAction
{
    if (aDefineName == nil) {
        return;
    }
    
    NSNumber *v = [[NSUserDefaults standardUserDefaults] objectForKey:aDefineName];
    if (v == nil) {
        aAction();
    } else {
        if ([v isKindOfClass:[NSNumber class]] && [v boolValue] == NO) {
            aAction();
        }
    }
}

/**
 * 將一個flag 設定成 YES 且儲存在 UserDefault
 */
- (void) setOneTimeTag:(NSString *)aDefineName
{
    if (aDefineName == nil) {
        return;
    }
    
    //NSNumber *v = [[NSUserDefaults standardUserDefaults] objectForKey:aDefineName];
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:aDefineName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


/**
 * Mode 切換
 */
#define __UserDefault_Mode_Key_Format  @"%@, hi2,e@#4@#=="
#define __UserDefault_Mode_Format @"%@=/=?=%@"

- (void) setAppMode:(TMGlobal_AppMode)aMode
{
    NSAssert(aMode < TMGlobal_AppMode_Num, @"Not in the set of TMGlobal_AppMode");
    NSAssert(aMode >= 0, @"Not in the set of TMGlobal_AppMode");
    
    NSString *bundle = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
    NSArray *checkArray = @[TMGlobalAppModeRelease, TMGlobalAppModeDevelop, TMGlobalAppModeTest, TMGlobalAppModeCustome1, TMGlobalAppModeCustome2, TMGlobalAppModeCustome3];
    
    NSString *valid = tmStringFromMD5([NSString stringWithFormat:__UserDefault_Mode_Format, bundle, checkArray[aMode]]);
    
    [[NSUserDefaults standardUserDefaults] setObject:valid forKey:[NSString stringWithFormat:__UserDefault_Mode_Key_Format, bundle]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (TMGlobal_AppMode) appMode
{
    NSString *bundle = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
    NSLog(@"test : now bundle ID = %@", bundle);
    
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:__UserDefault_Mode_Key_Format, bundle]];
    
    NSArray *checkArray = @[TMGlobalAppModeRelease, TMGlobalAppModeDevelop, TMGlobalAppModeTest, TMGlobalAppModeCustome1, TMGlobalAppModeCustome2, TMGlobalAppModeCustome3];
    
    for (int i = 0; i < [checkArray count]; ++i) {
        NSString *key = checkArray[i];
        NSString *valid = tmStringFromMD5([NSString stringWithFormat:__UserDefault_Mode_Format, bundle, key]);
        if ([valid isEqualToString:value]) {
            return i;
        }
    }
    
    return _defaultAppMode; 
}

- (void) setDefaultAppMode:(TMGlobal_AppMode)aMode
{
    _defaultAppMode = aMode;
}

- (void) clearAppMode
{
    NSString *bundle = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:__UserDefault_Mode_Key_Format, bundle]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 * ex: aModeDic = @{@"Parse":@[@"xxxxxxxxxxxx",
 *                             @"yyyyyyyyyy",
 *                             @"rrrrrrrrrr"],
 *                  @"Flurry":@[@"xxxxxxxxxxxx",
 *                             @"yyyyyyyyyy",
 *                             @"rrrrrrrrrr"]}
 */
- (void) setModeDictionary:(NSDictionary *)aModeDic
{
    self.appModeValueMap = [aModeDic copy];
}

- (id) objectOfClass:(NSString *)aClassName
{
    NSAssert(self.appModeValueMap != nil, @"self.appModeValueMap is nil");
    
    NSArray *array = [self.appModeValueMap objectForKey:aClassName];
    NSAssert(array != nil, @"there is no \"%@\" setting", aClassName);
    NSAssert([[array class] isSubclassOfClass:[NSArray class]], @"the items should be NSArray");
    NSAssert([array count] <= TMGlobal_AppMode_Num, @"items data too many");
    NSAssert([array count] >= 3, @"items data too less, (release, develop, test ....)");
    
    TMGlobal_AppMode nowMode = [self appMode];
    NSAssert(nowMode < [array count], @"now mode is out of range");
    
    return [array objectAtIndex:nowMode];
}


- (id)init
{
    self = [super init];
    if (self) {
        _mapKey = [[NSMutableDictionary alloc] init];
        _defaultAppMode = TMGlobal_AppMode_Develop;
    }
    return self;
}


@end
