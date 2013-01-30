//
//  TMUITools.h
//  TMGeneral
//
//  Created by mac on 12/10/16.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef __TMUITOOL_H__
#define __TMUITOOL_H__

/// 這個的處理速度似乎有點慢....
extern UIImage *tmImageResizeAndCutCenter(UIImage *aOriImage, CGSize aTargetSize);

extern UIImage *tmImageRotateByOwnOrientationFrom(UIImage *aOriImage);

extern UIImage *tmUIViewToImage(UIView *view);

extern UIImage *tmUIViewsToImage(UIView *view);

extern UIImage *tmResizeImage(UIImage *aOriImage, CGSize aTargetSize);

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

extern CGSize tmStringSize(NSString *aString, UIFont *aFont, float aRefWidth);

extern void tmBringUIViewBehindAtY(UIView *aSecond, UIView *aRefView, float aOffset);

extern void tmBringUIViewBehindAtX(UIView *aSecond, UIView *aRefView, float aOffset);

extern UIImage *tmImageWithColor(UIColor *color);

#endif