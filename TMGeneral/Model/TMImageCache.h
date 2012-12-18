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

@property (nonatomic, strong) NSData * data;
@property (nonatomic, strong) NSString * identify;
@property (nonatomic, strong) NSDate * lastDate;
@property (nonatomic, strong) NSString * tag;
@property (nonatomic, strong) NSNumber * type;

@end
