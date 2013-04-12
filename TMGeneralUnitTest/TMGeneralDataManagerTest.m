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
#import "TMViewController.h"

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

    [[TMGeneralDataManager sharedInstance] removeAllFinishAPIData];
    
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    while ( [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}

    [testVC viewWillDisappear:YES];
}

@end
