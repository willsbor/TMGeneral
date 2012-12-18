//
//  TMKeyboardController.h
//  TMGeneral
//
//  Created by mac on 12/10/16.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//
/**
 * @brief  for 5.0 中文鍵盤上方選擇欄位做調整
 * 目前只有針對 iphone  Protrait and Landscape  方向做調整
 * 如果再置底的狀況下 比較好作法可能是用 inputField protocol 的 inputView and inputAxxxxryView
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface TMKeyboardItem : NSObject

@property (nonatomic) float movingDist; ///< 上移距離
@property (nonatomic) BOOL modifiedBySelectedBar; ///< 是否要針對 5.0 up 中文鍵盤上方選擇欄位做調整
@property (nonatomic, unsafe_unretained) id<UITextViewDelegate> textViewDelegate;  ///< 如果監控的是textView 要轉發的delegate

@property (nonatomic, strong) UITextField *targetTextField;
@property (nonatomic, strong) NSArray *movingViews;
@property (nonatomic, strong) UITextView *tartgetTextView;

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
