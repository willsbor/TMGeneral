//
//  TMGeneralDataManager.m
//  TMGeneral
//
//  Created by willsborKang on 12/12/19.
//  Copyright (c) 2012年 thinkermobile. All rights reserved.
//

#import "TMGeneralDataManager.h"
#import "TMDataManager+Protected.h"
#import "TMApiData+Plus.h"
#import "TMImageCache.h"

#import "TMTools.h"

@implementation TMGeneralDataManager

static TMGeneralDataManager *sharedInstance;

+ (TMGeneralDataManager *)sharedInstance
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		sharedInstance = [[TMGeneralDataManager alloc] initWithDatabaseFilename:nil];
        [sharedInstance setSaveThreshold:10]; ///for test
	});
	
	return sharedInstance;
}

- (NSString *)managedObjectModelName
{
    return @"TMGeneralDataModel";
}

#pragma mark -

- (NSString *) createTMApiDataWith:(void (^)(TMApiData *apidata))aSetting
{
    __block NSString *_itemID;
    /// 創造一個新的資料物件
    [self executeBlock:^{
        NSManagedObjectContext *manaedObjectContext = self.managedObjectContext;
        TMApiData *_actionItem = [NSEntityDescription insertNewObjectForEntityForName:@"TMApiData"
                                                    inManagedObjectContext:manaedObjectContext];
        
        _actionItem.objectName = NSStringFromClass([self class]);   ///< 返回執行時要啟動的 object
        //NSLog(@"TMAPIModel save in DB and target class [inside] : %@", _actionItem.objectName);
        _actionItem.createTime = _actionItem.lastActionTime = [NSDate date];
        _actionItem.identify = tmStringFromMD5([NSString stringWithFormat:@"%f", [_actionItem.createTime timeIntervalSince1970]]);
        
        _actionItem.retryDelayTime = @TMAPIMODEL_DEFAULT_RETRY_DELAY_TIME;
        _actionItem.type = [NSNumber numberWithInt:TMAPI_Type_General];
        _actionItem.cacheType = [NSNumber numberWithInt:TMAPI_Cache_Type_None];
        _actionItem.state = [NSNumber numberWithInt:TMAPI_State_Init];
        _actionItem.retryTimes = @3;
        _actionItem.mode = [NSNumber numberWithInt:TMAPI_Mode_Leave_With_Cancel];
        
        if (aSetting) aSetting(_actionItem);
        
        //[self save];
        _itemID = [_actionItem.identify copy];
        
        [self save];
    }];
    
    return _itemID;
}

- (void) changeApiData:(NSString *)aIdentify With:(void (^)(TMApiData *apidata))aSetting
{
    [self executeBlock:^{
         TMApiData *aData = [self _getApiDataByIdentify:aIdentify];
        aSetting(aData);
    }];
}

- (void) changeApiData:(NSString *)aIdentify Status:(NSInteger) aState
{
    [self changeApiData:aIdentify With:^(TMApiData *apidata) {
        apidata.state = [NSNumber numberWithInteger:aState];
    }];
}

- (void) changeApiData:(NSString *)aIdentify CacheType:(NSInteger)aCacheType
{
    [self changeApiData:aIdentify With:^(TMApiData *apidata) {
        apidata.cacheType = [NSNumber numberWithInteger:aCacheType];
    }];
}

- (void) changeApiData:(NSString *)aIdentify RetryTimes:(NSInteger)aRetryTimes
{
    [self changeApiData:aIdentify With:^(TMApiData *apidata) {
        apidata.retryTimes = [NSNumber numberWithInteger:aRetryTimes];
    }];
}

- (void) changeApiData:(NSString *)aIdentify  RetryDelayTimes:(double)aRetryDelayTimes
{
    [self changeApiData:aIdentify With:^(TMApiData *apidata) {
        apidata.retryDelayTime = [NSNumber numberWithDouble:aRetryDelayTimes];
    }];
}

- (id) returnObjectByKey:(NSString *)aKey OfIdentify:(NSString *)aIdentify
{
    __block id result = nil;
    [self executeBlock:^{
        TMApiData *api = [self _getApiDataByIdentify:aIdentify];
        
        result = [[api valueForKey:aKey] copy];
    }];
    
    return result;
}

