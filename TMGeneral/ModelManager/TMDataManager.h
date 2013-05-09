//
//  TMDataManager.h
//  TMGeneral
//
//  copy from XMPPFramework
//
//  Created by kang on 12/10/10.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//extern NSString * const DataManagerDidSaveFailedTag;
//extern NSString * const DataManagerCreateDirectoryFailedTag;
//extern NSString * const DataManagerFatalErrorCreatePersistentStoreTag;
//extern NSString * const DataManagerDidSaveNotification;
//extern NSString * const DataManagerDidSaveFailedNotification;

@interface TMDataManager : NSObject {
@private
	
	//NSMutableDictionary *myJidCache;
	
	int32_t pendingRequests;
	
	NSManagedObjectModel *managedObjectModel;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
	NSManagedObjectContext *managedObjectContext;
	NSManagedObjectContext *mainThreadManagedObjectContext;
	
@protected
	
	NSString *databaseFileName;
	NSUInteger saveThreshold;
	NSUInteger saveCount;
	
	dispatch_queue_t storageQueue;
    
    BOOL autoAllowExternalBinaryDataStorage;
	void *storageQueueTag;
    
}

/**
 * Initializes a core data storage instance, backed by SQLite, with the given database store filename.
 * It is recommended your database filname use the "sqlite" file extension (e.g. "XMPPRoster.sqlite").
 * If you pass nil, a default database filename is automatically used.
 * This default is derived from the classname,
 * meaning subclasses will get a default database filename derived from the subclass classname.
 *
 * If you attempt to create an instance of this class with the same databaseFileName as another existing instance,
 * this method will return nil.
 **/
- (id)initWithDatabaseFilename:(NSString *)databaseFileName;

/**
 * Initializes a core data storage instance, backed by an in-memory store.
 **/
- (id)initWithInMemoryStore;

/**
 * Readonly access to the databaseFileName used during initialization.
 * If nil was passed to the init method, returns the actual databaseFileName being used (the default filename).
 **/
@property (readonly) NSString *databaseFileName;

/**
 * The saveThreshold specifies the maximum number of unsaved changes to NSManagedObjects before a save is triggered.
 *
 * Since NSManagedObjectContext retains any changed objects until they are saved to disk
 * it is an important memory management concern to keep the number of changed objects within a healthy range.
 **/
@property (readwrite) NSUInteger saveThreshold;

/**
 * Provides access to the the thread-safe components of the CoreData stack.
 *
 * Please note:
 * The managedObjectContext is private to the storageQueue.
 * If you're on the main thread you can use the mainThreadManagedObjectContext.
 * Otherwise you must create and use your own managedObjectContext.
 *
 * If you think you can simply add a property for the private managedObjectContext,
 * then you need to go read the documentation for core data,
 * specifically the section entitled "Concurrency with Core Data".
 *
 * @see mainThreadManagedObjectContext
 **/
@property (strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 * Convenience method to get a managedObjectContext appropriate for use on the main thread.
 * This context should only be used from the main thread.
 *
 * NSManagedObjectContext is a light-weight thread-UNsafe component of the CoreData stack.
 * Thus a managedObjectContext should only be accessed from a single thread, or from a serialized queue.
 *
 * A managedObjectContext is associated with a persistent store.
 * In most cases the persistent store is an sqlite database file.
 * So think of a managedObjectContext as a thread-specific cache for the underlying database.
 *
 * This method lazily creates a proper managedObjectContext,
 * associated with the persistent store of this instance,
 * and configured to automatically merge changesets from other threads.
 **/
@property (strong, readonly) NSManagedObjectContext *mainThreadManagedObjectContext;

//// Tool
+ (NSData *) dataFromNSData:(id)aObject;
+ (id) objectFormNSData:(NSData *)aData;

- (NSFetchedResultsController *) createFetchResultsControllerWithEntityForName:(NSString *)aEntity
                                                                  andPredicate:(NSPredicate *)predicate
                                                                      andSorts:(NSArray *)sorts
                                                                  andCacheName:(NSString *)aCacheName;

//// overrite me If need
- (NSString *)managedObjectModelName;

@end

