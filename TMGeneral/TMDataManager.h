//
//  TMDataManager.h
//  TMGeneral
//
//  Created by kang on 12/10/10.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const DataManagerDidSaveNotification;
extern NSString * const DataManagerDidSaveFailedNotification;

@interface TMDataManager : NSObject {
}

@property (nonatomic, readonly, retain) NSManagedObjectModel *objectModel;
@property (nonatomic, readonly, retain) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, readonly, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (void) setDefaultProjectModel:(NSString *)aProjectModel;
+ (TMDataManager *) defaultProjectDB;
+ (TMDataManager *)sharedInstance;
- (BOOL)save;
- (NSManagedObjectContext*)managedObjectContext;  ///< 先不要用這個

- (NSData *) dataFromNSData:(id)aObject;
- (id) objectFormNSData:(NSData *)aData;

@end
