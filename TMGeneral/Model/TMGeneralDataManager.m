//
//  TMGeneralDataManager.m
//  TMGeneral
//
//  Created by willsborKang on 12/12/19.
//  Copyright (c) 2012年 thinkermobile. All rights reserved.
//

#import "TMGeneralDataManager.h"
#import "TMDataManager+Protected.h"
#import "TMAPIModel.h"
#import "TMApiData.h"
#import "TMImageCache.h"

#import "TMTools.h"

@implementation TMGeneralDataManager
@synthesize apiIdentifyList = _apiIdentifyList;

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

static NSTimer *g_checkCacheAPITimer = nil;

- (BOOL) isIdentifyInTempList:(NSString *)aIdentify
{
    for (TMAPIModel *object in [[self class] sharedInstance].apiIdentifyList) {
        if ([object.actionItem.identify isEqualToString:aIdentify]) {
            return YES;
        }
    }
    
    return NO;
}

- (void) switchAPIDataStateFromInvalidDoing2Pending
{
    /// 將 不在執行列表中的物件 且 cachetype 是 TMAPI_Cache_Type_EveryActive
    /// 狀態如果是doing 就轉換成 pending  (先不包含 TMAPI_State_Init)
    
    /// 因為程式有可能中途被強制中段 導致 DB內的狀態還停留在doing
    /// 但是要保證 TMAPI_Cache_Type_EveryActive 能被送出
    /// 所以這標要檢查表留需要被執行的命令
    
    [self executeBlock:^{
        NSManagedObjectContext *manaedObjectContext = self.managedObjectContext;
        NSFetchRequest *fetchReq = [[NSFetchRequest alloc]init];
        [fetchReq setEntity:[NSEntityDescription entityForName:@"TMApiData" inManagedObjectContext:manaedObjectContext]];
        [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"(cacheType == %d) AND (state == %d OR state == %d)",
                                TMAPI_Cache_Type_EveryActive,
                                TMAPI_State_Doing,
                                TMAPI_State_Pending]];
        
        NSArray *resultArray = [manaedObjectContext executeFetchRequest:fetchReq error:nil];
        
        for (TMApiData *object in resultArray)
        {
            if (NO == [self isIdentifyInTempList:object.identify]) {
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
    
    /// 所以要先檢查一些不合法的doing 轉成 pending
    [self  switchAPIDataStateFromInvalidDoing2Pending];
    
    [self executeBlock:^{
        NSManagedObjectContext *manaedObjectContext = self.managedObjectContext;
        NSFetchRequest *fetchReq = [[NSFetchRequest alloc]init];
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
        NSFetchRequest *fetchReq = [[NSFetchRequest alloc]init];
        [fetchReq setEntity:[NSEntityDescription entityForName:@"TMApiData" inManagedObjectContext:manaedObjectContext]];
        [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"(state == %d or state == %d)",
                                TMAPI_State_Finished,
                                TMAPI_State_Stop]];
        
        NSArray *resultArray = [manaedObjectContext executeFetchRequest:fetchReq error:nil];
        
        for (TMApiData *object in resultArray)
        {
            [manaedObjectContext deleteObject:object];
        }
    }];
    
}

- (void) _checkAPIAction:(id)sender
{
    @synchronized([self class]) {
        g_checkCacheAPITimer = nil;
    }
    
    __block NSArray *resultArray;
    
    [self executeBlock:^{
        NSManagedObjectContext *manaedObjectContext = self.managedObjectContext;
        NSFetchRequest *fetchReq = [[NSFetchRequest alloc]init];
        [fetchReq setEntity:[NSEntityDescription entityForName:@"TMApiData" inManagedObjectContext:manaedObjectContext]];
        [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"(cacheType == %d OR cacheType == %d) AND (state == %d)",
                                TMAPI_Cache_Type_EveryActive,
                                TMAPI_Cache_Type_ThisActive,
                                TMAPI_State_Failed]];
        
        resultArray = [manaedObjectContext executeFetchRequest:fetchReq error:nil];
    }];
    
    
    for (TMApiData *object in resultArray) {
        /// 設後不理
        ////  這裡一直執行可能會有行為上的問題  就是假設一直送不成功 ... 系統可能會很忙 or 煩
        id apiClass = NSClassFromString(object.objectName);
        id apiModel = [[apiClass alloc] initFromAction:object];
        ((TMAPIModel *)apiModel).thread = TMAPI_Thread_Type_SubThread;  ///< 如果做保證執行的動作 則讓他在sub thread 做
        [apiModel startWithDelegate:nil];
    }
    
    [self startCheckCacheAPI];
}

- (void) startCheckCacheAPI
{
    @synchronized([self class]) {
        if (g_checkCacheAPITimer != nil) {
            return;
        }
        
        g_checkCacheAPITimer = [NSTimer scheduledTimerWithTimeInterval:TMAPIMODEL_DEFAULT_CHECK_API_DURATION target:[self class] selector:@selector(_checkAPIAction:) userInfo:nil repeats:NO];
    }
}

- (void) stopCheckCacheAPI
{
    @synchronized([self class]) {
        [g_checkCacheAPITimer invalidate];
        g_checkCacheAPITimer = nil;
    }
}

- (TMApiData *) createTMApiData
{
    __block TMApiData *_actionItem;
    /// 創造一個新的資料物件
    [self executeBlock:^{
        NSManagedObjectContext *manaedObjectContext = self.managedObjectContext;
        _actionItem = [NSEntityDescription insertNewObjectForEntityForName:@"TMApiData"
                                                    inManagedObjectContext:manaedObjectContext];
    }];
    
    return _actionItem;
}

- (void) changeApiData:(TMApiData *)aData Status:(NSInteger) aState
{
    [self executeBlock:^{
        aData.state = [NSNumber numberWithInteger:aState];
    }];
}

- (void) changeApiData:(TMApiData *)aData CacheType:(NSInteger)aCacheType
{
    [self executeBlock:^{
        aData.cacheType = [NSNumber numberWithInteger:aCacheType];
    }];
}

- (void) changeApiData:(TMApiData *)aData RetryTimes:(NSInteger)aRetryTimes
{
    [self executeBlock:^{
        aData.retryTimes = [NSNumber numberWithInteger:aRetryTimes];
    }];
}

- (void) changeApiData:(TMApiData *)aData RetryDelayTimes:(double)aRetryDelayTimes
{
    [self executeBlock:^{
        aData.retryDelayTime = [NSNumber numberWithDouble:aRetryDelayTimes];
    }];
}

- (TMImageCache *) createImageCacheFrom:(NSString *)aUrl withTagMD5:(NSString *)aTagMD5 andType:(TMImageControl_Type)aType;
{
    __block TMImageCache *_actionItem = nil;
    [self executeBlock:^{
        NSManagedObjectContext *manaedObjectContext = self.managedObjectContext;
        NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
        [fetchReq setEntity:[NSEntityDescription entityForName:@"TMImageCache"
                                        inManagedObjectContext:manaedObjectContext]];
        
        [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"tag == %@", aTagMD5]];
        
        NSArray *resultArray = [manaedObjectContext executeFetchRequest:fetchReq error:nil];
        
        if ([resultArray count] == 1) {
            _actionItem = [resultArray objectAtIndex:0];
            
        } else if ([resultArray count] == 0) {
            
            
            
            NSManagedObjectContext *manaedObjectContext = self.managedObjectContext;
            _actionItem = [NSEntityDescription insertNewObjectForEntityForName:@"TMImageCache"
                                                 inManagedObjectContext:manaedObjectContext];
            _actionItem.tag = aTagMD5;
            _actionItem.identify = tmStringFromMD5([NSString stringWithFormat:@"%@%f", aTagMD5, [[NSDate date] timeIntervalSince1970]]);
            _actionItem.type = [NSNumber numberWithInt:aType];
            
        } else {
            assert(@"重複");
        }
    }];
    
    return _actionItem;
}

- (void) imageCache:(TMImageCache *)aImageCache setData:(NSData *)aImageData
{
    [self executeBlock:^{
        aImageCache.data = aImageData;
        aImageCache.lastDate = [NSDate date];
    }];
}

#pragma mark -

- (NSString *)managedObjectBundleName
{
    return @"TMGeneralResource";
}

- (NSString *)managedObjectModelName
{
    return @"TMGeneralDataModel";
}

- (NSMutableArray *) apiIdentifyList
{
    if (_apiIdentifyList) {
        return _apiIdentifyList;
    }
    
    _apiIdentifyList = [[NSMutableArray alloc] init];
    
    return _apiIdentifyList;
}

@end