/// FAILED FUNCTION
- (TMApiData *) getTMApiDataOnMainByID:(NSString *)aIdentify
{
    NSManagedObjectContext *manaedObjectContext = self.mainThreadManagedObjectContext;
    NSFetchRequest *fetchReq = [[NSFetchRequest alloc]init];
    [fetchReq setEntity:[NSEntityDescription entityForName:@"TMApiData" inManagedObjectContext:manaedObjectContext]];
    [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"identify == %@", aIdentify]];
    
    NSArray *resultArray = [manaedObjectContext executeFetchRequest:fetchReq error:nil];
    
    TMApiData *result = nil;
    if ([resultArray count] == 1) {
        result = [resultArray objectAtIndex:0];
    }
    else if ([resultArray count] == 0) {
        
    } else {
        assert(@"重複");
    }
    
    return result;
}

- (NSString *) createImageCacheWithTagMD5:(NSString *)aTagMD5 andType:(TMImageControl_Type)aType
{
    __block NSString *tag = nil;
    [self executeBlock:^{
        TMImageCache *_actionItem = [self _imageCacheByTag:aTagMD5];
        if (_actionItem) {

        } else {
            ///   == nil
            NSManagedObjectContext *manaedObjectContext = self.managedObjectContext;
            _actionItem = [NSEntityDescription insertNewObjectForEntityForName:@"TMImageCache"
                                                        inManagedObjectContext:manaedObjectContext];
            _actionItem.tag = aTagMD5;
            _actionItem.identify = tmStringFromMD5([NSString stringWithFormat:@"%@%f", aTagMD5, [[NSDate date] timeIntervalSince1970]]);
            _actionItem.type = [NSNumber numberWithInt:aType];
            
            [self save];
        }
        
        tag = _actionItem.tag;
    }];
    
    return tag;
}

- (NSData *) imageCacheImageDataByTag:(NSString *)aTagMD5
{
    __block NSData *imageData = nil;
    [self executeBlock:^{
        
        NSManagedObjectContext *manaedObjectContext = self.managedObjectContext;
        NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
        [fetchReq setEntity:[NSEntityDescription entityForName:@"TMImageCache"
                                        inManagedObjectContext:manaedObjectContext]];
        
        [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"tag == %@", aTagMD5]];
        
        NSArray *resultArray = [manaedObjectContext executeFetchRequest:fetchReq error:nil];
        
        TMImageCache *_actionItem = nil;
        if ([resultArray count] == 1) {
            _actionItem = [resultArray objectAtIndex:0];
            
            imageData = [_actionItem.data copy];
        } else if ([resultArray count] == 0) {
            
        } else {
            assert(@"重複");
        }
        
        [self save];
    }];
    
    return imageData;
}

- (void) imageCache:(NSString *)aTagMD5 setData:(NSData *)aImageData
{
    [self executeBlock:^{

        TMImageCache *_actionItem = [self _imageCacheByTag:aTagMD5];
        if (_actionItem) {
            _actionItem.data = aImageData;
            _actionItem.lastDate = [NSDate date];
            
            [self save];
        } 

    }];
}

- (BOOL) isHaveImageDataByTag:(NSString *)aTagMD5
{
    __block BOOL have = NO;
    [self executeBlock:^{
        
        TMImageCache *_actionItem = [self _imageCacheByTag:aTagMD5];
        if (_actionItem) {
            if (_actionItem.data) {
                have = YES;
            }
        }
        
    }];
    
    return have;
}

#pragma mark - private

- (TMApiData *) _getApiDataByIdentify:(NSString *)aIdentify
{
    
    NSManagedObjectContext *manaedObjectContext = self.managedObjectContext;
    NSFetchRequest *fetchReq = [[NSFetchRequest alloc]init];
    [fetchReq setEntity:[NSEntityDescription entityForName:@"TMApiData" inManagedObjectContext:manaedObjectContext]];
    [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"identify == %@", aIdentify]];
    
    NSArray *resultArray = [manaedObjectContext executeFetchRequest:fetchReq error:nil];
    
    TMApiData *result = nil;
    if ([resultArray count] == 1) {
        result = [resultArray objectAtIndex:0];
    }
    else if ([resultArray count] == 0) {
        
    } else {
        assert(@"重複");
    }
    
    return result;
}

- (TMImageCache *) _imageCacheByTag:(NSString *)aTagMD5
{
    TMImageCache *_actionItem = nil;
    NSManagedObjectContext *manaedObjectContext = self.managedObjectContext;
    NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
    [fetchReq setEntity:[NSEntityDescription entityForName:@"TMImageCache"
                                    inManagedObjectContext:manaedObjectContext]];
    
    [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"tag == %@", aTagMD5]];
    
    NSArray *resultArray = [manaedObjectContext executeFetchRequest:fetchReq error:nil];
    
    if ([resultArray count] == 1) {
        _actionItem = [resultArray objectAtIndex:0];
    } else if ([resultArray count] == 0) {
        
    } else {
        assert(@"重複");
    }
    
    return _actionItem;
}



