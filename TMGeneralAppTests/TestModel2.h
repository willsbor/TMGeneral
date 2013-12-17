//
//  TestModel2.h
//  TMGeneral
//
//  Created by willsborKang on 13/12/13.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TestModel2 : NSManagedObject

@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSSet *model3s;
@property (nonatomic, retain) NSOrderedSet *model4s;
@end

@interface TestModel2 (CoreDataGeneratedAccessors)

- (void)addModel3sObject:(NSManagedObject *)value;
- (void)removeModel3sObject:(NSManagedObject *)value;
- (void)addModel3s:(NSSet *)values;
- (void)removeModel3s:(NSSet *)values;

- (void)insertObject:(NSManagedObject *)value inModel4sAtIndex:(NSUInteger)idx;
- (void)removeObjectFromModel4sAtIndex:(NSUInteger)idx;
- (void)insertModel4s:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeModel4sAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInModel4sAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceModel4sAtIndexes:(NSIndexSet *)indexes withModel4s:(NSArray *)values;
- (void)addModel4sObject:(NSManagedObject *)value;
- (void)removeModel4sObject:(NSManagedObject *)value;
- (void)addModel4s:(NSOrderedSet *)values;
- (void)removeModel4s:(NSOrderedSet *)values;
@end
