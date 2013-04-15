//
//  GlobalModel.m
//  TMGeneral
//
//  Created by willsborKang on 13/4/15.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TMGlobalModel.h"

@interface GlobalModel : SenTestCase

@end

@implementation GlobalModel

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

- (void)testGetAppMode
{
    TMGlobalModel *gm = [[TMGlobalModel alloc] init];
    [gm clearAppMode];
    
    TMGlobal_AppMode mode = [gm appMode];
    
    STAssertEquals(mode, TMGlobal_AppMode_Develop, @"預設default為 develop");
}

- (void)testSetAppMode
{
    TMGlobalModel *gm = [[TMGlobalModel alloc] init];
    [gm clearAppMode];
    
    TMGlobal_AppMode mode = [gm appMode];
    
    STAssertEquals(mode, TMGlobal_AppMode_Develop, @"預設default為 develop");
    
    [gm setAppMode:(TMGlobal_AppMode_Release)];
    
    mode = [gm appMode];
    
    STAssertEquals(mode, TMGlobal_AppMode_Release, @"");

}

- (void)testSetDefaultAppMode
{
    TMGlobalModel *gm = [[TMGlobalModel alloc] init];
    [gm clearAppMode];
    
    TMGlobal_AppMode mode = [gm appMode];
    
    STAssertEquals(mode, TMGlobal_AppMode_Develop, @"預設default為 develop");
    
    [gm setDefaultAppMode:(TMGlobal_AppMode_Test)];
    
    mode = [gm appMode];
    
    STAssertEquals(mode, TMGlobal_AppMode_Test, @"");
    
}

- (void) testModeDictionary
{
    TMGlobalModel *gm = [[TMGlobalModel alloc] init];
    [gm clearAppMode];
    
    [gm setModeDictionary:@{@"Parse":@[@"123", @"456", @"789"],
                           @"Flurry":@[@"987", @"654", @"321"],}];
    
    NSString *v = [gm objectOfClass:@"Parse"];
    STAssertEqualObjects(v, @"456", @"預設default為 develop = 456");
    
    [gm setAppMode:(TMGlobal_AppMode_Release)];
    v = [gm objectOfClass:@"Parse"];
    STAssertEqualObjects(v, @"123", @"release = 123");
    
    [gm setAppMode:(TMGlobal_AppMode_Release)];
    v = [gm objectOfClass:@"Flurry"];
    STAssertEqualObjects(v, @"987", @"release = 987");
}

@end
