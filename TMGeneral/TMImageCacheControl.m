//
//  TMImageCacheControl.m
//  TMGeneral
//
//  Created by mac on 12/10/14.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import "TMImageCacheControl.h"
#import "TMGeneralDataManager.h"
#import "TMTools.h"

#import "TMImageCache.h"
#import "AFNetworking.h"

#define _PRELOAD_TAG   @"2uh4u3h42@#$2"

@interface _TMICCPreloadItem : NSObject
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, assign) TMImageControl_Type type;
@end

@implementation _TMICCPreloadItem
@end

@interface TMImageCacheControl ()
{
    NSMutableDictionary *_imageViewList;
    NSMutableDictionary *_imageView2ActivyList;
    NSMutableDictionary *_activeList;
    
    NSLock *_lock;
    
    NSInteger _preloadCounter;
    NSMutableArray *_preloadArray;
    id<TMImageCacheControlPreloadProtocol> preloadDelegate;
    
    //
}

@end

@implementation TMImageCacheControl

+ (TMImageCacheControl *) defaultTMImageCacheControl
{
    static dispatch_once_t pred;
	static TMImageCacheControl *sharedInstance = nil;
    
	dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
	return sharedInstance;
}

- (int) finishOnePreloadAndNotify:(NSString *)aTagMD5
{
    _preloadCounter++;
    
    if (preloadDelegate == nil) {
        
    }
    else if (_preloadCounter == [_preloadArray count]) {
        
        if ([preloadDelegate respondsToSelector:@selector(tmImageCacheControl:PreloadFinish:)]) {
            [preloadDelegate tmImageCacheControl:self PreloadFinish:TMImageControl_Preload_Errcode_Success];
        }
        
        preloadDelegate = nil;
    }
    else if (_preloadCounter > [_preloadArray count])
    {
        NSAssert(FALSE, @"_preloadCounter > [_preloadArray count]");
    }
    
    return [_preloadArray count] - _preloadCounter;
}

- (void) executePreload:(id<TMImageCacheControlPreloadProtocol>)aDelegete
{
    if (preloadDelegate != nil) {
        return;
    }
    
    preloadDelegate = aDelegete;
    _preloadCounter = 0;
    
    for (_TMICCPreloadItem *object in _preloadArray) {
        NSString *aTagMD5 = tmStringFromMD5(object.tag);
        
        if (object.type == TMImageControl_Type_NoCache) {
            if (0 == [self finishOnePreloadAndNotify:aTagMD5])
                break;
        }
        
        
        TMImageCache *cacheItem = [self createCacheItemFrom:object.url withTagMD5:aTagMD5 andType:object.type];
        
        if (cacheItem == nil) {
            /// 理論上不可能到這裡
            NSAssert(FALSE, @"there must be a item");
        } else {
            //////// 有圖的話
            ////////// 顯示
            
            if (cacheItem.data != nil) {
                if (object.type == TMImageControl_Type_FirstTime) {
                    /// 已經 有資料了...
                    if (0 == [self finishOnePreloadAndNotify:aTagMD5])
                        break;
                }
                else if (object.type == TMImageControl_Type_UpdateEveryTime) {
                    
                }
            } else {
                
            }
        }
        
        /// 現在這個流程可能會有  沒有讀到資料  可是在一瞬間又有資料
        /// 下面的標記就會失效
        
        // 先找 globle image list 中有沒有這個iv
        [_lock lock];
        //// 有的話
        NSMutableArray *imageviews = [_activeList objectForKey:aTagMD5];
        
        if (imageviews == nil) {
            imageviews = [[NSMutableArray alloc] init];
            [_activeList setObject:imageviews forKey:aTagMD5];
        }
        
        if ([imageviews containsObject:_PRELOAD_TAG]) {
            /// 已經加入preload了....
        } else {
            [imageviews addObject:_PRELOAD_TAG];
        }
        
        [_lock unlock];
        
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:object.url]];
        [request setHTTPShouldHandleCookies:NO];
        [request setHTTPShouldUsePipelining:YES];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        
        __unsafe_unretained TMImageCacheControl *selfItem = self;
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"ImageCache Success : (%d) %@", operation.response.statusCode, object.url);
            
            [[TMGeneralDataManager sharedInstance] imageCache:cacheItem setData:responseObject];
            
            //returnData = [UIImage imageWithData:responseObject];
            
            [selfItem finishAndUpdateImage:cacheItem.data WithTagMD5:cacheItem.tag];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"ImageCache Error (%d) %@ : %@", operation.response.statusCode, object.url, error);
            
            if (self.ImageModifyHTTPErrorWithOptions) {
                UIImage *modifyImage = nil;
                modifyImage = _ImageModifyHTTPErrorWithOptions(modifyImage, @{@"statusCode":[NSNumber numberWithInteger:operation.response.statusCode]});
                [selfItem finishAndUpdateImage:UIImagePNGRepresentation(modifyImage) WithTagMD5:cacheItem.tag];
            } else {
                [selfItem finishAndUpdateImage:nil WithTagMD5:cacheItem.tag];
            }
            
        }];
        
        [operation start];
    }
    
}

