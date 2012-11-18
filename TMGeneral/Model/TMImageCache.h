//
//  TMImageCache.h
//  TMGeneral
//
//  Created by mac on 12/10/14.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
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
