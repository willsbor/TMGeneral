//
//  TMViewController.h
//  TMGeneral
//
//  Created by mac on 12/10/9.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMAPIModel.h"
#import "TMImageCacheControl.h"

@interface TMViewController : UIViewController

@property (nonatomic, strong) NSMutableDictionary *activeAPIs;
@property (nonatomic, strong) NSArray *touchHiddenKeyBoardsByViews;

//// view
- (id) initWithUniversal;

//// API
- (void) resultAPI:(TMAPIModel *)aModel
           withKey:(NSString *)aKey
 finishWithErrcode:(int)aErrcode
          AndParam:(NSDictionary *)aParam;

- (void) executeAPI:(TMAPIModel *)aModel withKey:(NSString *)aKey;
- (void) executeAPI:(TMAPIModel *)aModel;
- (id) apiModelByKey:(NSString *)aKey;
- (void) cancelAPIForKey:(NSString *)aKey;

//// image
- (void) loadImage:(UIImageView *)aImageView from:(NSString *)aURL;
- (void) loadImage:(UIImageView *)aImageView from:(NSString *)aURL placeholder:(UIImage *)aPlaceholder;
- (void) loadImage:(UIImageView *)aImageView
              from:(NSString *)aURL
           withTag:(NSString *)aTag
           andType:(TMImageControl_Type)aType
       placeholder:(UIImage *)aPlaceholder;

/// keyboard
- (void) hideAllKeyBoard;
- (void) showKeyBoard:(NSString *)KeyboardKey;
- (void) hideKeyBoard:(NSString *)KeyboardKey;

- (NSString *) registerTextField:(UITextField *) aTargetTextField
                     toMoveViews:(NSArray *)aMovedViews
              withMovingDistance:(float) aMovingDistance
            andModifyBySelectBar:(BOOL) aSelectBar 
                       andOption:(NSDictionary *)aOptions;

- (NSString *) registerTextField:(UITextField *) aTargetTextField
                     toMoveViews:(NSArray *)aMovedViews
              withMovingDistance:(float) aMovingDistance
            andModifyBySelectBar:(BOOL) aSelectBar ;

- (NSString *) registerTextView:(UITextView *) aTargetTextView
                    toMoveViews:(NSArray *)aMovedViews
             withMovingDistance:(float) aMovingDistance
           andModifyBySelectBar:(BOOL) aSelectBar
                      andOption:(NSDictionary *)aOptions;

- (NSString *) registerTextView:(UITextView *) aTargetTextView
                    toMoveViews:(NSArray *)aMovedViews
             withMovingDistance:(float) aMovingDistance
           andModifyBySelectBar:(BOOL) aSelectBar ;

- (IBAction)enterEngineerMode1:(id)sender;
- (IBAction)enterEngineerMode2:(id)sender;

@end
