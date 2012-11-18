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

@property (nonatomic, retain) NSNumber * cacheType;
@property (nonatomic, retain) NSData * content;
@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSString * identify;
@property (nonatomic, retain) NSDate * lastActionTime;
@property (nonatomic, retain) NSString * objectName;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSNumber * mode;
@property (nonatomic, retain) NSNumber * retryTimes;
@property (nonatomic, retain) NSNumber * retryDelayTime;

@end
