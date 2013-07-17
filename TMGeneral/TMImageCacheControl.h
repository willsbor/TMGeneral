/*
 TMImageCacheControl.h
 
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

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define TM_IMAGE_CACHE_PLACEHOLDER_IMAGE   @"com.thinkermobile.image_cache.placeholder"
#define TM_IMAGE_CACHE_ACTIVITY_INDICATOR  @"com.thinkermobile.image_cache.activityindicator"

#define TM_IMAGE_CACHE_NOTIFY_PRELOAD_FINISH   @"com.thinkermobile.image_cache.preload_finish"

#define TM_IMAGE_CACHE_ERR_USERINFO_SERVER_ERROR_KEY @"ServerError"
#define TM_IMAGE_CACHE_ERR_USERINFO_STATUS_CODE_KEY  @"ServerStatusCode"

typedef enum
{
    TMImageControl_Type_NoCache,  ///< 不做 cache
    TMImageControl_Type_FirstTime,   ///< 只有第一次抓資料 後面舊不更新了
    TMImageControl_Type_UpdateEveryTime,   ///< 每次都會先回傳cache資料 然後並且抓到新的資料後cache且更新
} TMImageControl_Type;

typedef enum
{
    TMImageControl_Errcode_Success,
    TMImageControl_Errcode_Failed,
    TMImageControl_Errcode_No_Downlaod_URL,
    TMImageControl_Errcode_ServerError,
} TMImageControl_Errcode;

typedef UIImage* (^TMICImageModify)(UIImage *, NSError *);

@class TMImageCacheControl;
@class AFHTTPRequestOperation;
@protocol TMImageCacheControlPreloadProtocol <NSObject>

@optional
- (void) tmImageCacheControl:(TMImageCacheControl *)aControl PreloadFinish:(int)aErrcode;

@end

@interface TMImageCacheControl : NSObject

@property (nonatomic, strong) NSDictionary *defaultOptions;
@property (nonatomic, strong) TMICImageModify ImageModify;    ///< 圖片擷取後 （不論從網路還是cache）皆會經過此block做圖片修改 (修改圖片不會存入cache)

+ (TMImageCacheControl *) defaultTMImageCacheControl;

//// for TMViewController
- (void) removeListonImageViews:(NSArray *)aImageViews;
- (void) removeListonImageView:(UIImageView *)aImageView;


- (void) setImageURL:(NSString *)aURL toImageView:(UIImageView *)aImageView;
- (void) setImageURL:(NSString *)aURL toImageView:(UIImageView *)aImageView withTag:(NSString *)aTag;
- (void) setImageURL:(NSString *)aURL toImageView:(UIImageView *)aImageView withType:(TMImageControl_Type)aType;
- (void) setImageURL:(NSString *)aURL toImageView:(UIImageView *)aImageView withTag:(NSString *)aTag andType:(TMImageControl_Type)aType;
- (void) setImageURL:(NSString *)aURL
         toImageView:(UIImageView *)aImageView
             withTag:(NSString *)aTag
             andType:(TMImageControl_Type)aType
          andOptions:(NSDictionary *)aOptions;

- (AFHTTPRequestOperation *) setImageOperationByImageURL:(NSString *)aURL withTag:(NSString *)aTag andType:(TMImageControl_Type)aType toComplete:(void (^)(UIImage *aImage, NSError *error))aComplete;

/**
 * 下面為擷取一個網址的圖片，結果會引到block，但是存取中的重複讀取(time issue) 尚未做最佳化與處理
 * 並且沒有影響到上面to Image的function
 */
- (void) setImageURL:(NSString *)aURL toComplete:(void (^)(UIImage *aImage, NSError *error))aComplete;
- (void) setImageURL:(NSString *)aURL withTag:(NSString *)aTag toComplete:(void (^)(UIImage *aImage, NSError *error))aComplete;
- (void) setImageURL:(NSString *)aURL withType:(TMImageControl_Type)aType toComplete:(void (^)(UIImage *aImage, NSError *error))aComplete;
- (void) setImageURL:(NSString *)aURL withTag:(NSString *)aTag andType:(TMImageControl_Type)aType toComplete:(void (^)(UIImage *aImage, NSError *error))aComplete;

/// public
- (void) addPreloadImageURL:(NSString *)aURL withTag:(NSString *)aTag andType:(TMImageControl_Type)aType;
- (void) executePreload:(id<TMImageCacheControlPreloadProtocol>)aDelegete;


@end
