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
#import "TMUITools.h"

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
- (NSError *) _errorURLisNil;
- (NSError *) _errorServerErrorWithCode:(NSError *)aServerError andStatusCode:(NSInteger)aStatusCode;
@end

@interface TMImageCacheControl (UTest)

@end

@implementation TMImageCacheControl (UTest)

+ (void) load
{
    Method origMethod = class_getInstanceMethod(self, @selector(_getDataFrom:AndSaveIn:toComplete:));
	Method newMethod = class_getInstanceMethod(self, @selector(unitTest_getDataFrom:AndSaveIn:toComplete:));
    method_setImplementation(origMethod, method_getImplementation(newMethod));

}

- (void)unitTest_getDataFrom:(NSString *)aUrl AndSaveIn:(NSString *)aItem toComplete:(void (^)(NSData *aImageNSData, NSError *error))aComplete
{
    /// 直接回應對應的網路圖片
    
    if (aUrl == nil || [aUrl length] == 0) {
        if (aComplete) aComplete(nil, [self _errorURLisNil]);
        return;
    }
    
    
    void (^success)(id responseObject) = ^(id responseObject) {
        [[TMGeneralDataManager sharedInstance] imageCache:aItem setData:responseObject];
        NSData *imageData = [[TMGeneralDataManager sharedInstance] imageCacheImageDataByTag:aItem];
        if (aComplete) aComplete(imageData, nil);
    };
    
    void (^failed)(id responseObject, NSInteger ServerErrcode) = ^(id responseObject, NSInteger ServerErrcode) {
            NSError *dummyError = [[NSError alloc] initWithDomain:@"UnitTest" code:1111 userInfo:nil];
        if (aComplete) aComplete(nil, [self _errorServerErrorWithCode:dummyError andStatusCode:ServerErrcode]);
    };
    
    
    UIImage *image = tmImageWithColor([UIColor grayColor]);
    if ([aUrl isEqualToString:@"http://1.1.1.1"]) {
        image = tmImageWithColor([UIColor greenColor]);
    }
    else if ([aUrl isEqualToString:@"http://1.1.1.2"]) {
        image = tmImageWithColor([UIColor redColor]);
    }
    else if ([aUrl isEqualToString:@"http://1.1.1.3"]) {
        image = tmImageWithColor([UIColor yellowColor]);
    }
    else if ([aUrl isEqualToString:@"http://1.1.1.5"]) {
        image = tmImageWithColor([UIColor yellowColor]);
    }
    else if ([aUrl isEqualToString:@"http://1.1.2.1"]) {
        image = nil;
    }
    
    if (image) {
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            success(UIImageJPEGRepresentation(image, 0.5));
        });
    } else {
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            failed(nil, 403);
        });
    }
    
}

@end


@interface TMImageCacheControlTest : SenTestCase <TMImageCacheControlPreloadProtocol>
{
    NSDate *asyncWaitUntil;
    int errcode;
}
@end

@implementation TMImageCacheControlTest

- (void) testSetImageToBlock
{
    TMImageCacheControl *ICC = [TMImageCacheControl defaultTMImageCacheControl];
    
    UIImageView *targetImageView = [[UIImageView alloc] init];
    [ICC setImageURL:@"http://1.1.1.5" toComplete:^(UIImage *aImage, NSError *error) {
        targetImageView.image = aImage;
    }];
    
    STAssertNil(targetImageView.image, @"it should not be asign data");
    
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:2.0];
    while (targetImageView.image == nil && [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}
    
    STAssertNotNil(targetImageView.image, @"it should download data");
}

- (void) testServerErrcode403
{
    TMImageCacheControl *ICC = [TMImageCacheControl defaultTMImageCacheControl];
    
    UIImageView *targetImageView = [[UIImageView alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [ICC setImageURL:@"http://1.1.2.1"
             toImageView:targetImageView
                 withTag:nil
                 andType:TMImageControl_Type_FirstTime];
    });
    
    STAssertNil(targetImageView.image, @"it should not be asign data");
    
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:2.0];
    while (targetImageView.image == nil && [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}
    
    STAssertNil(targetImageView.image, @"it should not be asign data because erver error");
}

- (void) testServerErrcode403withModify
{
    TMImageCacheControl *ICC = [TMImageCacheControl defaultTMImageCacheControl];
    
    UIImage *modifyImage = tmImageWithColor([UIColor whiteColor]);
    ICC.ImageModify = ^(UIImage *aOriImage, NSError *aError) {
        NSInteger statuscode = [[aError.userInfo objectForKey:TM_IMAGE_CACHE_ERR_USERINFO_STATUS_CODE_KEY] integerValue];
        if (statuscode == 403) {
            return modifyImage;
        } else
            return aOriImage;
    };
    
    UIImageView *targetImageView = [[UIImageView alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [ICC setImageURL:@"http://1.1.2.1"
             toImageView:targetImageView
                 withTag:nil
                 andType:TMImageControl_Type_FirstTime];
    });
    
    STAssertNil(targetImageView.image, @"it should not be asign data");
    
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:2.0];
    while (targetImageView.image == nil && [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}
    
    STAssertNotNil(targetImageView.image, @"it should not be asign data because erver error");
    STAssertTrue([UIImagePNGRepresentation(modifyImage) isEqualToData:UIImagePNGRepresentation(targetImageView.image)], nil);
    
    ICC.ImageModify = nil;
}

- (void) testNormal
{
    
    TMImageCacheControl *ICC = [TMImageCacheControl defaultTMImageCacheControl];

    UIImageView *targetImageView = [[UIImageView alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [ICC setImageURL:@"http://1.1.1.1"
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
        [ICC setImageURL:@"http://1.1.1.1"
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
    [ICC setImageURL:@"http://1.1.1.2"
         toImageView:target2ImageView
             withTag:nil
             andType:TMImageControl_Type_FirstTime];
    
    STAssertNil(target2ImageView.image, @"it should not be asign data");
    
    [ICC setImageURL:@"http://1.1.1.1"
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
    
    [ICC addPreloadImageURL:@"http://1.1.1.1"
                    withTag:nil
                    andType:(TMImageControl_Type_FirstTime)];
    
    [ICC addPreloadImageURL:@"http://1.1.1.3"
                    withTag:nil
                    andType:(TMImageControl_Type_FirstTime)];
    
    errcode = -1;
    [ICC executePreload:self];
    
    asyncWaitUntil = [NSDate dateWithTimeIntervalSinceNow:10.0];
    while (errcode == -1 && [asyncWaitUntil timeIntervalSinceNow] > 0) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:asyncWaitUntil];
	}
    
    STAssertEqualsWithAccuracy(errcode, TMImageControl_Errcode_Success, 0, nil);
}

- (void) testEveryTimeUpdate
{
    TMImageCacheControl *ICC = [TMImageCacheControl defaultTMImageCacheControl];

    UIImageView *targetImageView = [[UIImageView alloc] init];
    [ICC setImageURL:@"http://1.1.1.1"
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
    [ICC setImageURL:@"http://1.1.1.2"
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
