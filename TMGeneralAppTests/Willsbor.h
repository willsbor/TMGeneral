//
//  Willsbor.h
//  TMGeneral
//
//  Created by willsborKang on 13/11/11.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Willsbor : NSManagedObject

@property (nonatomic, retain) NSDate * create_time;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * identify;

@end
