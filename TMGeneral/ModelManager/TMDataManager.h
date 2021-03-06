/*
 TMDataManager.h
 
 Copyright (c) 2012 willsbor Kang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface TMDataManager : NSObject {
@private

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
/**
 * 將 NSDictionary or NSArray 轉換成 NSData
 */
+ (NSData *) dataFromNSData:(id)aObject;

/**
 * 將 NSData 轉換成 NSDictionary or NSArray
 */
+ (id) objectFormNSData:(NSData *)aData;

- (NSFetchedResultsController *) createFetchResultsControllerWithEntityForName:(NSString *)aEntity
                                                                  andPredicate:(NSPredicate *)predicate
                                                                      andSorts:(NSArray *)sorts
                                                                  andCacheName:(NSString *)aCacheName
                                                                andSectionName:(NSString *)aSectionName;

- (NSFetchedResultsController *) createFetchResultsControllerWithEntityForName:(NSString *)aEntity
                                                                  andPredicate:(NSPredicate *)predicate
                                                                      andSorts:(NSArray *)sorts
                                                                  andCacheName:(NSString *)aCacheName;

- (NSFetchedResultsController *) createFetchResultsControllerOnMainWithEntityForName:(NSString *)aEntity
                                                                  andPredicate:(NSPredicate *)predicate
                                                                      andSorts:(NSArray *)sorts
                                                                  andCacheName:(NSString *)aCacheName
                                                                andSectionName:(NSString *)aSectionName;

- (NSFetchedResultsController *) createFetchResultsControllerOnMainWithEntityForName:(NSString *)aEntity
                                                                  andPredicate:(NSPredicate *)predicate
                                                                      andSorts:(NSArray *)sorts
                                                                  andCacheName:(NSString *)aCacheName;

/**
 * 設定這次專案產生的檔案，所屬的資料夾的名稱
 */
+ (void) setAppName:(NSString *)aAppName;

/**
 * 依照給予的keys 拿取單一物件內參數，用一個 dictionary 回傳
 * Warning 一次只能拿一個物件
 * @param aClassName 物件類別
 * @param aKeys 要拿取的參數 string array
 * @param pred 判斷物件的條件
 * @return 物件資料
 */
- (NSDictionary *) objectValuesFor:(NSString *)aClassName WithKeys:(NSArray *)aKeys andPredicate:(NSPredicate *)pred;

/**
 * 回傳資料庫中是否能找到符合條件該物件
 * @param aClassName 物件類別
 * @param pred 判斷物件的條件
 */
- (BOOL) isNoneFor:(NSString *)aClassName andPredicate:(NSPredicate *)pred;

/**
 * release data manager相關的參數
 */
- (void) closeMOCandPSCComplete:(void (^)(void))aComplete;

/**
 * release data manager相關的參數 並且刪除該產生出來的 sqlite 的檔案 (如果是 NSSQLiteStoreType )
 */
- (void) closeMOCandPSCWtihDeleteDataBaseFileComplete:(void (^)(void))aComplete;

/**
 * 專案中的 DataManager 對應到 xcoredatamodel的檔案名稱
 *
 * overrite me If need
 */
- (NSString *)managedObjectModelName;

@end