- (void) addPreloadImageURL:(NSString *)aURL withTag:(NSString *)aTag andType:(TMImageControl_Type)aType
{
    if (preloadDelegate != nil) {
        return;
    }
    
    if (aTag == nil || [aTag length] == 0) {
        aTag = aURL;
    }
    
    NSAssert(aTag != nil, @"aTag is nil");
    NSAssert([aTag length] > 0, @"[aTag length] == 0");
    //NSAssert(aURL != nil, @"aURL is nil");  ///tag 跟 url 不能同時為空  URL 為空表示不用網路下載
    
    _TMICCPreloadItem *item = [[_TMICCPreloadItem alloc] init];
    item.url = aURL;
    item.tag = aTag;
    item.type = aType;
    
    [_preloadArray addObject:item];
    
    
}

- (void) removeListonImageViews:(NSArray *)aImageViews
{
    for (UIImageView *iv in aImageViews) {
        [self removeListonImageView:iv];
    }
}

- (void) removeListonImageView:(UIImageView *)aImageView
{
    [_lock lock];
    
    NSMutableArray *removekeys = [NSMutableArray array];
    for (NSString *key in [_activeList allKeys]) {
        NSMutableArray *imageviews = [_activeList objectForKey:key];
        if ([imageviews containsObject:aImageView]) {
            [imageviews removeObject:aImageView];
            
            //// 如果這個array沒有資料了 就註記等等要清掉
            if ([imageviews count] == 0) {
                [removekeys addObject:key];
            }
        }
    }
    [_activeList removeObjectsForKeys:removekeys];
    
    NSString *imgKey = tmStringFromMD5([NSString stringWithFormat:@"%p", aImageView]);
    [_imageViewList removeObjectForKey:imgKey];
    [_imageView2ActivyList removeObjectForKey:imgKey];
    
    /// 清掉
    
    [_lock unlock];
}

- (void) setImageURL:(NSString *)aURL toImageView:(UIImageView *)aImageView
{
    [self setImageURL:aURL toImageView:aImageView withTag:nil andType:(TMImageControl_Type_FirstTime)];
}

- (void) setImageURL:(NSString *)aURL toImageView:(UIImageView *)aImageView withTag:(NSString *)aTag
{
    [self setImageURL:aURL toImageView:aImageView withTag:aTag andType:(TMImageControl_Type_FirstTime)];
}

- (void) setImageURL:(NSString *)aURL toImageView:(UIImageView *)aImageView withType:(TMImageControl_Type)aType
{
    [self setImageURL:aURL toImageView:aImageView withTag:nil andType:aType];
}

- (void) setImageURL:(NSString *)aURL
         toImageView:(UIImageView *)aImageView
             withTag:(NSString *)aTag
             andType:(TMImageControl_Type)aType
{
    [self setImageURL:aURL
          toImageView:aImageView
              withTag:aTag
              andType:aType
           andOptions:_defaultOptions];
}

