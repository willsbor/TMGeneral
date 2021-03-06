/*
 TMUITools.m
 
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

#import "TMUITools.h"
#import "TMTools.h"
#import <QuartzCore/CoreAnimation.h>

UIImage *tmImageResizeAndCutCenter(UIImage *aOriImage, CGSize aTargetSize)
{
    float imageWidth = aOriImage.size.width;
    float imageHeight = aOriImage.size.height;
    
    assert(imageWidth > 0 && imageHeight > 0); //<@"imageResizeAndMatchCenter Input image illegal"
    
    UIImage *imgThumb;

    float tempImageX = 0;
    float tempImageY = 0;
    
    float tempImageWidth = 0;
    float tempImageHeight  = 0;
    
    // Calc clip rectangle
    /// Kang modify
    /// 直接把 fb近來的圖取最大的中央正方形
    
    float realRatio = aTargetSize.width;
    realRatio /= aTargetSize.height;
    
    float ratio = imageWidth;
    ratio /= imageHeight;
    
    if (ratio > realRatio) {
        // 以高為主，切割畫面
        // 取全高，裁減寬
        tempImageHeight = imageHeight ;
        tempImageWidth = imageHeight  * realRatio;
        
        tempImageX = -( imageWidth - tempImageWidth ) / 2;
        tempImageY = 0;
    } else {
        // 以寬為主，切割畫面
        // 取全寬，裁減高
        tempImageHeight = imageWidth / realRatio ;
        tempImageWidth = imageWidth  ;
        
        tempImageX = 0;
        tempImageY = (tempImageHeight - imageHeight)/ 2;
    }
    
    // 裁減 UIImage
    CGRect clipRect = CGRectMake(tempImageX, tempImageY, imageWidth, imageHeight);
    
    CGContextRef context;
    UIGraphicsBeginImageContext(CGSizeMake(tempImageWidth, tempImageHeight));
    
    context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -tempImageHeight);
    CGContextDrawImage(context, clipRect, aOriImage.CGImage);
    
    imgThumb = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return imgThumb;
}

UIImage *tmImageCutCenter(UIImage *aOriImage, CGSize aTargetSize)
{
    if (aTargetSize.width >= aOriImage.size.width
        && aTargetSize.height >= aOriImage.size.height) {
        return aOriImage;
    }
    
    aTargetSize.width = MIN(aTargetSize.width, aOriImage.size.width);
    aTargetSize.height = MIN(aTargetSize.height, aOriImage.size.height);
    
    float tempImageX = -(aOriImage.size.width - aTargetSize.width) / 2;
    float tempImageY = -(aOriImage.size.height - aTargetSize.height) / 2;
    
    // 裁減 UIImage
    CGRect clipRect = CGRectMake(tempImageX, tempImageY, aOriImage.size.width, aOriImage.size.height);
    
    CGContextRef context;
    UIGraphicsBeginImageContext(aTargetSize);
    
    context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -aTargetSize.height);
    CGContextDrawImage(context, clipRect, aOriImage.CGImage);
    
    __autoreleasing UIImage *imgThumb = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imgThumb;
}

UIImage *tmImageRotateByOwnOrientationFrom(UIImage *aOriImage)
{
    int orient = aOriImage.imageOrientation;
    
    // UIView* rotatedViewBox = [[UIView alloc] initWithFrame: CGRectMake(0, 0, aOri.size.width, aOri.size.height)];
    
    float angleRadians;
    CGSize rotatedSize;
    CGRect rect;
    switch (orient) {
        case UIImageOrientationLeft:
            angleRadians = 3.0 * M_PI / 2.0;
            rotatedSize = CGSizeMake(aOriImage.size.width, aOriImage.size.height);
            rect = CGRectMake(-aOriImage.size.width / 2, -aOriImage.size.height / 2, rotatedSize.height, rotatedSize.width);
            break;
        case UIImageOrientationRight:
            angleRadians = M_PI / 2.0;
            rotatedSize = CGSizeMake(aOriImage.size.width, aOriImage.size.height);
            rect = CGRectMake(-aOriImage.size.height / 2, -aOriImage.size.width / 2, rotatedSize.height, rotatedSize.width);
            break;
        case UIImageOrientationDown:
            angleRadians = M_PI;
            rotatedSize = CGSizeMake(aOriImage.size.width, aOriImage.size.height);
            rect = CGRectMake(-aOriImage.size.width / 2, -aOriImage.size.height / 2, rotatedSize.width, rotatedSize.height);
            break;
        default:
            angleRadians = 0.0;
            rotatedSize = CGSizeMake(aOriImage.size.width, aOriImage.size.height);
            rect = CGRectMake(-aOriImage.size.width / 2, -aOriImage.size.height / 2, rotatedSize.width, rotatedSize.height);
            break;
    }
    
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    CGContextRotateCTM(bitmap, angleRadians);
    
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, rect, [aOriImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

CGAffineTransform tmAspectFit(CGRect innerRect, CGRect outerRect)
{
    CGFloat scaleFactor = MIN(outerRect.size.width/innerRect.size.width, outerRect.size.height/innerRect.size.height);
    CGAffineTransform scale = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    CGRect scaledInnerRect = CGRectApplyAffineTransform(innerRect, scale);
    CGAffineTransform translation =
    CGAffineTransformMakeTranslation((outerRect.size.width - scaledInnerRect.size.width) / 2 - scaledInnerRect.origin.x,
                                     (outerRect.size.height - scaledInnerRect.size.height) / 2 - scaledInnerRect.origin.y);
    return CGAffineTransformConcat(scale, translation);
}

UIView *tmViewCreateByDatas(NSArray *aDatas, float aWidth, float aLH, NSDictionary *aParam)
{
    UIView *paper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, aWidth, 100.0)];
    paper.backgroundColor = [UIColor clearColor];
    
    float markPositionX = 0.0;
    int lineCount = 1;
    //float markPositionY = 0.0;
    //float lineHeight = 10.0;
    float _TextIndent = 0;  ///< 第一行除外的n行縮排
    if ([aParam objectForKey:@"TextIndent"] != nil) {
        _TextIndent = [[aParam objectForKey:@"TextIndent"] floatValue];
    }
    
    for (NSArray *section in aDatas) {
        for (UIView *object in section) {
            BOOL isFirstLine = YES;
            float TextIndent = 0;
            
            if ([object class] == [UILabel class]) {
                UILabel *label = (UILabel *)object;
                CGPoint offset = label.frame.origin;
                label.backgroundColor = [UIColor clearColor];
                CGSize _size = tmStringSize(label.text ,label.font, MAXFLOAT);
                float remaind = markPositionX + _size.width - (aWidth);
                
                if (remaind > 0) {
                    NSString *cutString = nil;
                    CGSize _r_size;
                    int iMark = 0;
                    while (iMark < [label.text length]) {
                        int i;
                        for (i = [label.text length] - iMark ; i >= 1; --i) {
                            cutString = [label.text substringWithRange:NSMakeRange(iMark, i)];
                            _r_size = tmStringSize(cutString ,label.font, MAXFLOAT);
                            if (markPositionX + _r_size.width <= (aWidth)) {
                                break;
                            }
                        }
                        
                        if (i == 0) {
                            ///表示這行滿倒放不下字
                            lineCount += 1;
                            if (isFirstLine) {
                                TextIndent = _TextIndent;
                                isFirstLine = NO;
                            }
                            
                            markPositionX = TextIndent;
                            continue; ///while
                        }
                        
                        UILabel *tmpL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _r_size.width, _r_size.height)];
                        tmpL.font = label.font;
                        tmpL.text = cutString;
                        tmpL.backgroundColor = [UIColor clearColor];
                        tmpL.textColor = label.textColor;
                        tmpL.textAlignment = NSTextAlignmentLeft;

                        [paper addSubview:tmpL];
                        tmpL.frame = CGRectMake(offset.x + markPositionX, offset.y + (aLH * (lineCount)) - _r_size.height, _r_size.width, _r_size.height);
                        markPositionX += _r_size.width;
                        
                        iMark += i;
                        if (iMark >= [label.text length]) {
                            break;
                        } else {
                            lineCount += 1;
                            if (isFirstLine) {
                                TextIndent = _TextIndent;
                                isFirstLine = NO;
                            }
                            
                            markPositionX = TextIndent;
                        }
                    }
                    
                    
                } else {
                    [paper addSubview:label];
                    label.textAlignment = NSTextAlignmentLeft;
                    label.frame = CGRectMake(offset.x + markPositionX, offset.y + (aLH * (lineCount)) - _size.height, _size.width, _size.height);
                    markPositionX += _size.width;
                    
                    //if (remaind == 0) {
                    //    lineCount += 1;  ///表示這行滿了  要到下一行
                    //    markPositionX = 0;
                    //}
                }
            } else if ([object class] == [UIImageView class]) {
                UIImageView *img = (UIImageView *)object;
                CGPoint offset = img.frame.origin;
                CGSize _size = img.frame.size;
                
                if (markPositionX >= (aWidth)) {
                    /// 圖沒辦法換行 但是如果超過一行的話 下一張就一定要換行
                    /// 這個放在  下面那三行前面試因為 如果前面那個是圖 可能就會超過一行
                    /// 所以圖接圖之前要檢查  如果前面是文字 基本上UILABEL的部份就有檢查掉了
                    lineCount += 1;
                    if (isFirstLine) {
                        TextIndent = _TextIndent;
                        //isFirstLine = NO;
                    }
                    
                    markPositionX = TextIndent;
                }
                
                [paper addSubview:img];
                img.frame = CGRectMake(offset.x + markPositionX, offset.y + (aLH * (lineCount)) - _size.height, _size.width, _size.height);
                markPositionX += _size.width;
                
                
                
            } else {
                /// 不是 Label的時候的處理
                
            }
        }
        
        ///換行
        lineCount += 1;
        markPositionX = 0;
    }
    
    CGRect _frame = paper.frame;
    _frame.size.height = (lineCount - 1) * aLH;  ///< 理論上會多加一行  所以扣掉
    paper.frame = _frame;
    
    return paper;

}

CGSize tmStringSize(NSString *aString, UIFont *aFont, float aRefWidth)
{
    __block CGSize expectedLabelSize;
    
    if ([aString respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        //expectedLabelSize = [aString sizeWithAttributes:@{NSFontAttributeName:aFont}];

        
         CGSize maximumLabelSize = CGSizeMake(aRefWidth,MAXFLOAT);
         NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
         
         CGRect newRect = [aString boundingRectWithSize:maximumLabelSize
                                                options:options
                                             attributes:@{NSFontAttributeName: aFont}
                                                context:nil];
         
         expectedLabelSize = newRect.size;
    }
    else {
        CGSize maximumLabelSize = CGSizeMake(aRefWidth,MAXFLOAT);
        expectedLabelSize = [aString sizeWithFont:aFont
                                constrainedToSize:maximumLabelSize
                                    lineBreakMode:NSLineBreakByWordWrapping];
    }
    return expectedLabelSize;
}

void tmModifyLabelSizeByFontSize(UILabel *aText, float aMaxFontSize, float aMinFontSize)
{
    CGFloat fsize = aMaxFontSize;
    CGSize s;
    do {
        aText.font = [aText.font fontWithSize:fsize];
        fsize -= 1.0;
        s = tmStringSize(aText.text, aText.font, aText.frame.size.width);
        
    } while (s.height > aText.frame.size.height && fsize > aMinFontSize);
}

void tmLabelSizeFitTextSize(UILabel *aText, float aRefWidth)
{
    CGSize s = tmStringSize(aText.text, aText.font, aRefWidth);
    CGRect f = aText.frame;
    f.size = s;
    aText.frame = f;
}

/**
 *  讓  UILabel 大小fit text的寬度
 */
