//
//  TMApiAction.h
//  TMGeneral
//
//  Created by mac on 12/10/13.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TMApiData : NSManagedObject

@property (nonatomic, strong) NSNumber * cacheType;
@property (nonatomic, strong) NSData * content;
@property (nonatomic, strong) NSDate * createTime;
@property (nonatomic, strong) NSString * identify;
@property (nonatomic, strong) NSDate * lastActionTime;
@property (nonatomic, strong) NSString * objectName;
@property (nonatomic, strong) NSNumber * type;
@property (nonatomic, strong) NSNumber * state;
@property (nonatomic, strong) NSNumber * mode;
@property (nonatomic, strong) NSNumber * retryTimes;
@property (nonatomic, strong) NSNumber * retryDelayTime;

@end