- (void) setImageURL:(NSString *)aURL
         toImageView:(UIImageView *)aImageView
             withTag:(NSString *)aTag
             andType:(TMImageControl_Type)aType
          andOptions:(NSDictionary *)aOptions
{
    if (aTag == nil || [aTag length] == 0) {
        aTag = aURL;
    }
    
    NSAssert(aTag != nil, @"aTag is nil");
    NSAssert([aTag length] > 0, @"[aTag length] == 0");
    //NSAssert(aURL != nil, @"aURL is nil");  ///tag 跟 url 不能同時為空  URL 為空表示不用網路下載
    
    /// 結合default options
    NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithDictionary:_defaultOptions];
    [options addEntriesFromDictionary:aOptions];
    
    NSString *aTagMD5 = tmStringFromMD5(aTag);
    
    
    // 先找 globle image list 中有沒有這個iv
    [_lock lock];
    NSString *imgKey = tmStringFromMD5([NSString stringWithFormat:@"%p", aImageView]);
    NSString *tagMD5 = [_imageViewList objectForKey:imgKey];
    //// 有的話
    ///// 將舊 url -> iv 的連結拿掉
    if (tagMD5 != nil) {
        NSMutableArray *imageviews = [_activeList objectForKey:tagMD5];
        [imageviews removeObject:aImageView];
    }
    
    // 設定 url -> iv的連結
    /// 如果再 _activeList 內 表示正在下載
    /// 但是... 現在的結構下 後來的網址會被捨棄 導致不會拿到最新的
    [_imageViewList setObject:aTagMD5 forKey:imgKey];
    NSMutableArray *imageviews = [_activeList objectForKey:aTagMD5];
    if (imageviews == nil) {
        imageviews = [[NSMutableArray alloc] init];
        [_activeList setObject:imageviews forKey:aTagMD5];
    }
    [imageviews addObject:aImageView];
    [_lock unlock];
    
    
    
    //// 設定圖片
    ////// 從cache 中拿圖 + tag
    TMImageCache *cacheItem = [self createCacheItemFrom:aURL withTagMD5:aTagMD5 andType:aType];
    
    if (cacheItem == nil) {
        /// 理論上不可能到這裡
        NSAssert(FALSE, @"there must be a item");
    } else {
        //////// 有圖的話
        ////////// 顯示
        
        if (cacheItem.data != nil) {
            if (aType == TMImageControl_Type_FirstTime
                || aType == TMImageControl_Type_UpdateEveryTime) {
                
                if (self.ImageModify != nil) {
                    aImageView.image = _ImageModify([UIImage imageWithData:cacheItem.data]);
                } else {
                    aImageView.image = [UIImage imageWithData:cacheItem.data];
                }
            }
            
            UIActivityIndicatorView *aiv = [_imageView2ActivyList objectForKey:imgKey];
            if (aiv != nil) {
                [aiv removeFromSuperview];
                [_imageView2ActivyList removeObjectForKey:imgKey];
            }
            
        } else {
            /// 如果cache沒有圖 看看有沒有 placeholder加入
            UIImage *placeholder = [options objectForKey:TM_IMAGE_CACHE_PLACEHOLDER_IMAGE];
            if (placeholder != nil) {
                if (self.ImageModify != nil) {
                    aImageView.image = _ImageModify(placeholder);
                } else {
                    aImageView.image = placeholder;
                }
            }
            
            if ([[options objectForKey:TM_IMAGE_CACHE_ACTIVITY_INDICATOR] boolValue]) {
                UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhite)];
                aiv.center = CGPointMake(aImageView.frame.size.width / 2, aImageView.frame.size.height / 2);
                [aiv startAnimating];
                [aImageView addSubview:aiv];
                [_imageView2ActivyList setObject:aiv forKey:imgKey];
            }
        }
    }
    
    
    
    
    /// type (檢查type 執行type對應動作)
    if (aType == TMImageControl_Type_FirstTime) {
        if (cacheItem.data == nil) {
            [self getDataFrom:aURL AndSaveIn:cacheItem];
        } else {
            [self finishAndUpdateImage:nil WithTagMD5:cacheItem.tag];
        }
    }
    else if (aType == TMImageControl_Type_UpdateEveryTime) {
        [self getDataFrom:aURL AndSaveIn:cacheItem];
        
    } else {
        /// TMImageControl_Type_NoCache
        /// 實作上"先"使用類似 TMImageControl_Type_UpdateEveryTime 的方法
        /// 只是前面先不拿 cache Image 填入
        [self getDataFrom:aURL AndSaveIn:cacheItem];
    }
    
}

