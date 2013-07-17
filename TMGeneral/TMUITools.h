/*
 TMUITools.h
 
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
#import <UIKit/UIKit.h>

#ifndef __TMUITOOL_H__
#define __TMUITOOL_H__

/// 這個的處理速度似乎有點慢....
extern UIImage *tmImageResizeAndCutCenter(UIImage *aOriImage, CGSize aTargetSize);

/**
 * 從以圖片aOriImage中心  切除  aTargetSize以外的區域   如果 aTargetSize大於原圖，則會回傳原圖
 */
extern UIImage *tmImageCutCenter(UIImage *aOriImage, CGSize aTargetSize);

extern UIImage *tmImageRotateByOwnOrientationFrom(UIImage *aOriImage);

extern UIImage *tmUIViewToImage(UIView *view);

extern UIImage *tmUIViewsToImage(UIView *view);

extern UIImage *tmResizeImage(UIImage *aOriImage, CGSize aTargetSize);

/**
 * 很好.... 忘了註解 也忘了這是幹嘛的....
 */
extern CGAffineTransform tmAspectFit(CGRect innerRect, CGRect outerRect);

/**
 * scale
 The scale factor to apply to the bitmap. If you specify a value of 0.0, the scale factor is set to the scale factor of the device’s main screen.
 */
extern UIImage *tmResizeImageWithScale(UIImage *aOriImage, CGSize aTargetSize, CGFloat aScale);

/**
 * 這個沒有保護當寬度太小 連一個字都放不下去的時候的問題
 * for 4.3 or 5.x  聽說6.0 有support 多顏色的UILabel
 */
//extern UIView *tmViewCreateByDatas(NSArray *aDatas, float aWidth, float aLH);
extern UIView *tmViewCreateByDatas(NSArray *aDatas, float aWidth, float aLH, NSDictionary *aParam);

/**
 * 回傳string的uilabel的顯示大小 (aRefWidth 為限制寬度， 如果無限制則請傳入 MAXFLOAT)
 */
extern CGSize tmStringSize(NSString *aString, UIFont *aFont, float aRefWidth);

/**
 * 定義最大最小的字型大小，會自動搜尋最大size 且 能完整放入 UILabel中的字型大小後，調整UILabel的字型大小
 */
extern void tmModifyLabelSizeByFontSize(UILabel *aText, float aMaxFontSize, float aMinFontSize);

extern void tmBringUIViewBehindAtY(UIView *aSecond, UIView *aRefView, float aOffset);

extern void tmBringUIViewBehindAtX(UIView *aSecond, UIView *aRefView, float aOffset);

/**
 * 產生一個 小小色塊
 */
extern UIImage *tmImageWithColor(UIColor *color);

/**
 * resize btn size for text
 */
extern void tmResizeBtnSize(UIButton *aBtn, float aWidthBuffer);

extern void tmResizeBtnSizeRefRight(UIButton *aBtn, float aWidthBuffer);

extern void tmResetBtnBackgroundImage(UIButton *aBtn, UIEdgeInsets capInsets, UIControlState aForState);
#endif