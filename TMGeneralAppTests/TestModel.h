//
//  TestModel.h
//  TMGeneral
//
//  Created by willsborKang on 13/11/11.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TestModel : NSManagedObject

@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSString * tag;

@end
