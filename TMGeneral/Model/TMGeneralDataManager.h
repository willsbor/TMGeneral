//
//  TMGeneralDataManager.h
//  TMGeneral
//
//  Created by willsborKang on 12/12/19.
//  Copyright (c) 2012年 thinkermobile. All rights reserved.
//

#import "TMDataManager.h"
#import "TMImageCacheControl.h"

@class TMApiData;
@interface TMGeneralDataManager : TMDataManager

+ (TMGeneralDataManager *)sharedInstance;

- (NSString *) createTMApiDataWith:(void (^)(TMApiData *apidata))aSetting;
- (void) changeApiData:(NSString *)aIdentify With:(void (^)(TMApiData *apidata))aSetting;
- (void) changeApiData:(NSString *)aIdentify Status:(NSInteger) aState;
- (void) changeApiData:(NSString *)aIdentify CacheType:(NSInteger)aCacheType;
- (void) changeApiData:(NSString *)aIdentify RetryTimes:(NSInteger)aRetryTimes;
- (void) changeApiData:(NSString *)aIdentify RetryDelayTimes:(double)aRetryDelayTimes;

- (id) returnObjectByKey:(NSString *)aKey OfIdentify:(NSString *)aIdentify;

//- (TMApiData *) getTMApiDataOnMainByID:(NSString *)aIdentify;

- (NSString *) createImageCacheWithTagMD5:(NSString *)aTagMD5 andType:(TMImageControl_Type)aType;
- (void) imageCache:(NSString *)aTagMD5 setData:(NSData *)aImageData;
- (NSData *) imageCacheImageDataByTag:(NSString *)aTagMD5;
- (BOOL) isHaveImageDataByTag:(NSString *)aTagMD5;

- (void) switchAPIDataStateFromInvalidDoing2Pending:(BOOL (^)(NSString *identify))isIdentifyInTempList;
- (void) switchAPIDataStateFromInvalid2Stop;
- (void) removeAllFinishAPIData;
- (void) _checkAPIAction:(void (^)(TMApiData *object))aActionBlock;

@end
