/*
 UITabBarController+CustomizeTabBar.h
 
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


#import <UIKit/UIKit.h>

//#define CUSTOMIZE_TABBAR_VIEW_BASE_TAG_VALUE  65534

@interface UITabBarController (CustomizeTabBar)

@property (nonatomic, readonly) UIView *customTabView;

/**
 * @brief 客製化tabbar  輸入要使用的 view + button
 *
 * tabbar 會至底靠齊
 *
 * @param aView 欲使用的UIView
 * @see - (void) loadCustomTab:(UIView *)aView AtCenter:(CGPoint)aCenter;
*/
- (void) loadCustomTab:(UIView *)aView;

/**
 * @brief 客製化tabbar  輸入要使用的 view + button
 * 
 * 要對  裡面的 UIButton  設定其 tag value from 0 to N  且位於 UIView的第一層
 * 其餘物件的tag  不可落在 0 ~ N 之間
 * @param aView 欲使用的UIView
 * @param aRectFrame Custume tabbar 要放置的中心位置
 */
- (void) loadCustomTab:(UIView *)aView AtRect:(CGRect)aRectFrame;

@end
