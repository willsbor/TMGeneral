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
        [sharedInstance setSaveThreshold:10]; ///for test
	});
	
	return sharedInstance;
}

- (NSString *)managedObjectBundleName
{
    return @"TMGeneralResource";
}

- (NSString *)managedObjectModelName
{
    return @"TMGeneralDataModel";
}

- (void) save
{
    //// 儲存 的  狀況會有問題
    //[super save];
}

@end
