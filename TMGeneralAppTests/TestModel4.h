//
//  TestModel4.h
//  TMGeneral
//
//  Created by willsborKang on 13/12/16.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TestModel2;

@interface TestModel4 : NSManagedObject

@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) TestModel2 *model2;

@end
