/*
 UITabBarController+CustomizeTabBar.m
 
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

#import "UITabBarController+CustomizeTabBar.h"

@implementation UITabBarController (CustomizeTabBar)

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
			//break;
		}
        if ([[NSString stringWithFormat:@"%@", [view class]] isEqualToString:@"UITransitionView"] == YES) {
           // view.frame = CGRectMake(0, 0, 320, 411 + 49);
            CGRect f = view.frame;
            f.size.height += 49.0;
            view.frame = f;
        }
        //HiiirLog(@"%@ %f, %f, %f ,%f", [view class], view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
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
        //HiiirLog(@"adsdf %d", ((UIButton *)sender).tag );
        
        if (((UIButton *)sender).tag < [self.viewControllers count])
        {
            ///workaround
            UIView *superview = ((UIButton *)sender).superview;
            ((UIButton *)[superview viewWithTag:self.selectedIndex]).selected = NO;
            ////
            
            self.selectedIndex = ((UIButton *)sender).tag;
            ((UIButton *)sender).selected = YES;
            
        }
    }
    processing = NO;
}



-(void) loadCustomTab:(UIView *)aView
{
    aView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [self loadCustomTab:aView AtRect:CGRectMake(0, self.view.frame.size.height - aView.frame.size.height,aView.frame.size.width, aView.frame.size.height)];
}

- (void) loadCustomTab:(UIView *)aView AtRect:(CGRect)aRectFrame
{
    //// 
    //  如果 aView 用同一個 多次載入  可能會造成 crash  還找不到原因
    ////
    [aView removeFromSuperview];
    
    aView.tag = CUSTOMIZE_TABBAR_VIEW_BASE_TAG_VALUE;
    
    aView.frame = aRectFrame;

    // GET ALL UIButton
    
	for(UIView *bv in aView.subviews)
	{
		if([bv isKindOfClass:[UIButton class]])
		{
            [((UIButton *)bv) removeTarget:self action:@selector(click:) forControlEvents:(UIControlEventTouchUpInside)];
			[(UIButton *)bv addTarget:self action:@selector(click:) forControlEvents:(UIControlEventTouchUpInside)];
            
            if (bv.tag == self.selectedIndex)
            {
                ((UIButton *)bv).selected = YES;
            }
		}
	}

    [self.view addSubview:aView];
    [self hideExistingTabBar];
}

@end
