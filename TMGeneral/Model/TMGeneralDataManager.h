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
@class TMImageCache;
@interface TMGeneralDataManager : TMDataManager

@property (nonatomic, readonly, strong) NSMutableArray *apiIdentifyList;

+ (TMGeneralDataManager *)sharedInstance;

- (void) switchAPIDataStateFromInvalidDoing2Pending;
- (void) switchAPIDataStateFromInvalid2Stop;

- (void) startCheckCacheAPI;
- (void) stopCheckCacheAPI;

- (void) removeAllFinishAPIData;

- (TMApiData *) createTMApiData;
- (void) changeApiData:(TMApiData *)aData Status:(NSInteger) aState;
- (void) changeApiData:(TMApiData *)aData CacheType:(NSInteger)aCacheType;
- (void) changeApiData:(TMApiData *)aData RetryTimes:(NSInteger)aRetryTimes;
- (void) changeApiData:(TMApiData *)aData RetryDelayTimes:(double)aRetryDelayTimes;

- (TMImageCache *) createImageCacheFrom:(NSString *)aUrl withTagMD5:(NSString *)aTagMD5 andType:(TMImageControl_Type)aType;
- (void) imageCache:(TMImageCache *)aImageCache setData:(NSData *)aImageData;


@end
