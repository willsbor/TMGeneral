/*
 TMImageCacheControl.m
 
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

#import "TMImageCacheControl.h"
#import "TMGeneralDataManager.h"
#import "TMTools.h"

#import <AFNetworking/AFNetworking.h>

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

@property (nonatomic, strong) void (^getDataSuccess)(AFHTTPRequestOperation *operation, id responseObject);
@property (nonatomic, strong) void (^getDataFailure)(AFHTTPRequestOperation *operation, NSError *error);

@end

@implementation TMImageCacheControl

+ (TMImageCacheControl *) defaultTMImageCacheControl
{
    static dispatch_once_t pred;
	static TMImageCacheControl *sharedInstance = nil;
    
	dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
	return sharedInstance;
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
            if (0 == [self _finishOnePreloadAndNotify:aTagMD5])
                break;
        }
        
        
        NSString *cacheItem = [self _createCacheItemFrom:object.url withTagMD5:aTagMD5 andType:object.type];
        
        if (cacheItem == nil) {
            /// 理論上不可能到這裡
            NSAssert(FALSE, @"there must be a item");
        } else {
            //////// 有圖的話
            ////////// 顯示
            
            if ([[TMGeneralDataManager sharedInstance] isHaveImageDataByTag:cacheItem]) {
                if (object.type == TMImageControl_Type_FirstTime) {
                    /// 已經 有資料了...
                    if (0 == [self _finishOnePreloadAndNotify:aTagMD5])
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
        

        __weak TMImageCacheControl *selfItem = self;
        void (^getDataFinishBlock)(NSData *aImageNSData, NSError *error) = ^(NSData *aImageNSData, NSError *error) {
            if (error == nil) {
                UIImage *image = [UIImage imageWithData:aImageNSData];
                if (_ImageModify) image = _ImageModify(image, nil);
                [selfItem _finishAndUpdateImage:image WithTagMD5:cacheItem];
            } else {
                if (_ImageModify) {
                    [selfItem _finishAndUpdateImage:_ImageModify(nil, error) WithTagMD5:cacheItem];
                } else {
                    [selfItem _finishAndUpdateImage:nil WithTagMD5:cacheItem];
                }
            }
        };
        
        [self _getDataFrom:object.url AndSaveIn:cacheItem toComplete:getDataFinishBlock];
    }
    
}

- (void) addPreloadImageURL:(NSString *)aURL withTag:(NSString *)aTag andType:(TMImageControl_Type)aType
{
    if (preloadDelegate != nil) {
        return;
    }
    
    _TMICCPreloadItem *item = [[_TMICCPreloadItem alloc] init];
    item.url = aURL;
    item.tag = [self _tagByInputTag:aTag andInputUrl:aURL];
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
    
    
    /// 結合default options
    NSMutableDictionary *options = [[NSMutableDictionary alloc] initWithDictionary:_defaultOptions];
    [options addEntriesFromDictionary:aOptions];
    
    NSString *aTagMD5 = tmStringFromMD5([self _tagByInputTag:aTag andInputUrl:aURL]);
    
    
    // 先找 globle image list 中有沒有這個iv
    [_lock lock];
    NSString *imgKey = tmStringFromMD5([NSString stringWithFormat:@"%p", aImageView]);
    NSString *tagMD5 = [_imageViewList objectForKey:imgKey];
    //// 有的話
    ///// 將舊 url -> iv 的連結拿掉
    if (tagMD5 != nil) {
        NSMutableArray *imageviews = [_activeList objectForKey:tagMD5];
        if (aImageView) [imageviews removeObject:aImageView];
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
    if (aImageView) [imageviews addObject:aImageView];
    [_lock unlock];
    
    
    
    //// 設定圖片
    ////// 從cache 中拿圖 + tag
    NSString *cacheItem = [self _createCacheItemFrom:aURL withTagMD5:aTagMD5 andType:aType];
    
    if (cacheItem == nil) {
        /// 理論上不可能到這裡
        NSAssert(FALSE, @"there must be a item");
    } else {
        //////// 有圖的話
        ////////// 顯示
        
        if ([[TMGeneralDataManager sharedInstance] isHaveImageDataByTag:cacheItem]) {
            if (aType == TMImageControl_Type_FirstTime
                || aType == TMImageControl_Type_UpdateEveryTime) {
                
                NSData *imageData = [[TMGeneralDataManager sharedInstance] imageCacheImageDataByTag:cacheItem];
                if (self.ImageModify != nil) {
                    aImageView.image = _ImageModify([UIImage imageWithData:imageData], nil);
                } else {
                    aImageView.image = [UIImage imageWithData:imageData];
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
                    aImageView.image = _ImageModify(placeholder, nil);
                } else {
                    aImageView.image = placeholder;
                }
            }
            
            if (aImageView && [[options objectForKey:TM_IMAGE_CACHE_ACTIVITY_INDICATOR] boolValue]) {
                UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhite)];
                aiv.center = CGPointMake(aImageView.frame.size.width / 2, aImageView.frame.size.height / 2);
                [aiv startAnimating];
                [aImageView addSubview:aiv];
                [_imageView2ActivyList setObject:aiv forKey:imgKey];
            }
        }
    }
    
    
    
    
    /// type (檢查type 執行type對應動作)
    __weak TMImageCacheControl *selfItem = self;
    void (^getDataFinishBlock)(NSData *aImageNSData, NSError *error) = ^(NSData *aImageNSData, NSError *error) {
        if (error == nil) {
            UIImage *image = [UIImage imageWithData:aImageNSData];
            if (_ImageModify) image = _ImageModify(image, nil);
            [selfItem _finishAndUpdateImage:image WithTagMD5:cacheItem];
        } else {
            if (_ImageModify) {
                [selfItem _finishAndUpdateImage:_ImageModify(nil, error) WithTagMD5:cacheItem];
            } else {
                [selfItem _finishAndUpdateImage:nil WithTagMD5:cacheItem];
            }
        }
    };
    
    
    if (aType == TMImageControl_Type_FirstTime) {
        if (NO == [[TMGeneralDataManager sharedInstance] isHaveImageDataByTag:cacheItem]) {
            
            [self _getDataFrom:aURL AndSaveIn:cacheItem toComplete:getDataFinishBlock];
        } else {
            //[self finishAndUpdateImage:nil WithTagMD5:cacheItemTag];
            getDataFinishBlock(nil, nil);
        }
    }
    else if (aType == TMImageControl_Type_UpdateEveryTime) {
        [self _getDataFrom:aURL AndSaveIn:cacheItem toComplete:getDataFinishBlock];
        
    } else {
        /// TMImageControl_Type_NoCache
        /// 實作上"先"使用類似 TMImageControl_Type_UpdateEveryTime 的方法
        /// 只是前面先不拿 cache Image 填入
        [self _getDataFrom:aURL AndSaveIn:cacheItem toComplete:getDataFinishBlock];
    }
    
}

- (void) setImageURL:(NSString *)aURL toComplete:(void (^)(UIImage *aImage, NSError *error))aComplete
{
    [self setImageURL:aURL withTag:nil andType:(TMImageControl_Type_FirstTime) toComplete:aComplete];
}
- (void) setImageURL:(NSString *)aURL withTag:(NSString *)aTag toComplete:(void (^)(UIImage *aImage, NSError *error))aComplete;
{
    [self setImageURL:aURL withTag:aTag andType:(TMImageControl_Type_FirstTime) toComplete:aComplete];
}
- (void) setImageURL:(NSString *)aURL withType:(TMImageControl_Type)aType toComplete:(void (^)(UIImage *aImage, NSError *error))aComplete
{
    [self setImageURL:aURL withTag:nil andType:aType toComplete:aComplete];
}

- (void) setImageURL:(NSString *)aURL withTag:(NSString *)aTag andType:(TMImageControl_Type)aType toComplete:(void (^)(UIImage *aImage, NSError *error))aComplete
{
    NSString *aTagMD5 = tmStringFromMD5([self _tagByInputTag:aTag andInputUrl:aURL]);
    
    NSString *cacheItem = [self _createCacheItemFrom:aURL withTagMD5:aTagMD5 andType:aType];
    
    
    void (^getDataFinishBlock)(NSData *aImageNSData, NSError *error) = ^(NSData *aImageNSData, NSError *error) {
        UIImage *resultI = [UIImage imageWithData:aImageNSData];
        if (self.ImageModify != nil) resultI = _ImageModify(resultI, error);
        if (aComplete) aComplete(resultI, error);
    };
    
    if (cacheItem == nil) {
        /// 理論上不可能到這裡
        NSAssert(FALSE, @"there must be a item");
    } else {
        //////// 有圖的話
        ////////// 顯示
        
        if ([[TMGeneralDataManager sharedInstance] isHaveImageDataByTag:cacheItem]) {
            if (aType == TMImageControl_Type_FirstTime
                || aType == TMImageControl_Type_UpdateEveryTime) {
                NSData *imageData = [[TMGeneralDataManager sharedInstance] imageCacheImageDataByTag:cacheItem];
                getDataFinishBlock(imageData, nil);
            }
        }
    }
    
    if (aType == TMImageControl_Type_UpdateEveryTime
        || aType == TMImageControl_Type_NoCache
        || (aType == TMImageControl_Type_FirstTime && NO == [[TMGeneralDataManager sharedInstance] isHaveImageDataByTag:cacheItem])) {
        [self _getDataFrom:aURL AndSaveIn:cacheItem toComplete:getDataFinishBlock];
    }
    
    
}

- (AFHTTPRequestOperation *) setImageOperationByImageURL:(NSString *)aURL withTag:(NSString *)aTag andType:(TMImageControl_Type)aType toComplete:(void (^)(UIImage *aImage, NSError *error))aComplete
{
    NSString *aTagMD5 = tmStringFromMD5([self _tagByInputTag:aTag andInputUrl:aURL]);
    
    NSString *cacheItemTag = [self _createCacheItemFrom:aURL withTagMD5:aTagMD5 andType:aType];
    
    
    void (^getDataFinishBlock)(NSData *aImageNSData, NSError *error) = ^(NSData *aImageNSData, NSError *error) {
        UIImage *resultI = [UIImage imageWithData:aImageNSData];
        if (self.ImageModify != nil) resultI = _ImageModify(resultI, error);
        if (aComplete) aComplete(resultI, error);
    };
    
    if (cacheItemTag == nil) {
        /// 理論上不可能到這裡
        NSAssert(FALSE, @"there must be a item");
    } else {
        //////// 有圖的話
        ////////// 顯示
        
        if ([[TMGeneralDataManager sharedInstance] isHaveImageDataByTag:cacheItemTag]) {
            if (aType == TMImageControl_Type_FirstTime
                || aType == TMImageControl_Type_UpdateEveryTime) {
                NSData *imageData = [[TMGeneralDataManager sharedInstance] imageCacheImageDataByTag:cacheItemTag];
                dispatch_async(dispatch_get_main_queue(), ^{
                    getDataFinishBlock(imageData, nil);
                });
                return nil;
            }
        }
    }
    
    if (aType == TMImageControl_Type_UpdateEveryTime
        || aType == TMImageControl_Type_NoCache
        || (aType == TMImageControl_Type_FirstTime && NO == [[TMGeneralDataManager sharedInstance] isHaveImageDataByTag:cacheItemTag])) {
        
        if (aURL == nil || [aURL length] == 0) {
            
            //[self finishAndUpdateImage:nil WithTagMD5:aItem.tag];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (aComplete) aComplete(nil, [self _errorURLisNil]);
            });
            return nil;
        }
        
        AFHTTPRequestOperation *operation = [self _getOperationFrom:aURL AndSaveIn:cacheItemTag toComplete:getDataFinishBlock];
        
        return operation;
    }
    
    return nil;
}

#pragma mark - private

- (NSString *) _tagByInputTag:(NSString *)aTag andInputUrl:(NSString *)aURL
{
    if (aTag == nil || [aTag length] == 0) {
        aTag = aURL;
    }
    
    NSAssert(aTag != nil, @"aTag is nil");
    NSAssert([aTag length] > 0, @"[aTag length] == 0");
    
    return aTag;
}

- (void) _finishAndUpdateImage:(UIImage *)aImageData WithTagMD5:(NSString *)aTagMD5
{
    [_lock lock];
    
    NSMutableArray *imageviews = [_activeList objectForKey:aTagMD5];
    
    for (NSObject *object in imageviews) {
        
        if ([object isKindOfClass:[UIImageView class]]) {
            if (aImageData != nil) {
                ((UIImageView *)object).image = aImageData;
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
                [self _finishOnePreloadAndNotify:aTagMD5];
            }
        }
        
    }
    
    /// 清掉
    [_activeList removeObjectForKey:aTagMD5];
    
    
    [_lock unlock];
}

- (NSError *) _errorURLisNil
{
    __autoreleasing NSError *error = [[NSError alloc] initWithDomain:NSStringFromClass([self class]) code:TMImageControl_Errcode_No_Downlaod_URL userInfo:nil];
    return error;
}

- (NSError *) _errorServerErrorWithCode:(NSError *)aServerError andStatusCode:(NSInteger)aStatusCode
{
    __autoreleasing NSError *error = [[NSError alloc] initWithDomain:NSStringFromClass([self class]) code:TMImageControl_Errcode_ServerError userInfo:@{TM_IMAGE_CACHE_ERR_USERINFO_SERVER_ERROR_KEY: aServerError, TM_IMAGE_CACHE_ERR_USERINFO_STATUS_CODE_KEY:[NSNumber numberWithInteger:aStatusCode]}];
    return error;
}

- (AFHTTPRequestOperation *) _getOperationFrom:(NSString *)aUrl AndSaveIn:(NSString *)aItemTag toComplete:(void (^)(NSData *aImageNSData, NSError *error))aComplete
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:aUrl]];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPShouldUsePipelining:YES];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[TMGeneralDataManager sharedInstance] imageCache:aItemTag setData:responseObject];
        NSData *imageData = [[TMGeneralDataManager sharedInstance] imageCacheImageDataByTag:aItemTag];
        if (aComplete) aComplete(imageData, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (aComplete) aComplete(nil, [self _errorServerErrorWithCode:error andStatusCode:operation.response.statusCode]);
    }];
    
    return operation;
}

- (void) _getDataFrom:(NSString *)aUrl AndSaveIn:(NSString *)aItemTag toComplete:(void (^)(NSData *aImageNSData, NSError *error))aComplete
{
    if (aUrl == nil || [aUrl length] == 0) {
        
        //[self finishAndUpdateImage:nil WithTagMD5:aItem.tag];
        if (aComplete) aComplete(nil, [self _errorURLisNil]);
        return;
    }
    
    AFHTTPRequestOperation *operation = [self _getOperationFrom:aUrl AndSaveIn:aItemTag toComplete:aComplete];
    [operation start];
}

- (NSString *) _createCacheItemFrom:(NSString *)aUrl withTagMD5:(NSString *)aTagMD5 andType:(TMImageControl_Type)aType
{
    NSString *tag = [[TMGeneralDataManager sharedInstance] createImageCacheWithTagMD5:aTagMD5 andType:aType];
    
    return tag;
}

- (int) _finishOnePreloadAndNotify:(NSString *)aTagMD5
{
    _preloadCounter++;
    
    if (preloadDelegate == nil) {
        
    }
    else if (_preloadCounter == [_preloadArray count]) {
        
        if ([preloadDelegate respondsToSelector:@selector(tmImageCacheControl:PreloadFinish:)]) {
            [preloadDelegate tmImageCacheControl:self PreloadFinish:TMImageControl_Errcode_Success];
        }
        
        preloadDelegate = nil;
    }
    else if (_preloadCounter > [_preloadArray count])
    {
        NSAssert(FALSE, @"_preloadCounter > [_preloadArray count]");
    }
    
    return [_preloadArray count] - _preloadCounter;
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
        
        /*
        self.getDataSuccess = ^(AFHTTPRequestOperation *operation, id responseObject) {
            [[TMGeneralDataManager sharedInstance] imageCache:aItem setData:responseObject];
            if (aComplete) aComplete(aItem.data, nil);
        };
        */
        
    }
    return self;
}



@end