void tmLabelSizeFitTextSizeWidth(UILabel *aText, float aRefWidth)
{
    CGSize s = tmStringSize(aText.text, aText.font, aRefWidth);
    CGRect f = aText.frame;
    f.size.width = s.width;
    f.size.height = MAX(f.size.height, s.height);
    aText.frame = f;
}

/**
 *  讓  UILabel 大小fit text的高度
 */
void tmLabelSizeFitTextSizeHeight(UILabel *aText, float aRefWidth)
{
    CGSize s = tmStringSize(aText.text, aText.font, aRefWidth);
    CGRect f = aText.frame;
    f.size.width = MAX(f.size.width, s.width);
    f.size.height = s.height;
    aText.frame = f;
}

void tmBringUIViewBehindAtY(UIView *aSecond, UIView *aRefView, float aOffset)
{
    CGRect newFrame = aSecond.frame;
    newFrame.origin.y = aRefView.frame.origin.y + aRefView.frame.size.height + aOffset;
    aSecond.frame = newFrame;
}

void tmBringUIViewBehindAtX(UIView *aSecond, UIView *aRefView, float aOffset)
{
    CGRect newFrame = aSecond.frame;
    newFrame.origin.x = aRefView.frame.origin.x + aRefView.frame.size.width + aOffset;
    aSecond.frame = newFrame;
}

