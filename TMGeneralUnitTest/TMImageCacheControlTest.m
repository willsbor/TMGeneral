//
//  TMImageCacheControlTest.m
//  TMGeneral
//
//  Created by willsborKang on 12/12/19.
//  Copyright (c) 2012年 thinkermobile. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "TMGeneralDataManager.h"
#import "TMImageCache.h"
#import "TMImageCacheControl.h"

#import <OCMock/OCMock.h>

#import <objc/runtime.h>

@interface TMGeneralDataManager (UTest)

@end

@implementation TMGeneralDataManager (UTest)

+ (void)load
{
	Method origMethod = class_getInstanceMethod(self, @selector(initWithDatabaseFilename:));
	Method newMethod = class_getInstanceMethod(self, @selector(initWithDatabaseFilename_override:));
	
	method_setImplementation(origMethod, method_getImplementation(newMethod));
    
    origMethod = class_getInstanceMethod(self, @selector(managedObjectModel));
	newMethod = class_getInstanceMethod(self, @selector(managedObjectModel_override));
    method_setImplementation(origMethod, method_getImplementation(newMethod));
}


- (id)initWithDatabaseFilename_override:(NSString *)aDatabaseFileName
{
	return [self initWithInMemoryStore];
}

- (NSManagedObjectModel *)managedObjectModel_override
{
    NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:[NSBundle allBundles]];
    return mom;
}

@end

@interface TMImageCacheControl ()

- (TMImageCache *) createCacheItemFrom:(NSString *)aUrl withTagMD5:(NSString *)aTagMD5 andType:(TMImageControl_Type)aType;
- (void) getDataFrom:(NSString *)aUrl AndSaveIn:(TMImageCache *)aItem;

@end

@interface TMImageCacheControlTest : SenTestCase <TMImageCacheControlPreloadProtocol>
{
    NSDate *asyncWaitUntil;
    int errcode;
}
@end

@implementation TMImageCacheControlTest

- (void) testNormal
{
    
    TMImageCacheControl *ICC = [TMImageCacheControl defaultTMImageCacheControl];

    UIImageView *targetImageView = [[UIImageView alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [ICC setImageURL:@"http://maps.googleapis.com/maps/api/streetview?size=600x300&location=25.052863,121.547428&heading=90&fov=90&pitch=0&sensor=false"
             toImageView:targetImageView
                 withTag:nil
                 andType:TMImageControl_Type_FirstTime];
    });
    
    STAssertNil(targetImageView.image, @"it should not be asign data");
    
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:10.0];
    while (targetImageView.image == nil && [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}
    
    STAssertNotNil(targetImageView.image, @"it should download data");
    
}

- (void) testImageInDB
{
    TMImageCacheControl *ICC = [TMImageCacheControl defaultTMImageCacheControl];
    
    UIImageView *targetImageView = [[UIImageView alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [ICC setImageURL:@"http://maps.googleapis.com/maps/api/streetview?size=600x300&location=25.052863,121.547428&heading=90&fov=90&pitch=0&sensor=false"
             toImageView:targetImageView
                 withTag:nil
                 andType:TMImageControl_Type_FirstTime];
    });
    
    STAssertNil(targetImageView.image, @"it should not be asign data");
    
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:10.0];
    while (targetImageView.image == nil && [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}
    
    STAssertNotNil(targetImageView.image, @"it should download data");
    
    
    UIImageView *target2ImageView = [[UIImageView alloc] init];
    [ICC setImageURL:@"http://maps.googleapis.com/maps/api/streetview?size=600x300&location=24.052863,122.547428&heading=90&fov=90&pitch=0&sensor=false"
         toImageView:target2ImageView
             withTag:nil
             andType:TMImageControl_Type_FirstTime];
    
    STAssertNil(target2ImageView.image, @"it should not be asign data");
    
    [ICC setImageURL:@"http://maps.googleapis.com/maps/api/streetview?size=600x300&location=25.052863,121.547428&heading=90&fov=90&pitch=0&sensor=false"
         toImageView:target2ImageView
             withTag:nil
             andType:TMImageControl_Type_FirstTime];
    
    STAssertNotNil(target2ImageView.image, @"it should have image");
}

- (void) tmImageCacheControl:(TMImageCacheControl *)aControl PreloadFinish:(int)aErrcode
{
    errcode = aErrcode;

}

- (void) testPreloadFunction
{
    TMImageCacheControl *ICC = [TMImageCacheControl defaultTMImageCacheControl];
    
    [ICC addPreloadImageURL:@"http://maps.googleapis.com/maps/api/streetview?size=600x300&location=25.052863,121.547428&heading=90&fov=90&pitch=0&sensor=false"
                    withTag:nil
                    andType:(TMImageControl_Type_FirstTime)];
    
    [ICC addPreloadImageURL:@"http://maps.googleapis.com/maps/api/streetview?size=600x300&location=25.052463,121.547428&heading=90&fov=90&pitch=0&sensor=false"
                    withTag:nil
                    andType:(TMImageControl_Type_FirstTime)];
    
    errcode = -1;
    [ICC executePreload:self];
    
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:10.0];
    while (errcode == -1 && [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}
    
    STAssertEqualsWithAccuracy(errcode, TMImageControl_Preload_Errcode_Success, 0, nil);
}

- (void) testEveryTimeUpdate
{
    TMImageCacheControl *ICC = [TMImageCacheControl defaultTMImageCacheControl];

    UIImageView *targetImageView = [[UIImageView alloc] init];
    [ICC setImageURL:@"http://maps.googleapis.com/maps/api/streetview?size=600x300&location=25.052863,121.547428&heading=90&fov=90&pitch=0&sensor=false"
             toImageView:targetImageView
                 withTag:@"tag"
                 andType:TMImageControl_Type_UpdateEveryTime];
    
    STAssertNil(targetImageView.image, @"it should not be asign data");
    
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:10.0];
    while (targetImageView.image == nil && [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}
    
    STAssertNotNil(targetImageView.image, @"it should download data");
    
    
    
    /// 開始抓
    
    UIImageView *target2ImageView = [[UIImageView alloc] init];
    [ICC setImageURL:@"http://maps.googleapis.com/maps/api/streetview?size=600x300&location=24.052863,122.547428&heading=90&fov=90&pitch=0&sensor=false"
             toImageView:target2ImageView
                 withTag:@"tag"
                 andType:TMImageControl_Type_UpdateEveryTime];
    /// 因為是每次都抓 所有因為已經有這個tag了，他會先拿資料庫裡的圖出來
    STAssertNotNil(target2ImageView.image, @"it should not be asign data");
    STAssertTrue([UIImagePNGRepresentation(targetImageView.image) isEqualToData:UIImagePNGRepresentation(target2ImageView.image)], nil);

    target2ImageView.image = nil; /// 清掉圖，期望下次抓到的圖
    
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:10.0];
    while (target2ImageView.image == nil && [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}
    
    /// 因為下次抓到的圖 網址不一樣 所以圖片會不一樣
    STAssertNotNil(target2ImageView.image, @"it should download data");
    STAssertFalse([UIImagePNGRepresentation(targetImageView.image) isEqualToData:UIImagePNGRepresentation(target2ImageView.image)], nil);
}

@end
