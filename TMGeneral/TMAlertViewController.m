//
//  TMAlertViewController.m
//  TMGeneral
//
//  Created by willsborKang on 13/10/7.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import "TMAlertViewController.h"
#import <libkern/OSAtomic.h>

@interface TMAlertViewController ()
{
    BOOL _isShow;
    
    int32_t _disableCount;
}

@end

@implementation TMAlertViewController

static int32_t g_alertShowCount = 0;

+ (void) resetGrayMaskCount
{
    g_alertShowCount = 0;
}

- (UIViewController *) baseVC
{
    UIWindow *main = nil;
    for (id object in [UIApplication sharedApplication].windows) {
        if ([NSStringFromClass([object class]) isEqualToString:@"UIWindow"]) {
            main = object;
            break;
        }
    }
    
    if (main == nil) {
        return nil;
    }
    
    __autoreleasing UIViewController *vc = (UIViewController *)[[[main subviews] objectAtIndex:0] nextResponder];
    
    //LOG_GENERAL(1, @"alert vc = %@", NSStringFromClass([vc class]));
    ////< 以上為了避開會因為alert而失效.....
    
    //// workaround
    //vc = ((UINavigationController *)vc).topViewController;
    //////
    
    return vc;
}

- (void) clickCancel {
    [self _disable];
    
    if ([self shouldClickCancel]) {
        OSAtomicDecrement32(&g_alertShowCount);
        if (_actionForCancel) _actionForCancel();
        
        [self _hide];
    } else {
        
    }
}

- (void) clickDoAction {
    [self _disable];
    
    if ([self shouldClickDoAction]) {
        OSAtomicDecrement32(&g_alertShowCount);
        if (_action) _action();
        
        [self _hide];
    } else {
        
    }
}

- (BOOL) shouldClickCancel {
    return YES;
}

- (BOOL) shouldClickDoAction {
    return YES;
}

- (void (^)(TMAlertViewController *alertVC, void (^animationfinish)(void))) showAnimation
{
    if (_showAnimation) {
        return _showAnimation;
    }
    
    _showAnimation = ^(TMAlertViewController *alertVC, void (^animationfinish)(void)) {
        alertVC.view.alpha = 0.0;
        alertVC.contentView.alpha = 0.0;
        alertVC.contentView.transform = CGAffineTransformMakeScale( 0.5, 0.5) ;
        [UIView animateWithDuration:0.3 animations:^{
            alertVC.view.alpha = 1.0;
            alertVC.contentView.alpha = 1.0;
            alertVC.contentView.transform = CGAffineTransformMakeScale( 1.1, 1.1) ;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 animations:^{
                alertVC.contentView.transform = CGAffineTransformMakeScale( 1.0, 1.0) ;
            } completion:^(BOOL finished) {
                animationfinish();
            }];
        }];
    };
    
    return _showAnimation;
}

- (void (^)(TMAlertViewController *alertVC, void (^animationfinish)(void))) hideAnimation
{
    if (_hideAnimation) {
        return _hideAnimation;
    }
    
    _hideAnimation = ^(TMAlertViewController *alertVC, void (^animationfinish)(void)) {
        [UIView animateWithDuration:0.3 animations:^{
            alertVC.contentView.alpha = 0.0;
            alertVC.view.alpha = 0.0;
            alertVC.contentView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        } completion:^(BOOL finished) {
            
            animationfinish();
        }];
    };
    
    return _showAnimation;
}

- (void) show
{
    if (_isShow == NO) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_animationModifyCardViewPosition)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_animationModifyCardViewPosition)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
        
        
        UIViewController *vc = [self baseVC];
        
        [vc.view addSubview:self.view];
        [vc addChildViewController:self];
        
        //LOG_GENERAL(1, @"alert vc frame = %@", NSStringFromCGRect(vc.view.frame));
        //LOG_GENERAL(1, @"alert self frame = %@", NSStringFromCGRect(self.view.frame));
        
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        CGRect f = self.view.frame;
        f.origin.y = (vc.view.frame.origin.y == 20) ? 0 : 20;
        self.view.frame = f;
        
        if (g_alertShowCount == 0) {  ///< 應該都會在mainthread上面
            if (self.grayBackgroundView) {
                self.grayBackgroundView.backgroundColor = self.grayColorOfBackground;
            }
        } else {
            if (self.grayBackgroundView) {
                self.grayBackgroundView.backgroundColor = self.grayColorOfBackground;
            }
        }
        OSAtomicIncrement32(&g_alertShowCount);
        
        [self _modifyCardViewPosition];
        _isShow = YES;

        [self _disable];
        
        self.showAnimation(self, ^{
            [self _enable];
        });
    }
    
}

