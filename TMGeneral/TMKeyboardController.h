/*
 TMKeyboardController.h
 
 Copyright (c) 2012 willsbor Kang at ThinkerMobile
 
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
/**
 * @brief  for 5.0 中文鍵盤上方選擇欄位做調整
 * 目前只有針對 iphone  Protrait and Landscape  方向做調整
 * 如果再置底的狀況下 比較好作法可能是用 inputField protocol 的 inputView and inputAxxxxryView
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TMKeyboardController;
@class TMKeyboardItem;
@protocol TMKeyboardDelegate <NSObject>

@optional
- (void) keyboard:(TMKeyboardController *)aKeyControl willModifySelectOfItem:(TMKeyboardItem *)aKeyItem ;
- (void) keyboard:(TMKeyboardController *)aKeyControl didModifySelectOfItem:(TMKeyboardItem *)aKeyItem;

- (void) keyboard:(TMKeyboardController *)aKeyControl changeInputAndWithSelectBarHeight:(CGFloat)aSelectBarHeight andKeyBoardHeight:(CGFloat)aKeyboardHeight;

@end

@interface TMKeyboardItem : NSObject

@property (nonatomic) float movingDist; ///< 上移距離
@property (nonatomic) BOOL modifiedBySelectedBar; ///< 是否要針對 5.0 up 中文鍵盤上方選擇欄位做調整
@property (nonatomic, unsafe_unretained) id<UITextViewDelegate> textViewDelegate;  ///< 如果監控的是textView 要轉發的delegate

@property (nonatomic, strong) UITextField *targetTextField;
@property (nonatomic, strong) NSArray *movingViews;
@property (nonatomic, strong) UITextView *tartgetTextView;

@property (nonatomic, weak) id<TMKeyboardDelegate> delegate;

@end

@interface TMKeyboardController : NSObject

@property (nonatomic, readonly) BOOL isShowKB; ///< 現在keyboard 的狀態

/**
 * old method
 */
+ (TMKeyboardController *) defaultTMKeyboardController;

- (NSString *) makeKey:(id)aObject;

/**
 * 將一個Keyboard movinger 註冊到 list 中
 */
- (void) addKeyboardItem:(TMKeyboardItem *)aKBM withKey:(NSString *)aKey;

/**
 * 拿取list 中的一個 kbm
 */
- (TMKeyboardItem *) getKeyboardItemWithKey:(NSString *)aKey;

/**
 * 拿取list 中的 所有的 kbm
 */
- (NSDictionary *) getAllKeyboardItem;

/**
 * 移除一個已經在list中的KBM
 */
- (void) removeWithKey:(NSString *)aKey;

- (void) showKeyBoard:(NSString *)aKey;

- (void) hideKeyBoard:(NSString *)aKey;



@end