extern UIImage *tmUIViewsToImage(UIView *view)
{
     // Create a graphics context with the target size
     // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
     // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
     //
     //  CGSize imageSize = [[UIScreen mainScreen] bounds].size;
     CGSize imageSize = view.frame.size;        // camera image size
     
     if (NULL != UIGraphicsBeginImageContextWithOptions)
     UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
     else
     UIGraphicsBeginImageContext(imageSize);
     
     CGContextRef context = UIGraphicsGetCurrentContext();
     
     // Start with the view...
     //
     CGContextSaveGState(context);
     CGContextTranslateCTM(context, [view center].x, [view center].y);
     CGContextConcatCTM(context, [view transform]);
     CGContextTranslateCTM(context,-[view bounds].size.width * [[view layer] anchorPoint].x,-[view bounds].size.height * [[view layer] anchorPoint].y);
     [[view layer] renderInContext:context];
     CGContextRestoreGState(context);
     
     // ...then repeat for every subview from back to front
     //
     for (UIView *subView in [view subviews])
     {
     if ( [subView respondsToSelector:@selector(screen)] )
     if ( [(UIWindow *)subView screen] == [UIScreen mainScreen] )
     continue;
     
     CGContextSaveGState(context);
     CGContextTranslateCTM(context, [subView center].x, [subView center].y);
     CGContextConcatCTM(context, [subView transform]);
     CGContextTranslateCTM(context,-[subView bounds].size.width * [[subView layer] anchorPoint].x,-[subView bounds].size.height * [[subView layer] anchorPoint].y);
     [[subView layer] renderInContext:context];
     CGContextRestoreGState(context);
     }
     
     UIImage *image = UIGraphicsGetImageFromCurrentImageContext();   // autoreleased image
     
     UIGraphicsEndImageContext();
     
     return image;
}

