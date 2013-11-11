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
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    NSDate *target = [formatter dateFromString:@"1970.01.17 11:37:00"];
    
    NSString *formate = tmStringNSDateByC(target, NULL);
    
    STAssertEqualObjects(formate, @"1970.01.17 03:37", @"default formate wrong");
}

- (void)testNSDataFormateByCWithInputFormate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    NSDate *target = [formatter dateFromString:@"1970.01.17 11:37:11"];
    
    NSString *formate = tmStringNSDateByC(target, "%Y.%m.%d - %H:%M:%S%z");
    
    STAssertEqualObjects(formate, @"1970.01.17 - 03:37:11+0800", @"default formate wrong");
}

- (void)testNSDataFormateByCWithInputFormate2
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    
    NSDate *target = [formatter dateFromString:@"2013.01.01 00:00:00"];
    
    NSString *formate = tmStringNSDateByC(target, "%Y.%m.%d - %H:%M:%S%z");
    
    STAssertEqualObjects(formate, @"2012.12.31 - 16:00:00+0800", @"default formate wrong");
}

@end
