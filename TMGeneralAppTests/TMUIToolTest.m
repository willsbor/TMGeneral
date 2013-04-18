//
//  TMUIToolTest.m
//  TMGeneral
//
//  Created by willsborKang on 13/4/18.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TMUITools.h"

@interface TMUIToolTest : SenTestCase

@end


@implementation TMUIToolTest

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

- (void)testImageCutCenterNormal
{
    UIImage *image = [UIImage imageNamed:@"1041314117.jpg"];  ///< 362 × 480
    
    UIImage *cutter = tmImageCutCenter(image, CGSizeMake(200, 321));
    
    STAssertEquals(cutter.size.width, 200.0f, @"image Size wrong");
    STAssertEquals(cutter.size.height, 321.0f, @"image Size wrong");
}



@end
