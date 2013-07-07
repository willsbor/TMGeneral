//
//  TMGeneralDataManagerTest.m
//  TMGeneral
//
//  Created by willsborKang on 12/12/19.
//  Copyright (c) 2012年 thinkermobile. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TMDataManager+Protected.h"
#import "TMGeneralDataManager.h"
#import "TMAPIModel.h"
#import "TMImageCache.h"
#import "TMViewController.h"
#import "TMUITools.h"

#import <objc/runtime.h>

@interface TMAPIModelTest : TMAPIModel

@end

@implementation TMAPIModelTest

- (void) main
{
    self.errcode = TMAPI_Errcode_Success;
    
    [self final];
}

@end

@interface TMGeneralDataManager ()
- (TMApiData *) _getApiDataByIdentify:(NSString *)aIdentify;
- (TMImageCache *) _imageCacheByTag:(NSString *)aTagMD5;
@end

@interface TMGeneralDataManager (UTest)

@end

@implementation TMGeneralDataManager (UTest)

+ (void)load
{
	Method origMethod = class_getInstanceMethod(self, @selector(initWithDatabaseFilename:));
	Method newMethod = class_getInstanceMethod(self, @selector(initWithDatabaseFilename_override:));
	method_setImplementation(origMethod, method_getImplementation(newMethod));
    
    origMethod = class_getInstanceMethod(self, @selector(managedObjectModel));
	newMethod = class_getInstanceMethod(self, @selector(managedObjectModel_override));
    method_setImplementation(origMethod, method_getImplementation(newMethod));
}


- (id)initWithDatabaseFilename_override:(NSString *)aDatabaseFileName
{
	return [self initWithInMemoryStore];
}

- (NSManagedObjectModel *)managedObjectModel_override
{
    NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    return mom;
}

@end


@interface TMGeneralDataManagerTest : SenTestCase
{
    NSDate *asyncWaitUntil;
}
@end

@implementation TMGeneralDataManagerTest

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

/*- (void)testGeneralDBName
{
    NSString *DBName = [[TMGeneralDataManager sharedInstance] managedObjectModelName];
    STAssertTrue([DBName isEqualToString:@"TMGeneralDataModel"], @"Can't find DB Name %@", DBName);
}*/

