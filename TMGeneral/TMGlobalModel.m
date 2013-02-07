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

@interface TMGlobalModel ()
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
        [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut) animations:^{
            self.waitingView.transform = CGAffineTransformMakeTranslation(0, 0);
            self.waitingView.alpha = 0.0;
        } completion:^(BOOL finished) {
            //self.waitingView.hidden = YES;
            //self.waitingView.transform = CGAffineTransformMakeTranslation(0, 0);
        }];
    }
}

- (void) waitingViewShowAtPoint:(CGPoint)aPoint withText:(NSString *)aText withDelayHidden:(NSTimeInterval)aHiddenTime
{
    if (g_baseView == nil) {
        return;
    }
    
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
        self.waitingView = [[UIView alloc] initWithFrame:CGRectMake(0, height - 60, 130, 40)];
        self.waitingView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        [self.waitingView.layer setCornerRadius:4.0f];
        [self.waitingView.layer setMasksToBounds:YES];
        [self.waitingView.layer setBorderWidth:1.0f];
        [self.waitingView.layer setBorderColor: [[UIColor grayColor] CGColor]];
        
        UIActivityIndicatorView *pV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhite)];
        [pV startAnimating];
        [self.waitingView addSubview:pV];
        pV.center = CGPointMake(pV.frame.size.width / 2 + 5, 20);
        
        text = [[UILabel alloc] initWithFrame:CGRectMake(pV.frame.size.width + 10, 0, 100, 40)];
        text.backgroundColor = [UIColor clearColor];
        text.textColor = [UIColor whiteColor];
        text.font = [UIFont systemFontOfSize:12.0];
        text.tag = 24632;
        [self.waitingView addSubview:text];
        
        [g_baseView addSubview:self.waitingView];
        
        self.waitingView.alpha = 0.0;
    } else {
        text = (UILabel *)[self.waitingView viewWithTag:24632];
    }
    
    if (aText != nil) {
        text.text = aText;
        CGSize textSize = tmStringSize(text.text, text.font, MAXFLOAT);
        CGRect f = text.frame;
        f.size.width = textSize.width + 4;
        text.frame = f;
        
        f = self.waitingView.frame;
        f.size.width = 5.0 + 20/*pV.frame.size.width*/ + 5.0 + text.frame.size.width + 5;
        self.waitingView.frame = f;
    }
    
    if (!(aPoint.x == -3333 && aPoint.y == -3333)) {
        CGRect f = self.waitingView.frame;
        
        
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
        
        self.waitingView.frame = f;
    }
    
    self.waitingView.transform = CGAffineTransformMakeTranslation(0, 0);
    
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
    
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut) animations:^{
        self.waitingView.transform = CGAffineTransformMakeTranslation(nextx, nexty);
        self.waitingView.alpha = 1.0;
    } completion:^(BOOL finished) {
        //self.waitingView.transform = CGAffineTransformMakeTranslation(nextx, nexty);
        
        if (aHiddenTime > 0) {
            [self.waitingViewCloseTimer invalidate];
            self.waitingViewCloseTimer = [NSTimer scheduledTimerWithTimeInterval:aHiddenTime target:self selector:@selector(closeWaitingViewAction:) userInfo:nil repeats:NO];
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

- (id)init
{
    self = [super init];
    if (self) {
        _mapKey = [[NSMutableDictionary alloc] init];
    }
    return self;
}


@end
