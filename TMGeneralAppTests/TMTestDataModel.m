//
//  TMTestDataModel.m
//  TMGeneral
//
//  Created by willsborKang on 13/11/11.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import "TMTestDataModel.h"

@implementation TMTestDataModel

static dispatch_once_t g_shared_instance_onceToken = 0;
+ (TMTestDataModel *)sharedInstance
{
	static TMTestDataModel *sharedInstance;
	dispatch_once(&g_shared_instance_onceToken, ^{
		sharedInstance = [[TMTestDataModel alloc] initWithDatabaseFilename:nil];
        [sharedInstance setSaveThreshold:10]; ///for test
	});
	
	return sharedInstance;
}

- (NSString *)managedObjectModelName
{
    return @"TMTestDataModel";
}

- (NSManagedObjectModel *)managedObjectModel
{
    NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    return mom;
}

@end
