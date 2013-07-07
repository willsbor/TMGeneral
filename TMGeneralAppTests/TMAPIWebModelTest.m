//
//  TMAPIWebModelTest.m
//  TMGeneral
//
//  Created by willsborKang on 12/12/19.
//  Copyright (c) 2012年 thinkermobile. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TMAPIWebModel.h"
#import "TMApiData.h"
#import "TMViewController.h"
#import "TMDataManager.h"
#import "TMDataManager+Protected.h"
#import "TMGeneralDataManager.h"
#import <objc/runtime.h>

@interface TMAPIModel (privateFunction)

@end

@implementation TMAPIModel (privateFunction)

+ (void)load
{
    //+ (void) startCheckCacheAPI
    Method origMethod = class_getClassMethod([self class], @selector(startCheckCacheAPI));
	Method newMethod = class_getClassMethod([self class], @selector(startCheckCacheAPI_override));
	
	method_setImplementation(origMethod, method_getImplementation(newMethod));
}

+ (void) startCheckCacheAPI_override
{
    
}

@end

@interface TMGeneralDataManager ()
- (void) _checkAPIAction:(id)sender;
@end


@interface TMDataManager (UTest)

@end

@implementation TMDataManager (UTest)

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

- (void) save {
    
}

@end
@interface TMTestViewController : TMViewController

@end

@implementation TMTestViewController


@end

#pragma mark - 

@interface TMEWebApiTestGoogle : TMAPIWebModel

@end

@implementation TMEWebApiTestGoogle

- (id) initWithInput:(NSDictionary *)aInput
{
    NSMutableDictionary *newImput = [NSMutableDictionary dictionaryWithDictionary:aInput];
    
    [newImput setObject:@"https://www.google.com.tw/" forKey:TMAPI_WEB_BASEURL];
    [newImput setObject:@"" forKey:TMAPI_WEB_PATH];
    [newImput setObject:@"GET" forKey:TMAPI_WEB_METHOD];
    //[newImput setObject:aInput forKey:TMAPI_WEB_PARAM];
    
    self = [super initWithInput:newImput];
    if (self) {
        
    }
    return self;
}

- (void) webSuccess:(AFHTTPRequestOperation *)operation response:(id)responseObject {
    self.errcode = TMAPI_Errcode_Success;
}
- (void) webFailed:(AFHTTPRequestOperation *)operation error:(NSError *)error { }

@end

#pragma mark -

@interface TMEWebApiTest : TMAPIWebModel

@end

@implementation TMEWebApiTest

- (id) initWithInput:(NSDictionary *)aInput
{
    NSMutableDictionary *newImput = [NSMutableDictionary dictionary];
    
    [newImput setObject:@"https://maps.googleapis.com" forKey:TMAPI_WEB_BASEURL];
    [newImput setObject:@"maps/api/geocode/json" forKey:TMAPI_WEB_PATH];
    [newImput setObject:@"GET" forKey:TMAPI_WEB_METHOD];
    [newImput setObject:@3 forKey:TMAPI_WEB_TIMEOUT];
    [newImput setObject:aInput forKey:TMAPI_WEB_PARAM];
    
    self = [super initWithInput:newImput];
    if (self) {
        
    }
    
    return self;
}

- (void) webSuccess:(AFHTTPRequestOperation *)operation response:(id)responseObject
{
    //NSError *error;
    //NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
    //NSLog(@"responseObject = %@", result);
    self.errcode = TMAPI_Errcode_Success;
}

- (void) webFailed:(AFHTTPRequestOperation *)operation error:(NSError *)error
{
}

@end

#pragma mark - 

@interface TMAPIWebModelTest : SenTestCase
{
    NSDate *asyncWaitUntil;
}
@end

@implementation TMAPIWebModelTest

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

