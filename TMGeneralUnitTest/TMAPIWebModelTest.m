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
#import <objc/runtime.h>

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
    NSLog(@"webSuccess");

    //NSError *error;
    //NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
    
    //NSLog(@"responseObject = %@", result);
    
    self.errcode = TMAPI_Errcode_Success;
}

- (void) webFailed:(AFHTTPRequestOperation *)operation error:(NSError *)error
{
    NSLog(@"webFailed Error: %@", error);
    
}

@end

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
    
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:5];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testWebAPI
{

    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"23.92100530,116.12775280", @"latlng",
                         @"false", @"sensor",
                         nil];
    TMEWebApiTest *api = [[TMEWebApiTest alloc] initWithInput:dic];
    //api.guaranteeAction = TMAPI_GuaranteeAction_Internet;
    api.retryTimes = 2;
    api.cacheType = TMAPI_Cache_Type_None;
    
    TMTestViewController *testVC = [[TMTestViewController alloc] init];
    
    [testVC executeAPI:api];
    
    ///STFail(@"Websocket connection should be opened successfully.");
	
    STAssertTrue(api.state == TMAPI_State_Doing, @"stat Don't change");
    
	while (api.state == TMAPI_State_Doing && [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}
    
	
	if (api.errcode != TMAPI_Errcode_Success) {
		STFail(@"API connection should be opened on time or have some error %d.", api.errcode);
	}
}

@end
