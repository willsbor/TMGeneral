/*
 UITabBarController+CustomizeTabBar.m
 
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

#import "UITabBarController+CustomizeTabBar.h"
#import <objc/runtime.h>

static char UITABBAR_IDENTIFER;
static char UITABBAR_BUTTONS_IDENTIFER;

@implementation UITabBarController (CustomizeTabBar)
@dynamic customTabView;
@dynamic customButtonArrays;

- (UIView *) customTabView
{
    return objc_getAssociatedObject(self, &UITABBAR_IDENTIFER);
}

- (void) setCustomTabView:(UIView *)customTabView
{
    objc_setAssociatedObject(self, &UITABBAR_IDENTIFER, customTabView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *) customButtonArrays
{
    return objc_getAssociatedObject(self, &UITABBAR_BUTTONS_IDENTIFER);
}

- (void) setCustomButtonArrays:(NSArray *)buttonArrays
{
    objc_setAssociatedObject(self, &UITABBAR_BUTTONS_IDENTIFER, buttonArrays, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dealloc
{
    [self setCustomTabView:nil];
    [self setCustomButtonArrays:nil];
}

- (void)hideExistingTabBar
{
	for(UIView *view in self.view.subviews)
	{
		if([view isKindOfClass:[UITabBar class]])
		{
			view.hidden = YES;
            CGRect f = view.frame;
            f.size.height = 0;
            view.frame = f;
		}
        if ([[NSString stringWithFormat:@"%@", [view class]] isEqualToString:@"UITransitionView"] == YES) {
            CGRect f = view.frame;
            f.size.height += 49.0;
            view.frame = f;
        }
	}
}

- (void) click: (id)sender
{
    static BOOL processing = NO;
    
    if (processing == YES) {
        return;
    }
    processing = YES;
    
    if (sender != nil)
    {
        UIButton *prevBtn = [self.customButtonArrays objectAtIndex:self.selectedIndex];
        prevBtn.selected = NO;
        
        NSInteger nowIndex = [self.customButtonArrays indexOfObject:sender];
        self.selectedIndex = nowIndex;
        ((UIButton *)sender).selected = YES;
    }
    processing = NO;
}

- (void) loadDefaultPositionCustomTab:(UIView *)aView AndButtons:(NSArray *)aButtons
{
    aView.frame = CGRectMake(0, self.view.frame.size.height - aView.frame.size.height,aView.frame.size.width, aView.frame.size.height);
    aView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [self loadCustomTab:aView AndButtons:aButtons];
}

- (void) loadCustomTab:(UIView *)aView AndButtons:(NSArray *)aButtons
{
    //// 
    //  如果 aView 用同一個 多次載入  可能會造成 crash  還找不到原因
    ////
    [self.customTabView removeFromSuperview];
    self.customTabView = aView;
    
    self.customButtonArrays = aButtons;
    
    //aView.tag = CUSTOMIZE_TABBAR_VIEW_BASE_TAG_VALUE;

    // GET ALL UIButton
    
	for(UIButton *bv in self.customButtonArrays)
	{
        [((UIButton *)bv) removeTarget:self action:@selector(click:) forControlEvents:(UIControlEventTouchUpInside)];
        [(UIButton *)bv addTarget:self action:@selector(click:) forControlEvents:(UIControlEventTouchUpInside)];
        
        if (bv.tag == self.selectedIndex)
        {
            (bv).selected = YES;
        }
	}

    [self.view addSubview:self.customTabView];
    [self hideExistingTabBar];
}

- (void) customTabbarHidden:(BOOL)aHidden animation:(BOOL)animation
{
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            self.customTabView.alpha = (aHidden) ? 0.0 : 1.0;
        }];
    } else
        self.customTabView.alpha = (aHidden) ? 0.0 : 1.0;

}

@end