- (void) finishAndUpdateImage:(NSData *)aImageData WithTagMD5:(NSString *)aTagMD5
{
    [_lock lock];
    
    NSMutableArray *imageviews = [_activeList objectForKey:aTagMD5];
    
    UIImage *image = nil;
    
    if (aImageData != nil) {
        image = [UIImage imageWithData:aImageData];
    }
    
    
    for (NSObject *object in imageviews) {
        
        if ([object isKindOfClass:[UIImageView class]]) {
            if (image != nil) {
                if (self.ImageModify != nil) {
                    ((UIImageView *)object).image = _ImageModify(image);
                } else {
                    ((UIImageView *)object).image = image;
                }
            }
            NSString *imgKey = tmStringFromMD5([NSString stringWithFormat:@"%p", object]);
            [_imageViewList removeObjectForKey:imgKey];
            
            UIActivityIndicatorView *aiv = [_imageView2ActivyList objectForKey:imgKey];
            if (aiv != nil) {
                [aiv removeFromSuperview];
                [_imageView2ActivyList removeObjectForKey:imgKey];
            }
        }
        else if ([object isKindOfClass:[NSString class]]) {
            if ([((NSString *)object) isEqualToString:_PRELOAD_TAG] ) {
                //// preload 的部份需要通知已經下載了
                [self finishOnePreloadAndNotify:aTagMD5];
            }
        }
        
    }
    
    /// 清掉
    [_activeList removeObjectForKey:aTagMD5];
    
    
    [_lock unlock];
}

- (void) getDataFrom:(NSString *)aUrl AndSaveIn:(TMImageCache *)aItem
{
    if (aUrl == nil || [aUrl length] == 0) {
        
        [self finishAndUpdateImage:nil WithTagMD5:aItem.tag];
        
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:aUrl]];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPShouldUsePipelining:YES];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    __unsafe_unretained TMImageCacheControl *selfItem = self;
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"ImageCache Success : (%d) %@", operation.response.statusCode, aUrl);
        
        
        [[TMGeneralDataManager sharedInstance] imageCache:aItem setData:responseObject];
        
        //returnData = [UIImage imageWithData:responseObject];
        
        [selfItem finishAndUpdateImage:aItem.data WithTagMD5:aItem.tag];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ImageCache Error (%d) %@ : %@", operation.response.statusCode, aUrl, error);
        
        if (self.ImageModifyHTTPErrorWithOptions) {
            UIImage *modifyImage = nil;
            modifyImage = _ImageModifyHTTPErrorWithOptions(modifyImage, @{@"statusCode":[NSNumber numberWithInteger:operation.response.statusCode]});
            [selfItem finishAndUpdateImage:UIImagePNGRepresentation(modifyImage) WithTagMD5:aItem.tag];
        } else {
            [selfItem finishAndUpdateImage:nil WithTagMD5:aItem.tag];
        }
    }];
    
    [operation start];
    //[operation waitUntilFinished];   ///
}

- (TMImageCache *) createCacheItemFrom:(NSString *)aUrl withTagMD5:(NSString *)aTagMD5 andType:(TMImageControl_Type)aType
{
    return [[TMGeneralDataManager sharedInstance] createImageCacheFrom:aUrl withTagMD5:aTagMD5 andType:aType];
}

- (id)init
{
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        _imageViewList = [[NSMutableDictionary alloc] init];
        _imageView2ActivyList = [[NSMutableDictionary alloc] init];
        _activeList = [[NSMutableDictionary alloc] init];
        _preloadArray = [[NSMutableArray alloc] init];
    }
    return self;
}



@end
