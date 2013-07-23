/*
 TMTableViewController.h
 
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

#import <UIKit/UIKit.h>
#import "TMAPIModel.h"
#import "TMImageCacheControl.h"

@interface TMTableViewController : UITableViewController

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

@end
