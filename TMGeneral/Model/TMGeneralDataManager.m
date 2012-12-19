//
//  TMGeneralDataManager.m
//  TMGeneral
//
//  Created by willsborKang on 12/12/19.
//  Copyright (c) 2012年 thinkermobile. All rights reserved.
//

#import "TMGeneralDataManager.h"
#import "TMDataManager+Protected.h"

@implementation TMGeneralDataManager


static TMGeneralDataManager *sharedInstance;

+ (TMGeneralDataManager *)sharedInstance
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		sharedInstance = [[TMGeneralDataManager alloc] initWithDatabaseFilename:nil];
	});
	
	return sharedInstance;
}

- (NSString *)managedObjectModelName
{
    return @"TMGeneralDataModel";
}

- (void) save
{
    [self save];
}

@end
