//
//  TMDataManagerTest.m
//  TMGeneral
//
//  Created by willsborKang on 13/11/11.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <objc/runtime.h>
#import <libkern/OSAtomic.h>

#import "TMDataManager+Protected.h"
#import "TMDataManager.h"

#import "TMTestDataModel.h"
#import "TestModel.h"
#import "Willsbor.h"

#import "TestModel2+Plus.h"
#import "TestModel3.h"
#import "TestModel4.h"

@interface TMDataManagerTest : SenTestCase
{
    NSDate *asyncWaitUntil;
    
    //IMP imp_old_managedObjectModel;
}
@end

@implementation TMDataManagerTest

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    __block BOOL deleteFinish = NO;
    [[TMTestDataModel sharedInstance] closeMOCandPSCWtihDeleteDataBaseFileComplete:^{
        deleteFinish = YES;
    }];
    
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:10.0];
    while (!deleteFinish && [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}
    
    STAssertTrue(deleteFinish, @"delete failed");
    
    [super tearDown];
}

- (void)testInitAndRemoveDBfile
{
    NSString *docsPath = [[TMTestDataModel sharedInstance] persistentStoreDirectory];
    NSString *storePath = [docsPath stringByAppendingPathComponent:[TMTestDataModel sharedInstance].databaseFileName];

    [TMTestDataModel sharedInstance].mainThreadManagedObjectContext;
    
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:storePath], @"data base file is should exist : %@", storePath);

}

- (void) testCreateOneItem
{
    NSDate *nowDate = [NSDate date];
    [[TMTestDataModel sharedInstance] executeBlock:^{
        Willsbor * test = [[TMTestDataModel sharedInstance] _createOneItem:@"Willsbor"];
        test.create_time = nowDate;
        test.name = @"testCreateOneItem";
        test.identify = @(123);
    }];

    
    [[TMTestDataModel sharedInstance] executeBlock:^{
        NSArray *result = [[TMTestDataModel sharedInstance] _getAllItems:@"Willsbor" ByPred:nil];
        
        STAssertTrue([result count] == 1, @"");
        
        Willsbor *test  = [result objectAtIndex:0];
        STAssertEqualObjects(test.create_time, nowDate, nil);
        STAssertEqualObjects(test.name, @"testCreateOneItem", nil);
        STAssertEqualObjects(test.identify, @(123), nil);
    }];
    
}

- (void) testDeqFunction
{
    __block Willsbor *test;
    NSDate *nowDate = [NSDate date];
    [[TMTestDataModel sharedInstance] executeBlock:^{
        test = [[TMTestDataModel sharedInstance] _deqOneItem:@"Willsbor" ByPred:nil];
        test.create_time = nowDate;
        test.name = @"testCreateOneItem";
        test.identify = @(123);
    }];
    
    __block Willsbor * test2;
    NSDate *nowDate2 = [NSDate date];
    [[TMTestDataModel sharedInstance] executeBlock:^{
        test2 = [[TMTestDataModel sharedInstance] _deqOneItem:@"Willsbor" ByPred:[NSPredicate predicateWithFormat:@"identify == %@", @(123)]];
        test2.create_time = nowDate2;
        test2.name = @"testCreateOneItem2";
        test2.identify = @(456);
        
        STAssertEquals(test2, test, nil);
    }];
    
    [[TMTestDataModel sharedInstance] executeBlock:^{
        NSArray *result = [[TMTestDataModel sharedInstance] _getAllItems:@"Willsbor" ByPred:nil];
        
        STAssertTrue([result count] == 1, @"");
        
        Willsbor *obj  = [result objectAtIndex:0];
        STAssertEqualObjects(obj.create_time, nowDate2, nil);
        STAssertEqualObjects(obj.name, @"testCreateOneItem2", nil);
        STAssertEqualObjects(obj.identify, @(456), nil);
    }];
    
    
    [[TMTestDataModel sharedInstance] executeBlock:^{
        test2 = [[TMTestDataModel sharedInstance] _deqOneItem:@"Willsbor" ByPred:[NSPredicate predicateWithFormat:@"identify == %@", @(123)]];
        
        STAssertNil(test2.create_time, nil);
        STAssertNil(test2.name, nil);
        STAssertEqualObjects(test2.identify, @0, nil);
        
        test2.create_time = nowDate;
        test2.name = @"testCreateOneItem3";
        test2.identify = @(789);
    }];
    
    [[TMTestDataModel sharedInstance] executeBlock:^{
        NSArray *result = [[TMTestDataModel sharedInstance] _getAllItems:@"Willsbor" ByPred:nil];
        
        STAssertTrue([result count] == 2, @"");
    }];
    
    [[TMTestDataModel sharedInstance] executeBlock:^{
        Willsbor *obj  = [[TMTestDataModel sharedInstance] _getOneItem:@"Willsbor" ByPred:[NSPredicate predicateWithFormat:@"identify == %@", @(789)]];
        
        STAssertEqualObjects(obj.create_time, nowDate, nil);
        STAssertEqualObjects(obj.name, @"testCreateOneItem3", nil);
        STAssertEqualObjects(obj.identify, @(789), nil);
    }];
    
}

