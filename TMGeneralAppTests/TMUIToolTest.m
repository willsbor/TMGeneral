//
//  TMUIToolTest.m
//  TMGeneral
//
//  Created by willsborKang on 13/4/18.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TMUITools.h"
#import "TMTools.h"
#import <objc/runtime.h>

@interface TMUIToolTest : SenTestCase

@end


@implementation TMUIToolTest

static NSString *g_testSystemVersion = @"7.0";
- (NSString *) systemVersion
{
    return g_testSystemVersion;
}

- (NSString *) temp
{
    return @"temp";
}

- (void) _testOnSystem:(NSString *)aVersion testItem:(void (^)(NSString *originSystemVersion))aTestItem
{
    g_testSystemVersion = [aVersion copy];
    
    NSString *originSyetemVersion = [[UIDevice currentDevice] systemVersion];
    
    Method origMethod = class_getInstanceMethod([[UIDevice currentDevice] class], @selector(systemVersion));
    Method tempMethod = class_getInstanceMethod([self class], @selector(temp));
	Method methodReturn = class_getInstanceMethod([self class], @selector(systemVersion));
	
    method_setImplementation(tempMethod, method_getImplementation(origMethod));
    
    method_setImplementation(origMethod, method_getImplementation(methodReturn));
    STAssertEqualObjects([[UIDevice currentDevice] systemVersion], [self systemVersion], nil);
    
    tmCleanToolsCaches();
    if (aTestItem) aTestItem(originSyetemVersion);
    tmCleanToolsCaches();
    
    method_setImplementation(origMethod, method_getImplementation(tempMethod));
}


- (void) _checkDiff:(NSString *)aNowVersion greaterThan7:(void (^)(void))aiOS7Action other:(void (^)(void))aOtherAction
{
    if ([aNowVersion floatValue] >= 7.0) {
        aiOS7Action();
    }
    else {
        aOtherAction();
    }
}

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
    [self _checkDiff:[[UIDevice currentDevice] systemVersion]
        greaterThan7:^{
            STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)23.52, 0, nil);
            STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)14, 0, nil);
            
        }
               other:^{
                   STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)24.0, 0, nil);
                   STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)15.0, 0, nil);
               }];
    
    label.text = @"123\n123";
    tmLabelSizeFitTextSize(label, 320);
    [self _checkDiff:[[UIDevice currentDevice] systemVersion]
        greaterThan7:^{
            STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)23.52, 0, nil);
            STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)28, 0, nil);
            
        }
               other:^{
                   STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)24.0, 0, nil);
                   STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)30.0, 0, nil);
               }];

    label.text = @"123\n1234";
    tmLabelSizeFitTextSize(label, 320);
    [self _checkDiff:[[UIDevice currentDevice] systemVersion]
        greaterThan7:^{
            STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)31.360001, 0, nil);
            STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)28, 0, nil);
            
        }
               other:^{
                   STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)32.0, 0, nil);
                   STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)30.0, 0, nil);
               }];

    label.text = @"123\n1234";
    tmLabelSizeFitTextSize(label, 30);
    [self _checkDiff:[[UIDevice currentDevice] systemVersion]
        greaterThan7:^{
            STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)23.52, 0, nil);
            STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)42, 0, nil);
            
        }
               other:^{
                   STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)24.0, 0, nil);
                   STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)45.0, 0, nil);
               }];

    label.text = @"123\n12345678";
    tmLabelSizeFitTextSize(label, 30);
    [self _checkDiff:[[UIDevice currentDevice] systemVersion]
        greaterThan7:^{
            STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)23.52, 0, nil);
            STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)56, 0, nil);
            
        }
               other:^{
                   STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)24.0, 0, nil);
                   STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)60.0, 0, nil);
               }];

}

