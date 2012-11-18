//
//  TMImageCacheControl.h
//  TMGeneral
//
//  Created by mac on 12/10/14.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define TM_IMAGE_CACHE_PLACEHOLDER_IMAGE   @"com.thinkermobile.image_cache.placeholder"

#define TM_IMAGE_CACHE_NOTIFY_PRELOAD_FINISH   @"com.thinkermobile.image_cache.preload_finish"

typedef enum
{
    TMImageControl_Type_NoCache,  ///< 不做 cache
    TMImageControl_Type_FirstTime,   ///< 只有第一次抓資料 後面舊不更新了
    TMImageControl_Type_UpdateEveryTime,   ///< 每次都會先回傳cache資料 然後並且抓到新的資料後cache且更新
} TMImageControl_Type;

typedef enum
{
    TMImageControl_Preload_Errcode_Success,
    TMImageControl_Preload_Errcode_Failed,
} TMImageControl_Preload_Errcode;

@class TMImageCacheControl;
@protocol TMImageCacheControlPreloadProtocol <NSObject>

@optional
- (void) tmImageCacheControl:(TMImageCacheControl *)aControl PreloadFinish:(int)aErrcode;

@end

@interface TMImageCacheControl : NSObject

@property (nonatomic, retain) NSDictionary *defaultOptions;

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

/// public
- (void) addPreloadImageURL:(NSString *)aURL withTag:(NSString *)aTag andType:(TMImageControl_Type)aType;
- (void) executePreload:(id<TMImageCacheControlPreloadProtocol>)aDelegete;

@end
