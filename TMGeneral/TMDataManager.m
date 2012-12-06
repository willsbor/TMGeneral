//
//  TMDataManager.m
//  TMGeneral
//
//  Created by kang on 12/10/10.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import "TMDataManager.h"

typedef void (^TMDataManagerErrorBlock)(NSString *errorTag, NSError *error);

NSString * const DataManagerDidSaveFailedTag = @"DataManagerDidSaveFailedTag";
NSString * const DataManagerCreateDirectoryFailedTag = @"DataManagerCreateDirectoryFailedTag";
NSString * const DataManagerFatalErrorCreatePersistentStoreTag = @"DataManagerFatalErrorCreatePersistentStoreTag";

NSString * const DataManagerDidSaveNotification = @"DataManagerDidSaveNotification";
NSString * const DataManagerDidSaveFailedNotification = @"DataManagerDidSaveFailedNotification";

@interface TMDataManager () {
    TMDataManagerErrorBlock _errorBlock;
}

- (NSString*)sharedDocumentsPath;

@property (nonatomic, retain) NSString *kDataManagerBundleName;
@property (nonatomic, retain) NSString *kDataManagerModelName;
@property (nonatomic, retain) NSString *kDataManagerSQLiteName;

@end

@implementation TMDataManager

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize mainObjectContext = _mainObjectContext;
@synthesize objectModel = _objectModel;

//NSString * const kDataManagerBundleName = @"TMGeneralResource";
//NSString * const kDataManagerModelName = @"TMGeneralDataModel";
//NSString * const kDataManagerSQLiteName = @"TMGeneralDataSQL.sqlite";

+ (TMDataManager *)sharedInstance {
	static dispatch_once_t pred;
	static TMDataManager *sharedInstance = nil;
    
	dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.kDataManagerBundleName = @"TMGeneralResource";
        sharedInstance.kDataManagerModelName = @"TMGeneralDataModel";
        sharedInstance.kDataManagerSQLiteName = @"TMGeneralDataSQL.sqlite";
    });
	return sharedInstance;
}

static NSString *g_defaultProjectName = nil;
+ (void) setDefaultProjectModel:(NSString *)aProjectModel
{
    [g_defaultProjectName release];
    g_defaultProjectName = [aProjectModel retain];
}

+ (TMDataManager *) defaultProjectDB
{
    static dispatch_once_t pred;
	static TMDataManager *sharedInstance = nil;
    
	dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.kDataManagerBundleName = nil;
        
        if (g_defaultProjectName == nil) {
            g_defaultProjectName = [[NSString stringWithFormat:@"TMDataProject"] retain];
        }
        
        sharedInstance.kDataManagerModelName = g_defaultProjectName;
        sharedInstance.kDataManagerSQLiteName = [NSString stringWithFormat:@"%@.sqlite", g_defaultProjectName];
    });
	return sharedInstance;
}

- (void) errorHandlerTarget:(void (^)(NSString *errorTag, NSError *error)) errorBlock
{
    [_errorBlock release];
    _errorBlock = [errorBlock retain];
}

- (id)init
{
    self = [super init];
    if (self) {
        _errorBlock = nil;
    }
    return self;
}

- (void)dealloc {
	[self save];
    
    [_errorBlock release];
	[_persistentStoreCoordinator release];
	[_mainObjectContext release];
	[_objectModel release];
    
	[super dealloc];
}

- (NSData *) dataFromNSData:(id)aObject
{
    NSMutableData *inputData = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:inputData];
    [archiver encodeObject:aObject forKey:@"inputParam"];
    [archiver finishEncoding];
    [archiver release];
    
    return [inputData autorelease];
}

- (id) objectFormNSData:(NSData *)aData
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:aData];
    NSObject *object = [unarchiver decodeObjectForKey:@"inputParam"];
    [object retain];

    [unarchiver finishDecoding];
    [unarchiver release];
    
    return [object autorelease];
}

- (NSManagedObjectModel*)objectModel {
	if (_objectModel)
		return _objectModel;
    
	NSBundle *bundle = [NSBundle mainBundle];
	if (_kDataManagerBundleName) {
		NSString *bundlePath = [[NSBundle mainBundle] pathForResource:_kDataManagerBundleName ofType:@"bundle"];
		bundle = [NSBundle bundleWithPath:bundlePath];
	}
	NSString *modelPath = [bundle pathForResource:_kDataManagerModelName ofType:@"momd"];
	_objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
    
	return _objectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
	if (_persistentStoreCoordinator)
		return _persistentStoreCoordinator;
    
	// Get the paths to the SQLite file
	NSString *storePath = [[self sharedDocumentsPath] stringByAppendingPathComponent:_kDataManagerSQLiteName];
	NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    
	// Define the Core Data version migration options
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             nil];
    
	// Attempt to load the persistent store
	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.objectModel];
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
        if (_errorBlock) {
            _errorBlock(DataManagerFatalErrorCreatePersistentStoreTag, error);
        }
        
		NSLog(@"Fatal error while creating persistent store: %@", error);
		abort();
	}
    
	return _persistentStoreCoordinator;
}

- (NSManagedObjectContext*)mainObjectContext {
	if (_mainObjectContext)
		return _mainObjectContext;
    
	// Create the main context only on the main thread
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(mainObjectContext)
                               withObject:nil
                            waitUntilDone:YES];
		return _mainObjectContext;
	}
    
	_mainObjectContext = [[NSManagedObjectContext alloc] init];
	[_mainObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
	return _mainObjectContext;
}

- (BOOL)save {
	if (![self.mainObjectContext hasChanges])
		return YES;
    
	NSError *error = nil;
	if (![self.mainObjectContext save:&error]) {
		NSLog(@"Error while saving: %@\n%@", [error localizedDescription], [error userInfo]);
		[[NSNotificationCenter defaultCenter] postNotificationName:DataManagerDidSaveFailedNotification
                                                            object:error];
        
        if (_errorBlock) _errorBlock(DataManagerDidSaveFailedTag, error);
		return NO;
	}
    
	[[NSNotificationCenter defaultCenter] postNotificationName:DataManagerDidSaveNotification object:nil];
	return YES;
}

- (NSString*)sharedDocumentsPath {
	static NSString *SharedDocumentsPath = nil;
	if (SharedDocumentsPath)
		return SharedDocumentsPath;
    
	// Compose a path to the <Library>/Database directory
	NSString *libraryPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] retain];
    [libraryPath release];
	SharedDocumentsPath = [[libraryPath stringByAppendingPathComponent:@"Database"] retain];
    
	// Ensure the database directory exists
	NSFileManager *manager = [NSFileManager defaultManager];
	BOOL isDirectory;
	if (![manager fileExistsAtPath:SharedDocumentsPath isDirectory:&isDirectory] || !isDirectory) {
		NSError *error = nil;
		NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                         forKey:NSFileProtectionKey];
		[manager createDirectoryAtPath:SharedDocumentsPath
		   withIntermediateDirectories:YES
                            attributes:attr
                                 error:&error];
		if (error) {
			NSLog(@"Error creating directory path: %@", [error localizedDescription]);
            if (_errorBlock) _errorBlock(DataManagerCreateDirectoryFailedTag, error);
        }
	}
    
	return SharedDocumentsPath;
}

- (NSManagedObjectContext*)managedObjectContext {
	NSManagedObjectContext *ctx = [[[NSManagedObjectContext alloc] init] autorelease];
	[ctx setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
	return ctx;
}

@end