- (void) testLabelSizeFitTextSizeWidth
{
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, 320, 40))];
    label.font = [UIFont fontWithName:@"Tamil Sangam MN" size:14];
    
    label.text = @"123";
    tmLabelSizeFitTextSizeWidth(label, 320);
    [self _checkDiff:[[UIDevice currentDevice] systemVersion]
        greaterThan7:^{
            STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)23.52, 0, nil);
            STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)40, 0, nil);
            
        }
               other:^{
                   STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)24.0, 0, nil);
                   STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)40.0, 0, nil);
               }];
    
    label.text = @"123\n123";
    tmLabelSizeFitTextSizeWidth(label, 320);
    [self _checkDiff:[[UIDevice currentDevice] systemVersion]
        greaterThan7:^{
            STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)23.52, 0, nil);
            STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)40, 0, nil);
            
        }
               other:^{
                   STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)24.0, 0, nil);
                   STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)40.0, 0, nil);
               }];
    
    label.text = @"123\n1234";
    tmLabelSizeFitTextSizeWidth(label, 320);
    [self _checkDiff:[[UIDevice currentDevice] systemVersion]
        greaterThan7:^{
            STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)31.360001, 0, nil);
            STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)40, 0, nil);
            
        }
               other:^{
                   STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)32.0, 0, nil);
                   STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)40, 0, nil);
               }];

    
    label.text = @"123\n1234\n12345";
    tmLabelSizeFitTextSizeWidth(label, 320);
    [self _checkDiff:[[UIDevice currentDevice] systemVersion]
        greaterThan7:^{
            STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)39.200001, 0, nil);
            STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)42, 0, nil);
            
        }
               other:^{
                   STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)40.0, 0, nil);
                   STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)45.0, 0, nil);
               }];

}

- (void) testLabelSizeFitTextSizeHeight
{
    
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRectMake(0, 0, 30, 40))];
    label.font = [UIFont fontWithName:@"Tamil Sangam MN" size:14];
    
    label.text = @"123";
    tmLabelSizeFitTextSizeHeight(label, 320);
    [self _checkDiff:[[UIDevice currentDevice] systemVersion]
        greaterThan7:^{
            STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)30, 0, nil);
            STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)14, 0, nil);
            
        }
               other:^{
            STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)30, 0, nil);
            STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)15, 0, nil);
        }];
    
    label.text = @"123\n123";
    tmLabelSizeFitTextSizeHeight(label, 320);
    [self _checkDiff:[[UIDevice currentDevice] systemVersion]
        greaterThan7:^{
            STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)30, 0, nil);
            STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)28, 0, nil);
            
        }
               other:^{
                   STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)30, 0, nil);
                   STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)30, 0, nil);
               }];
    
    
    label.text = @"123\n1234";
    tmLabelSizeFitTextSizeHeight(label, 320);
    [self _checkDiff:[[UIDevice currentDevice] systemVersion]
        greaterThan7:^{
            STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)31.360001, 0, nil);
            STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)28, 0, nil);
            
        }
               other:^{
                   STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)32.0, 0, nil);
                   STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)30, 0, nil);
               }];
    
    
    label.text = @"123\n1234\n12345";
    tmLabelSizeFitTextSizeHeight(label, 320);
    [self _checkDiff:[[UIDevice currentDevice] systemVersion]
        greaterThan7:^{
            STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)39.200001, 0, nil);
            STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)42, 0, nil);
            
        }
               other:^{
                   STAssertEqualsWithAccuracy(CGRectGetWidth(label.frame), (CGFloat)40.0, 0, nil);
                   STAssertEqualsWithAccuracy(CGRectGetHeight(label.frame), (CGFloat)45.0, 0, nil);
               }];
    
}

- (void) testStringSizeFunction
{
    UIFont *font = [UIFont fontWithName:@"Tamil Sangam MN" size:14];
    CGSize s = tmStringSize(@"123", font, 320);
    
    [self _checkDiff:[[UIDevice currentDevice] systemVersion]
        greaterThan7:^{
            CGSize targetS = CGSizeMake(23.52, 14);
            STAssertEquals(s, targetS, nil);
        } other:^{
            CGSize targetS = CGSizeMake(24, 15);
            STAssertEquals(s, targetS, nil);
        }];
        
}

@end