#pragma mark - 

- (void) switchAPIDataStateFromInvalidDoing2Pending:(BOOL (^)(NSString *identify))isIdentifyInTempList
{
    /// 將 不在執行列表中的物件 且 cachetype 是 TMAPI_Cache_Type_EveryActive
    /// 狀態如果是doing 就轉換成 pending  (先不包含 TMAPI_State_Init)
    
    /// 因為程式有可能中途被強制中段 導致 DB內的狀態還停留在doing
    /// 但是要保證 TMAPI_Cache_Type_EveryActive 能被送出
    /// 所以這標要檢查表留需要被執行的命令
    
    [self executeBlock:^{
        NSManagedObjectContext *manaedObjectContext = self.managedObjectContext;
        NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
        [fetchReq setEntity:[NSEntityDescription entityForName:@"TMApiData" inManagedObjectContext:manaedObjectContext]];
        [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"(cacheType == %d) AND (state == %d OR state == %d)",
                                TMAPI_Cache_Type_EveryActive,
                                TMAPI_State_Doing,
                                TMAPI_State_Pending]];
        
        NSArray *resultArray = [manaedObjectContext executeFetchRequest:fetchReq error:nil];
        
        for (TMApiData *object in resultArray)
        {
            if (NO == isIdentifyInTempList(object.identify)) {
                /// 表示在 cache中  但是不再現在的正在執行列表裡  所以要將 doing & pending -> failed
                object.state = [NSNumber numberWithInt:TMAPI_State_Failed];
            }
        }
    }];
}


- (void) switchAPIDataStateFromInvalid2Stop
{
    /// 這個不會管 有沒有正在執行
    /// 會將所有 state != pending 都 將 state 轉換成 stop
    
    [self executeBlock:^{
        NSManagedObjectContext *manaedObjectContext = self.managedObjectContext;
        NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
        [fetchReq setEntity:[NSEntityDescription entityForName:@"TMApiData" inManagedObjectContext:manaedObjectContext]];
        [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"(state == %d or state == %d)",
                                TMAPI_State_Init,
                                TMAPI_State_Doing]];
        
        NSArray *resultArray = [manaedObjectContext executeFetchRequest:fetchReq error:nil];
        
        for (TMApiData *object in resultArray)
        {
            object.state = [NSNumber numberWithInt:TMAPI_State_Stop];
        }
    }];
    
}

- (void) removeAllFinishAPIData
{
    [self executeBlock:^{
        NSManagedObjectContext *manaedObjectContext = self.managedObjectContext;
        NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
        [fetchReq setEntity:[NSEntityDescription entityForName:@"TMApiData" inManagedObjectContext:manaedObjectContext]];        
        [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"(state == %d or state == %d)",
                                TMAPI_State_Finished,
                                TMAPI_State_Stop]];
        
        NSArray *resultArray = [manaedObjectContext executeFetchRequest:fetchReq error:nil];
        
        for (TMApiData *object in resultArray)
        {
            [manaedObjectContext deleteObject:object];
        }
        
        [self save];
    }];
    
}

- (void) _checkAPIAction:(void (^)(TMApiData *object))aActionBlock
{
    [self executeBlock:^{
        NSManagedObjectContext *manaedObjectContext = self.managedObjectContext;
        NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
        [fetchReq setEntity:[NSEntityDescription entityForName:@"TMApiData" inManagedObjectContext:manaedObjectContext]];
        [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"(cacheType == %d OR cacheType == %d) AND (state == %d)",
                                TMAPI_Cache_Type_EveryActive,
                                TMAPI_Cache_Type_ThisActive,
                                TMAPI_State_Failed]];
        
        NSArray *resultArray = [manaedObjectContext executeFetchRequest:fetchReq error:nil];
        
        for (TMApiData *object in resultArray) {
            aActionBlock(object);
        }
    }];
    
    /*
    for (TMApiData *object in resultArray) {
        /// 設後不理
        ////  這裡一直執行可能會有行為上的問題  就是假設一直送不成功 ... 系統可能會很忙 or 煩
        id apiClass = NSClassFromString(object.objectName);
        id apiModel = [[apiClass alloc] initFromAction:object];
        ((TMAPIModel *)apiModel).thread = TMAPI_Thread_Type_SubThread;  ///< 如果做保證執行的動作 則讓他在sub thread 做
        [apiModel startWithDelegate:nil];
    }*/
}



@end
