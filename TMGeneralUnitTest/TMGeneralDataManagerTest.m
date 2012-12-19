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

@interface TMGeneralDataManagerTest : SenTestCase

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

- (void)testGeneralDBName
{
    NSString *DBName = [[TMGeneralDataManager sharedInstance] managedObjectModelName];
    STAssertTrue([DBName isEqualToString:@"TMGeneralDataModel"], @"Can't find DB Name %@", DBName);
}



@end