- (UIColor *) grayColorOfBackground
{
    if (_grayColorOfBackground) {
        return _grayColorOfBackground;
    }
    
    _grayColorOfBackground = [UIColor colorWithWhite:0.0 alpha:0.7];
    return _grayColorOfBackground;
}

- (void) _hide
{
    if (_isShow) {
        _isShow = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardDidShowNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardDidHideNotification
                                                      object:nil];
        
        self.hideAnimation(self, ^{
            _action = nil;
            _actionForCancel = nil;
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        });
    }
}

- (void) _modifyCardViewPosition
{
    /// 算鍵盤高度
    float keyboardheight = 0;
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        for (UIView *view in [window subviews]) {
            if ([[NSString stringWithFormat:@"%@", [view class]] isEqualToString:@"UIPeripheralHostView"] == YES ) {
                //NSLog(@"%@ - %@", [view class], NSStringFromCGRect([view frame]));
                CGRect tmp = [view frame];
                keyboardheight = tmp.size.height;
                break;
            }
        }
    }
    
    //LOG_GENERAL(1, @"%f - %@", keyboardheight, NSStringFromCGRect(self.view.frame));
    self.contentView.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height - keyboardheight) / 2 + 10);
}

- (void) _animationModifyCardViewPosition
{
    [UIView animateWithDuration:0.3 animations:^{
        [self _modifyCardViewPosition];
    }];
}

- (void) _disable
{
    if (OSAtomicIncrement32(&_disableCount) > 0) {
        for (UIButton *object in self.cancelBtns) {
            object.enabled = NO;
        }
        
        for (UIButton *object in self.okBtns) {
            object.enabled = NO;
        }
    }
}

- (void) _enable
{
    if (OSAtomicDecrement32(&_disableCount) <= 0) {
        for (UIButton *object in self.cancelBtns) {
            object.enabled = YES;
        }
        
        for (UIButton *object in self.okBtns) {
            object.enabled = YES;
        }
    }
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.contentView.alpha = 0.0;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self _modifyCardViewPosition];
    self.contentView.alpha = 1.0;
}

#pragma mark -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    //LOG_GENERAL(0, @"dealloc %@", NSStringFromClass([self class]));
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    for (UIButton *object in self.cancelBtns) {
        [object addTarget:self action:@selector(clickCancel) forControlEvents:(UIControlEventTouchUpInside)];
        object.enabled = YES;
    }
    
    for (UIButton *object in self.okBtns) {
        [object addTarget:self action:@selector(clickDoAction) forControlEvents:(UIControlEventTouchUpInside)];
        object.enabled = YES;
    }
    
    if (self.title) self.contentTitleLabel.text = self.title;
    if (self.message) self.contentTextLabel.text = self.message;
    
    if (self.type == TMAlertType_OK) {
        self.cancelokView.alpha = 0.0;
        self.okView.alpha = 1.0;
        self.noneProcessingView.alpha = 0.0;
    }
    else if (self.type == TMAlertType_Cancel_OK) {
        self.cancelokView.alpha = 1.0;
        self.okView.alpha = 0.0;
        self.noneProcessingView.alpha = 0.0;
    }
    else if (self.type == TMAlertType_None) {
        self.cancelokView.alpha = 0.0;
        self.okView.alpha = 0.0;
        self.noneProcessingView.alpha = 1.0;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    if ([self isViewLoaded] && [self.view window] == nil)
    {
        // Add code to preserve data stored in the views that might be
        // needed later.
        
        // Add code to clean up other strong references to the view in
        // the view hierarchy.
        self.view = nil;
    }
}

- (void)viewDidUnload {
    [self setContentView:nil];
    [self setContentTitleLabel:nil];
    [self setContentTextLabel:nil];
    [self setCancelBtns:nil];
    [self setOkBtns:nil];
    [self setCancelokView:nil];
    [self setOkView:nil];
    [self setNoneProcessingView:nil];
    [self setGrayBackgroundView:nil];
    [super viewDidUnload];
}

@end
