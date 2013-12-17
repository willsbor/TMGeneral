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

- (void) testLabelSizeFitTextSize
{
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, 320, 40))];
    label.font = [UIFont fontWithName:@"Tamil Sangam MN" size:14];
    
    label.text = @"123";
    tmLabelSizeFitTextSize(label, 320);
    STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)24.0, 0, nil);
    STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)15.0, 0, nil);
    
    label.text = @"123\n123";
    tmLabelSizeFitTextSize(label, 320);
    STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)24.0, 0, nil);
    STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)30.0, 0, nil);

    label.text = @"123\n1234";
    tmLabelSizeFitTextSize(label, 320);
    STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)32.0, 0, nil);
    STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)30.0, 0, nil);

    label.text = @"123\n1234";
    tmLabelSizeFitTextSize(label, 30);
    STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)24.0, 0, nil);
    STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)45.0, 0, nil);
}

- (void) testLabelSizeFitTextSizeWidth
{
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, 320, 40))];
    label.font = [UIFont fontWithName:@"Tamil Sangam MN" size:14];
    
    label.text = @"123";
    tmLabelSizeFitTextSizeWidth(label, 320);
    STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)24.0, 0, nil);
    STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)40, 0, nil);
    
    label.text = @"123\n123";
    tmLabelSizeFitTextSizeWidth(label, 320);
    STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)24.0, 0, nil);
    STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)40, 0, nil);
    
    label.text = @"123\n1234";
    tmLabelSizeFitTextSizeWidth(label, 320);
    STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)32.0, 0, nil);
    STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)40, 0, nil);
    
    label.text = @"123\n1234\n12345";
    tmLabelSizeFitTextSizeWidth(label, 320);
    STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)40.0, 0, nil);
    STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)45.0, 0, nil);
}

- (void) testLabelSizeFitTextSizeHeight
{
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, 30, 40))];
    label.font = [UIFont fontWithName:@"Tamil Sangam MN" size:14];
    
    label.text = @"123";
    tmLabelSizeFitTextSizeHeight(label, 320);
    STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)30, 0, nil);
    STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)15, 0, nil);
    
    label.text = @"123\n123";
    tmLabelSizeFitTextSizeHeight(label, 320);
    STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)30, 0, nil);
    STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)30, 0, nil);
    
    label.text = @"123\n1234";
    tmLabelSizeFitTextSizeHeight(label, 320);
    STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)32.0, 0, nil);
    STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)30, 0, nil);
    
    label.text = @"123\n1234\n12345";
    tmLabelSizeFitTextSizeHeight(label, 320);
    STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)40.0, 0, nil);
    STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)45.0, 0, nil);
}

@end