- (void) testRemoveObjectOnTwo
{
    NSDate *nowDate = [NSDate date];
    [[TMTestDataModel sharedInstance] executeBlock:^{
        Willsbor *test = [[TMTestDataModel sharedInstance] _deqOneItem:@"Willsbor" ByPred:nil];
        test.create_time = nowDate;
        test.name = @"testCreateOneItem";
        test.identify = @(123);
        
        Willsbor *test2 = [[TMTestDataModel sharedInstance] _getOneItem:@"Willsbor" ByPred:nil];
        
        STAssertEquals(test, test2, nil);
        STAssertFalse([test isFault], nil);
        STAssertFalse([test isDeleted], nil);
        STAssertFalse([test2 isFault], nil);
        STAssertFalse([test2 isDeleted], nil);
        
        
        
        [[TMTestDataModel sharedInstance].managedObjectContext deleteObject:test];
        STAssertFalse([test isFault], nil);
        STAssertTrue([test isDeleted], nil);
        STAssertFalse([test2 isFault], nil);
        STAssertTrue([test2 isDeleted], nil);
        
        Willsbor *test3 = [[TMTestDataModel sharedInstance] _getOneItem:@"Willsbor" ByPred:nil];
        STAssertNil(test3, nil);
        
        
        
        [[TMTestDataModel sharedInstance] save];
        STAssertTrue([test isFault], nil);
        STAssertTrue([test2 isFault], nil);
        
        Willsbor *test4 = [[TMTestDataModel sharedInstance] _getOneItem:@"Willsbor" ByPred:nil];
        STAssertNil(test4, nil);
    }];
}

- (void) testRemoveObjectFunciton
{
    NSDate *nowDate = [NSDate date];
    [[TMTestDataModel sharedInstance] executeBlock:^{
        TestModel2 *test2 = [[TMTestDataModel sharedInstance] _createOneItem:@"TestModel2"];
        
        test2.createDate = nowDate;
        test2.tag = @"test2";
        
        TestModel3 *test3 = [[TMTestDataModel sharedInstance] _createOneItem:@"TestModel3"];
        test3.tag = @"test3-1";
        [test2 addModel3sObject:test3];
        test3 = [[TMTestDataModel sharedInstance] _createOneItem:@"TestModel3"];
        test3.tag = @"test3-2";
        [test2 addModel3sObject:test3];
        test3 = [[TMTestDataModel sharedInstance] _createOneItem:@"TestModel3"];
        test3.tag = @"test3-3";
        [test2 addModel3sObject:test3];
        test3 = [[TMTestDataModel sharedInstance] _createOneItem:@"TestModel3"];
        test3.tag = @"test3-3";
        [test2 addModel3sObject:test3];
        
        TestModel4 *test4 = [[TMTestDataModel sharedInstance] _createOneItem:@"TestModel4"];
        test4.tag = @"test4-1";
        [test2 addModel4sObject:test4];
        test4 = [[TMTestDataModel sharedInstance] _createOneItem:@"TestModel4"];
        test4.tag = @"test4-2";
        [test2 addModel4sObject:test4];
        test4 = [[TMTestDataModel sharedInstance] _createOneItem:@"TestModel4"];
        test4.tag = @"test4-3";
        [test2 addModel4sObject:test4];
        
        STAssertEqualsWithAccuracy([test2.model3s count], (NSUInteger)4, 0, nil);
        STAssertEqualsWithAccuracy([test2.model4s count], (NSUInteger)3, 0, nil);
        
        [[TMTestDataModel sharedInstance] _removeObjects:@"TestModel2" ByPred:nil];
        
        STAssertFalse([test2 isFault], nil);
        STAssertTrue([test2 isDeleted], nil);
        [[TMTestDataModel sharedInstance] save];
        STAssertTrue([test2 isFault], nil);
        
        test2 = [[TMTestDataModel sharedInstance] _getOneItem:@"TestModel2" ByPred:nil];
        STAssertNil(test2, nil);
    }];
}

@end