- (void) testConnectNormal
{
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    
    TMEWebApiTestGoogle *api = [[TMEWebApiTestGoogle alloc] initWithInput:@{TMAPI_WEB_TIMEOUT : @3} ];
    api.retryTimes = 1;
    api.cacheType = TMAPI_Cache_Type_None;
    
    
    TMTestViewController *testVC = [[TMTestViewController alloc] init];
    [testVC executeAPI:api];
    
    STAssertTrue(api.state == TMAPI_State_Doing, @"stat Don't change");
    
	while (api.state == TMAPI_State_Doing && [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}
    
	
	if (api.errcode != TMAPI_Errcode_Success) {
		STFail(@"API connection should be opened on time or have some error %d.", api.errcode);
	}
}

/*
- (void) testConnectTimeoutWithoutRetry
{
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    
    TMEWebApiTestGoogle *api = [[TMEWebApiTestGoogle alloc] initWithInput:@{TMAPI_WEB_TIMEOUT : @0} ];
    api.retryTimes = 0;
    api.cacheType = TMAPI_Cache_Type_None;
    
    TMTestViewController *testVC = [[TMTestViewController alloc] init];
    [testVC executeAPI:api];
    
    
	while (api.state == TMAPI_State_Doing && [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}
    
    STAssertTrue(api.state == TMAPI_State_Failed, @"the state should be TMAPI_State_Failed. (state = %d)", api.state);
    STAssertTrue(api.errcode == TMAPI_Errcode_Failed, @"Timeout time = 0, so the errcode should be TMAPI_Errcode_Failed (error = %d)", api.errcode);
}

- (void) testConnectTimeoutWithRetry3
{
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    
    TMEWebApiTestGoogle *api = [[TMEWebApiTestGoogle alloc] initWithInput:@{TMAPI_WEB_TIMEOUT : @0} ];
    api.retryTimes = 2; ///<
    api.retryDelayTime = 1.0;
    api.cacheType = TMAPI_Cache_Type_None;
    
    TMTestViewController *testVC = [[TMTestViewController alloc] init];
    [testVC executeAPI:api];
    
    
	while ((api.state == TMAPI_State_Doing || api.state == TMAPI_State_Pending) && [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}
    
    STAssertTrue(api.state == TMAPI_State_Failed, @"the state should be TMAPI_State_Failed. (state = %d)", api.state);
    STAssertTrue(api.errcode == TMAPI_Errcode_Failed_And_Retry, @"Timeout time = 0, so the errcode should be TMAPI_Errcode_Failed_And_Retry (error = %d)", api.errcode);
}

- (void) testConnectTimeoutAndCacheThisActive
{
    TMEWebApiTestGoogle *api = [[TMEWebApiTestGoogle alloc] initWithInput:@{TMAPI_WEB_TIMEOUT : @0} ];
    api.retryTimes = 0; ///<
    api.retryDelayTime = 1.0;
    api.cacheType = TMAPI_Cache_Type_ThisActive;
    
    
    TMTestViewController *testVC = [[TMTestViewController alloc] init];
    [testVC executeAPI:api];
    
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:5];
	while ((api.state == TMAPI_State_Doing || api.state == TMAPI_State_Pending) && [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}
    
    STAssertTrue(api.state == TMAPI_State_Failed, @"the state should be TMAPI_State_Failed. (state = %d)", api.state);
    STAssertTrue(api.errcode == TMAPI_Errcode_Failed, @"Timeout time = 0, so the errcode should be TMAPI_Errcode_Failed (error = %d)", api.errcode);
    
    ///  偷拿出來把timeout 改掉
    __block NSArray *resultArray;
    [[TMGeneralDataManager sharedInstance] executeBlock:^{
        NSManagedObjectContext *manaedObjectContext = [TMGeneralDataManager sharedInstance].managedObjectContext;
        NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
        [fetchReq setEntity:[NSEntityDescription entityForName:@"TMApiData" inManagedObjectContext:manaedObjectContext]];
        [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"(cacheType == %d OR cacheType == %d) AND (state == %d)",
                                TMAPI_Cache_Type_EveryActive,
                                TMAPI_Cache_Type_ThisActive,
                                TMAPI_State_Failed]];
        
         resultArray = [manaedObjectContext executeFetchRequest:fetchReq error:nil];
    }];
    
    
    STAssertTrue([resultArray count] == 1, @"there only one Failed api_model");
    
    TMApiData *object = [resultArray objectAtIndex:0];
    NSDictionary *dic = [TMDataManager objectFormNSData:object.content];
    NSMutableDictionary *newDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    [newDic setObject:@2 forKey:TMAPI_WEB_TIMEOUT];
    object.content = [TMDataManager dataFromNSData:newDic];
    
    //// 後台跑 sub thread 重新開始
    [[TMGeneralDataManager sharedInstance] _checkAPIAction:nil];
    
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:2.5];
    while ( [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}
    
    [[TMGeneralDataManager sharedInstance] executeBlock:^{
        NSManagedObjectContext *manaedObjectContext = [TMGeneralDataManager sharedInstance].managedObjectContext;
        NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
        [fetchReq setEntity:[NSEntityDescription entityForName:@"TMApiData" inManagedObjectContext:manaedObjectContext]];
        [fetchReq setPredicate:[NSPredicate predicateWithFormat:@"(cacheType == %d OR cacheType == %d) AND (state == %d)",
                                TMAPI_Cache_Type_EveryActive,
                                TMAPI_Cache_Type_ThisActive,
                                TMAPI_State_Finished]];
        
        resultArray = [manaedObjectContext executeFetchRequest:fetchReq error:nil];
    }];
    
    STAssertTrue([resultArray count] == 1, @"there should be one success task");
}

 */

@end
