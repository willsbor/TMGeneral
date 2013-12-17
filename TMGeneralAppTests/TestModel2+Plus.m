//
//  TestModel2+Plus.m
//  TMGeneral
//
//  Created by willsborKang on 13/12/17.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import "TestModel2+Plus.h"

@implementation TestModel2 (Plus)

- (void)addModel4sObject:(NSManagedObject *)value
{
    NSMutableOrderedSet *s = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.model4s];
    
    [s addObject:value];
    
    self.model4s = s;
}

- (void)removeModel4s:(NSOrderedSet *)values
{
    NSMutableOrderedSet *s = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.model4s];
    
    [s removeObjectsInArray:[values array]];
    
    self.model4s = s;
}

- (void)removeModel4sObject:(NSManagedObject *)value
{
    NSMutableOrderedSet *s = [[NSMutableOrderedSet alloc] initWithOrderedSet:self.model4s];
    
    [s removeObject:value];
    
    self.model4s = s;
}


@end