- (void) testActiveApiAndThenDeleteFromDBAndCancel
{
    
    TMAPIModel *api = [[TMAPIModel alloc] initWithInput:@{}];
    
    TMViewController *testVC = [[TMViewController alloc] init];
    [testVC executeAPI:api];
    
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while ( [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}

    [TMAPIModel removeAllFinishAPIData];
    
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while ( [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}

    [testVC viewWillDisappear:YES];
}

- (void) testCreateTMApiData
{
    NSString *objectID = [[TMGeneralDataManager sharedInstance] createTMApiDataWith:nil];
    NSLog(@"Unit Test : objectID = %@", objectID);
    STAssertNotNil(objectID, @"");
    
    /*
     _actionItem.objectName = NSStringFromClass([self class]);   ///< 返回執行時要啟動的 object
     NSLog(@"TMAPIModel save in DB and target class [inside] : %@", _actionItem.objectName);
     _actionItem.createTime = _actionItem.lastActionTime = [NSDate date];
     _actionItem.identify = tmStringFromMD5([NSString stringWithFormat:@"%@", _actionItem.createTime]);
     
     _actionItem.retryDelayTime = @TMAPIMODEL_DEFAULT_RETRY_DELAY_TIME;
     _actionItem.type = [NSNumber numberWithInt:TMAPI_Type_General];
     _actionItem.cacheType = [NSNumber numberWithInt:TMAPI_Cache_Type_None];
     _actionItem.state = [NSNumber numberWithInt:TMAPI_State_Init];
     _actionItem.retryTimes = @3;
     _actionItem.mode = [NSNumber numberWithInt:TMAPI_Mode_Leave_With_Cancel];
     */
    
    [[TMGeneralDataManager sharedInstance] executeBlock:^{
        TMApiData *api = [[TMGeneralDataManager sharedInstance] _getApiDataByIdentify:objectID];

        STAssertNotNil(api.identify, @"");
        STAssertEqualObjects(api.objectName, @"TMGeneralDataManager", nil);
        STAssertEqualObjects(api.createTime, api.lastActionTime, nil);
        STAssertEqualObjects(api.retryDelayTime, @TMAPIMODEL_DEFAULT_RETRY_DELAY_TIME, nil);
        STAssertEqualObjects(api.type, [NSNumber numberWithInt:TMAPI_Type_General], nil);
        STAssertEqualObjects(api.cacheType, [NSNumber numberWithInt:TMAPI_Cache_Type_None], nil);
        STAssertEqualObjects(api.state, [NSNumber numberWithInt:TMAPI_State_Init], nil);
        STAssertEqualObjects(api.retryTimes, @3, nil);
        STAssertEqualObjects(api.mode, [NSNumber numberWithInt:TMAPI_Mode_Leave_With_Cancel], nil);
    }];
}

- (void) testChangeFunction
{
    NSString *objectID = [[TMGeneralDataManager sharedInstance] createTMApiDataWith:nil];
    NSLog(@"Unit Test : objectID = %@", objectID);
    STAssertNotNil(objectID, @"");
    
    [[TMGeneralDataManager sharedInstance] changeApiData:objectID With:^(TMApiData *apidata) {
        apidata.state = [NSNumber numberWithInt:TMAPI_State_Finished];
    }];
    
    [[TMGeneralDataManager sharedInstance] executeBlock:^{
        TMApiData *api = [[TMGeneralDataManager sharedInstance] _getApiDataByIdentify:objectID];
        
        STAssertNotNil(api.identify, @"");
        STAssertEqualObjects(api.objectName, @"TMGeneralDataManager", nil);
        STAssertEqualObjects(api.createTime, api.lastActionTime, nil);
        STAssertEqualObjects(api.retryDelayTime, @TMAPIMODEL_DEFAULT_RETRY_DELAY_TIME, nil);
        STAssertEqualObjects(api.type, [NSNumber numberWithInt:TMAPI_Type_General], nil);
        STAssertEqualObjects(api.cacheType, [NSNumber numberWithInt:TMAPI_Cache_Type_None], nil);
        STAssertEqualObjects(api.state, [NSNumber numberWithInt:TMAPI_State_Finished], nil);
        STAssertEqualObjects(api.retryTimes, @3, nil);
        STAssertEqualObjects(api.mode, [NSNumber numberWithInt:TMAPI_Mode_Leave_With_Cancel], nil);
    }];
}

- (void) testChangeFunction2
{
    NSString *objectID = [[TMGeneralDataManager sharedInstance] createTMApiDataWith:nil];
    NSLog(@"Unit Test : objectID = %@", objectID);
    STAssertNotNil(objectID, @"");
    
    [[TMGeneralDataManager sharedInstance] changeApiData:objectID CacheType:TMAPI_Cache_Type_ThisActive];
    
    [[TMGeneralDataManager sharedInstance] executeBlock:^{
        TMApiData *api = [[TMGeneralDataManager sharedInstance] _getApiDataByIdentify:objectID];
        
        STAssertNotNil(api.identify, @"");
        STAssertEqualObjects(api.objectName, @"TMGeneralDataManager", nil);
        STAssertEqualObjects(api.createTime, api.lastActionTime, nil);
        STAssertEqualObjects(api.retryDelayTime, @TMAPIMODEL_DEFAULT_RETRY_DELAY_TIME, nil);
        STAssertEqualObjects(api.type, [NSNumber numberWithInt:TMAPI_Type_General], nil);
        STAssertEqualObjects(api.cacheType, [NSNumber numberWithInt:TMAPI_Cache_Type_ThisActive], nil);
        STAssertEqualObjects(api.state, [NSNumber numberWithInt:TMAPI_State_Init], nil);
        STAssertEqualObjects(api.retryTimes, @3, nil);
        STAssertEqualObjects(api.mode, [NSNumber numberWithInt:TMAPI_Mode_Leave_With_Cancel], nil);
    }];
    
    [[TMGeneralDataManager sharedInstance] changeApiData:objectID RetryDelayTimes:100];
    
    [[TMGeneralDataManager sharedInstance] executeBlock:^{
        TMApiData *api = [[TMGeneralDataManager sharedInstance] _getApiDataByIdentify:objectID];
        
        STAssertNotNil(api.identify, @"");
        STAssertEqualObjects(api.objectName, @"TMGeneralDataManager", nil);
        STAssertEqualObjects(api.createTime, api.lastActionTime, nil);
        STAssertEqualObjects(api.retryDelayTime, @100, nil);
        STAssertEqualObjects(api.type, [NSNumber numberWithInt:TMAPI_Type_General], nil);
        STAssertEqualObjects(api.cacheType, [NSNumber numberWithInt:TMAPI_Cache_Type_ThisActive], nil);
        STAssertEqualObjects(api.state, [NSNumber numberWithInt:TMAPI_State_Init], nil);
        STAssertEqualObjects(api.retryTimes, @3, nil);
        STAssertEqualObjects(api.mode, [NSNumber numberWithInt:TMAPI_Mode_Leave_With_Cancel], nil);
    }];
    
    [[TMGeneralDataManager sharedInstance] changeApiData:objectID RetryTimes:232];
    
    [[TMGeneralDataManager sharedInstance] executeBlock:^{
        TMApiData *api = [[TMGeneralDataManager sharedInstance] _getApiDataByIdentify:objectID];
        
        STAssertNotNil(api.identify, @"");
        STAssertEqualObjects(api.objectName, @"TMGeneralDataManager", nil);
        STAssertEqualObjects(api.createTime, api.lastActionTime, nil);
        STAssertEqualObjects(api.retryDelayTime, @100, nil);
        STAssertEqualObjects(api.type, [NSNumber numberWithInt:TMAPI_Type_General], nil);
        STAssertEqualObjects(api.cacheType, [NSNumber numberWithInt:TMAPI_Cache_Type_ThisActive], nil);
        STAssertEqualObjects(api.state, [NSNumber numberWithInt:TMAPI_State_Init], nil);
        STAssertEqualObjects(api.retryTimes, @232, nil);
        STAssertEqualObjects(api.mode, [NSNumber numberWithInt:TMAPI_Mode_Leave_With_Cancel], nil);
    }];
}

- (void) testReturnObject
{
    NSString *objectID = [[TMGeneralDataManager sharedInstance] createTMApiDataWith:nil];
    NSLog(@"Unit Test : objectID = %@", objectID);
    STAssertNotNil(objectID, @"");
    
    id returnObj = [[TMGeneralDataManager sharedInstance] returnObjectByKey:@"identify" OfIdentify:objectID];
    STAssertEqualObjects(objectID, returnObj, nil);
    
    returnObj = [[TMGeneralDataManager sharedInstance] returnObjectByKey:@"createTime" OfIdentify:objectID];
    STAssertNotNil(returnObj, nil);
    
    returnObj = [[TMGeneralDataManager sharedInstance] returnObjectByKey:@"retryDelayTime" OfIdentify:objectID];
    STAssertEqualObjects(returnObj, @TMAPIMODEL_DEFAULT_RETRY_DELAY_TIME, nil);

    returnObj = [[TMGeneralDataManager sharedInstance] returnObjectByKey:@"type" OfIdentify:objectID];
    STAssertEqualObjects(returnObj, [NSNumber numberWithInt:TMAPI_Type_General], nil);
    
    returnObj = [[TMGeneralDataManager sharedInstance] returnObjectByKey:@"cacheType" OfIdentify:objectID];
    STAssertEqualObjects(returnObj, [NSNumber numberWithInt:TMAPI_Cache_Type_None], nil);
    
    returnObj = [[TMGeneralDataManager sharedInstance] returnObjectByKey:@"state" OfIdentify:objectID];
    STAssertEqualObjects(returnObj, [NSNumber numberWithInt:TMAPI_State_Init], nil);
    
    returnObj = [[TMGeneralDataManager sharedInstance] returnObjectByKey:@"retryTimes" OfIdentify:objectID];
    STAssertEqualObjects(returnObj, [NSNumber numberWithInt:3], nil);
    
    returnObj = [[TMGeneralDataManager sharedInstance] returnObjectByKey:@"mode" OfIdentify:objectID];
    STAssertEqualObjects(returnObj, [NSNumber numberWithInt:TMAPI_Mode_Leave_With_Cancel], nil);
}

- (void) testCreateImageCache
{
    NSString *inputTag = @"testCreateImageCache";
    NSString *returntag = [[TMGeneralDataManager sharedInstance] createImageCacheWithTagMD5:inputTag andType:(TMImageControl_Type_FirstTime)];
    
    STAssertEqualObjects(inputTag, returntag, nil);
}

- (void) testSaveDataInImageCache
{
    NSString *inputTag = @"testSaveDataInImageCache";
    NSString *returntag = [[TMGeneralDataManager sharedInstance] createImageCacheWithTagMD5:inputTag andType:(TMImageControl_Type_FirstTime)];
    
    UIImage *image = tmImageWithColor([UIColor grayColor]);
    [[TMGeneralDataManager sharedInstance] imageCache:returntag setData:UIImageJPEGRepresentation(image, 0.5)];
    
    [[TMGeneralDataManager sharedInstance] executeBlock:^{
        TMImageCache *imageCache = [[TMGeneralDataManager sharedInstance] _imageCacheByTag:returntag];
        
        STAssertEqualObjects(UIImageJPEGRepresentation(image, 0.5), imageCache.data, @"");
    }];
}

- (void) testGetImageData
{
    NSString *inputTag = @"testGetImageData";
    NSString *returntag = [[TMGeneralDataManager sharedInstance] createImageCacheWithTagMD5:inputTag andType:(TMImageControl_Type_FirstTime)];
    
    UIImage *image = tmImageWithColor([UIColor grayColor]);
    [[TMGeneralDataManager sharedInstance] imageCache:returntag setData:UIImageJPEGRepresentation(image, 0.5)];
    

    NSData *imageData = [[TMGeneralDataManager sharedInstance] imageCacheImageDataByTag:returntag];
    
    STAssertEqualObjects(UIImageJPEGRepresentation(image, 0.5), imageData, @"");
}

- (void) testHaveImageData
{
    NSString *inputTag = @"testHaveImageData";
    NSString *returntag = [[TMGeneralDataManager sharedInstance] createImageCacheWithTagMD5:inputTag andType:(TMImageControl_Type_FirstTime)];
    
    BOOL isHaveData = [[TMGeneralDataManager sharedInstance] isHaveImageDataByTag:returntag];
    
    STAssertFalse(isHaveData, @"");
    
    UIImage *image = tmImageWithColor([UIColor grayColor]);
    [[TMGeneralDataManager sharedInstance] imageCache:returntag setData:UIImageJPEGRepresentation(image, 0.5)];
    
    isHaveData = [[TMGeneralDataManager sharedInstance] isHaveImageDataByTag:returntag];
    
    STAssertTrue(isHaveData, @"");

}

@end