UIImage *tmUIViewToImage(UIView *view)
{
    
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    CGContextRef context=UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    //取得影像
    UIImage *the_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return the_image;
}

UIImage *tmResizeImageWithScale(UIImage *aOriImage, CGSize aTargetSize, CGFloat aScale)
{
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, aTargetSize.width, aTargetSize.height));
    CGImageRef imageRef = aOriImage.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(aTargetSize, NO, aScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, aTargetSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}

UIImage *tmResizeImage(UIImage *aOriImage, CGSize aTargetSize)
{
    return tmResizeImageWithScale(aOriImage, aTargetSize, 0);
}


UIImage *tmImageWithColor(UIColor *color) {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

void tmResizeBtnSize(UIButton *aBtn, float aWidthBuffer)
{
    CGSize s = tmStringSize(aBtn.titleLabel.text, aBtn.titleLabel.font, MAXFLOAT);
    CGRect f = aBtn.frame;
    f.size.width = MAX(f.size.width, s.width + aWidthBuffer);
    aBtn.frame = f;
}

extern void tmResizeBtnSizeRefRight(UIButton *aBtn, float aWidthBuffer)
{
    CGSize s = tmStringSize(aBtn.titleLabel.text, aBtn.titleLabel.font, MAXFLOAT);
    CGRect f = aBtn.frame;
    CGFloat w = MAX(f.size.width, s.width + aWidthBuffer);
    f.origin.x -= (w - f.size.width);
    f.size.width = w;
    aBtn.frame = f;
}

void tmResetBtnBackgroundImage(UIButton *aBtn, UIEdgeInsets capInsets, UIControlState aForState)
{
    UIImage *image = [aBtn backgroundImageForState:aForState];
    [aBtn setBackgroundImage:[image resizableImageWithCapInsets:capInsets] forState:aForState];
}
