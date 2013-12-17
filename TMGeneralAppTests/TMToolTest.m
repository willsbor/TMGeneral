//
//  TMToolTest.m
//  TMGeneral
//
//  Created by willsborKang on 13/4/9.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TMTools.h"
#import <objc/runtime.h>

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

- (void) testString2NSDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];

    NSDate *target = [formatter dateFromString:@"2013.01.01 00:00:00"];
    
    NSDate *result = tmNSDateString(@"2013.01.01 00:00:00", @"yyyy.MM.dd HH:mm:ss");
    
    STAssertEqualObjects(target, result, nil);
}

- (void) testString2NSDateWithNil
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy.MM.dd HH:mm"];
    
    NSDate *target = [formatter dateFromString:@"2013.01.01 00:10"];
    
    NSDate *result = tmNSDateString(@"2013.01.01 00:10", nil);
    
    STAssertEqualObjects(target, result, nil);
}

- (NSString *) systemVersion_4_3
{
    return @"4.3";
}

- (NSString *) systemVersion_5_0
{
    return @"5.0";
}

- (NSString *) systemVersion_6_0
{
    return @"6.0";
}

- (NSString *) systemVersion_6_1
{
    return @"6.1";
}

- (NSString *) systemVersion_7_0
{
    return @"7.0";
}

- (NSString *) systemVersion_7_0_2
{
    return @"7.0.2";
}

- (NSString *) systemVersion_7_1
{
    return @"7.1";
}

- (NSString *) temp
{
    return @"temp";
}

