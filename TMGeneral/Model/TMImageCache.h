//
//  TMImageCache.h
//  TMGeneral
//
//  Created by willsborKang on 13/4/19.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TMImageCache : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * identify;
@property (nonatomic, retain) NSDate * lastDate;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSNumber * type;

@end
