//
//  TMToolTest.m
//  TMGeneral
//
//  Created by willsborKang on 13/4/9.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TMTools.h"

@interface TMToolTest : SenTestCase

@end


@implementation TMToolTest

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

- (void)testNSDataFormateByC
{
    NSDate *test = [NSDate dateWithTimeIntervalSince1970:1424231];
    
    NSString *formate = tmStringNSDataByC(test, NULL);
    
    STAssertEqualObjects(formate, @"1970.01.17 11:37", @"default formate wrong");
}

- (void)testNSDataFormateByCWithInputFormate
{
    NSDate *test = [NSDate dateWithTimeIntervalSince1970:1424231];
    
    NSString *formate = tmStringNSDataByC(test, "%Y.%m.%d - %H:%M:%S%z");
    
    STAssertEqualObjects(formate, @"1970.01.17 - 11:37:11+0800", @"default formate wrong");
}

@end