- (void) testActionIfEqualOrGreaterThen5
{
    
    Method origMethod = class_getInstanceMethod([[UIDevice currentDevice] class], @selector(systemVersion));
    Method tempMethod = class_getInstanceMethod([self class], @selector(temp));
	Method methodReturn4_3 = class_getInstanceMethod([self class], @selector(systemVersion_4_3));
	Method methodReturn5_0 = class_getInstanceMethod([self class], @selector(systemVersion_5_0));
	Method methodReturn6_0 = class_getInstanceMethod([self class], @selector(systemVersion_6_0));
	Method methodReturn6_1 = class_getInstanceMethod([self class], @selector(systemVersion_6_1));
	Method methodReturn7_0 = class_getInstanceMethod([self class], @selector(systemVersion_7_0));
	Method methodReturn7_0_2 = class_getInstanceMethod([self class], @selector(systemVersion_7_0_2));
	Method methodReturn7_1 = class_getInstanceMethod([self class], @selector(systemVersion_7_1));
    
	method_setImplementation(tempMethod, method_getImplementation(origMethod));
    
    method_setImplementation(origMethod, method_getImplementation(methodReturn4_3));
    STAssertEqualObjects([[UIDevice currentDevice] systemVersion], [self systemVersion_4_3], nil);
    tmActionIfEqualOrGreaterThen5(^{
        STAssertTrue(FALSE, @"now ver = %@ (>= iOS5) ", [[UIDevice currentDevice] systemVersion]);
    }, ^{
        
    });

    tmActionIfEqualOrGreaterThen6(^{
        STAssertTrue(FALSE, @"now ver = %@ (>= iOS6) ", [[UIDevice currentDevice] systemVersion]);
    }, ^{

    });
    
    tmActionIfEqualOrGreaterThen7(^{
        STAssertTrue(FALSE, @"now ver = %@ (>= iOS7) ", [[UIDevice currentDevice] systemVersion]);
    }, ^{
        
    });
    tmCleanToolsCaches();
    
    
    method_setImplementation(origMethod, method_getImplementation(methodReturn5_0));
    STAssertEqualObjects([[UIDevice currentDevice] systemVersion], [self systemVersion_5_0], nil);
    tmActionIfEqualOrGreaterThen5(^{
        
    }, ^{
        STAssertTrue(FALSE, @"now ver = %@ (< iOS5) ", [[UIDevice currentDevice] systemVersion]);
    });
    
    tmActionIfEqualOrGreaterThen6(^{
        STAssertTrue(FALSE, @"now ver = %@ (>= iOS6) ", [[UIDevice currentDevice] systemVersion]);
    }, ^{
        
    });
    
    tmActionIfEqualOrGreaterThen7(^{
        STAssertTrue(FALSE, @"now ver = %@ (>= iOS7) ", [[UIDevice currentDevice] systemVersion]);
    }, ^{
        
    });
    tmCleanToolsCaches();
    
    method_setImplementation(origMethod, method_getImplementation(methodReturn6_0));
    STAssertEqualObjects([[UIDevice currentDevice] systemVersion], [self systemVersion_6_0], nil);
    tmActionIfEqualOrGreaterThen5(^{
        
    }, ^{
        STAssertTrue(FALSE, @"now ver = %@ (< iOS5) ", [[UIDevice currentDevice] systemVersion]);
    });
    
    tmActionIfEqualOrGreaterThen6(^{
        
    }, ^{
        STAssertTrue(FALSE, @"now ver = %@ (< iOS6) ", [[UIDevice currentDevice] systemVersion]);
    });
    
    tmActionIfEqualOrGreaterThen7(^{
        STAssertTrue(FALSE, @"now ver = %@ (>= iOS7) ", [[UIDevice currentDevice] systemVersion]);
    }, ^{
        
    });
    tmCleanToolsCaches();
    
    method_setImplementation(origMethod, method_getImplementation(methodReturn6_1));
    STAssertEqualObjects([[UIDevice currentDevice] systemVersion], [self systemVersion_6_1], nil);
    tmActionIfEqualOrGreaterThen5(^{
        
    }, ^{
        STAssertTrue(FALSE, @"now ver = %@ (< iOS5) ", [[UIDevice currentDevice] systemVersion]);
    });
    
    tmActionIfEqualOrGreaterThen6(^{
        
    }, ^{
        STAssertTrue(FALSE, @"now ver = %@ (< iOS6) ", [[UIDevice currentDevice] systemVersion]);
    });
    
    tmActionIfEqualOrGreaterThen7(^{
        STAssertTrue(FALSE, @"now ver = %@ (>= iOS7) ", [[UIDevice currentDevice] systemVersion]);
    }, ^{
        
    });
    tmCleanToolsCaches();
    
    method_setImplementation(origMethod, method_getImplementation(methodReturn7_0));
    STAssertEqualObjects([[UIDevice currentDevice] systemVersion], [self systemVersion_7_0], nil);
    tmActionIfEqualOrGreaterThen5(^{
        
    }, ^{
        STAssertTrue(FALSE, @"now ver = %@ (< iOS5) ", [[UIDevice currentDevice] systemVersion]);
    });
    
    tmActionIfEqualOrGreaterThen6(^{
        
    }, ^{
        STAssertTrue(FALSE, @"now ver = %@ (< iOS6) ", [[UIDevice currentDevice] systemVersion]);
    });
    
    tmActionIfEqualOrGreaterThen7(^{
        
    }, ^{
        STAssertTrue(FALSE, @"now ver = %@ (< iOS7) ", [[UIDevice currentDevice] systemVersion]);
    });
    tmCleanToolsCaches();
    
    method_setImplementation(origMethod, method_getImplementation(methodReturn7_0_2));
    STAssertEqualObjects([[UIDevice currentDevice] systemVersion], [self systemVersion_7_0_2], nil);
    tmActionIfEqualOrGreaterThen5(^{
        
    }, ^{
        STAssertTrue(FALSE, @"now ver = %@ (< iOS5) ", [[UIDevice currentDevice] systemVersion]);
    });
    
    tmActionIfEqualOrGreaterThen6(^{
        
    }, ^{
        STAssertTrue(FALSE, @"now ver = %@ (< iOS6) ", [[UIDevice currentDevice] systemVersion]);
    });
    
    tmActionIfEqualOrGreaterThen7(^{
        
    }, ^{
        STAssertTrue(FALSE, @"now ver = %@ (< iOS7) ", [[UIDevice currentDevice] systemVersion]);
    });
    tmCleanToolsCaches();
    
    method_setImplementation(origMethod, method_getImplementation(methodReturn7_1));
    STAssertEqualObjects([[UIDevice currentDevice] systemVersion], [self systemVersion_7_1], nil);
    tmActionIfEqualOrGreaterThen5(^{
        
    }, ^{
        STAssertTrue(FALSE, @"now ver = %@ (< iOS5) ", [[UIDevice currentDevice] systemVersion]);
    });
    
    tmActionIfEqualOrGreaterThen6(^{
        
    }, ^{
        STAssertTrue(FALSE, @"now ver = %@ (< iOS6) ", [[UIDevice currentDevice] systemVersion]);
    });
    
    tmActionIfEqualOrGreaterThen7(^{
        
    }, ^{
        STAssertTrue(FALSE, @"now ver = %@ (< iOS7) ", [[UIDevice currentDevice] systemVersion]);
    });
    tmCleanToolsCaches();
    
    method_setImplementation(origMethod, method_getImplementation(tempMethod));
    //STAssertEqualObjects([[UIDevice currentDevice] systemVersion], @"5.1", nil);
}

@end
