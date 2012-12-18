//
//  TMDataManager.h
//  TMGeneral
//
//  Created by kang on 12/10/10.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const DataManagerDidSaveFailedTag;
extern NSString * const DataManagerCreateDirectoryFailedTag;
extern NSString * const DataManagerFatalErrorCreatePersistentStoreTag;

extern NSString * const DataManagerDidSaveNotification;
extern NSString * const DataManagerDidSaveFailedNotification;

@interface TMDataManager : NSObject

@property (nonatomic, readonly, strong) NSManagedObjectContext *mainObjectContext;

//+ (void) setDefaultProjectModel:(NSString *)aProjectModel;
//+ (TMDataManager *) defaultProjectDB;
+ (TMDataManager *) sharedInstance;

- (void) errorHandlerTarget:(void (^)(NSString *errorTag, NSError *error)) errorBlock;

- (BOOL)save;

- (NSData *) dataFromNSData:(id)aObject;
- (id) objectFormNSData:(NSData *)aData;

@end
