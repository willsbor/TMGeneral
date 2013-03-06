//
//  TMKeyboardController.m
//  TMGeneral
//
//  Created by mac on 12/10/16.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import "TMKeyboardController.h"
#import "TMTools.h"

#define TM_KEYBOARD_ITEM_OBEJCT @"com.thinkermobile.keyboard_controller.notify_object"

@implementation TMKeyboardItem

- (id) initWithMovingDistance:(float)aMovingDist andModifySelectBar:(BOOL)aModifySelectBar
{
    self = [super init];
    if (self) {
        _modifiedBySelectedBar = aModifySelectBar;
        _movingDist = aMovingDist;
    }
    return self;
}


@end



@interface TMKeyboardController () <UITextViewDelegate>
{
    NSMutableDictionary *g_KBMs;
    NSMutableDictionary *g_RecordY;
}

@property (nonatomic)         int inputMethodModify;

@end



@implementation TMKeyboardController

+ (TMKeyboardController *) defaultTMKeyboardController
{
    static dispatch_once_t pred;
	static TMKeyboardController *sharedInstance = nil;
    
	dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
	return sharedInstance;
}

- (NSString *) makeKey:(id)aObject
{
    return tmStringFromMD5([NSString stringWithFormat:@"%p", aObject]);
}

- (void) addKeyboardItem:(TMKeyboardItem *)aKBM withKey:(NSString *)aKey
{
    if (g_KBMs == nil) {
        g_KBMs = [[NSMutableDictionary alloc] init];
    }
    
    [g_KBMs setObject:aKBM forKey:aKey];
    [self registerItem:aKBM];
}

- (NSDictionary *) getAllKeyboardItem
{
    return g_KBMs;
}

- (TMKeyboardItem *) getKeyboardItemWithKey:(NSString *)aKey
{
    if (g_KBMs == nil) return nil;
    
    return [g_KBMs objectForKey:aKey];
}

- (void) removeWithKey:(NSString *)aKey
{
    if (g_KBMs == nil) return;
    
    [g_KBMs removeObjectForKey:aKey];
}

- (CGFloat) checkInputMethod2
{
    
    CGFloat keyBoardHeight = 0;
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        for (UIView *view in [window subviews]) {
            if ([[NSString stringWithFormat:@"%@", [view class]] isEqualToString:@"UIPeripheralHostView"] == YES ) {
                //NSLog(@"%@ - %@", [view class], NSStringFromCGRect([view frame]));
                CGRect tmp = [view frame];
                keyBoardHeight = tmp.size.height;
                if (keyBoardHeight == 252  ///< 可能只for iphone 單方向 直的
                    || keyBoardHeight == 198) {    ///< for iphone 單方向 橫的
                    _inputMethodModify = 36;
                } else {
                    _inputMethodModify = 0;
                }
                break;
            }
        }
    }
    
    return keyBoardHeight;
}

- (void) checkInputMethod:(TMKeyboardItem *) aItem
{
    /// 先判斷是否有select bar
    CGFloat kh = [self checkInputMethod2];
    if (aItem.delegate != nil && [aItem.delegate respondsToSelector:@selector(keyboard:changeInputAndWithSelectBarHeight:andKeyBoardHeight:)]) {
        [aItem.delegate keyboard:self changeInputAndWithSelectBarHeight:_inputMethodModify andKeyBoardHeight:kh];
    }
    
    if (aItem.modifiedBySelectedBar == NO) {
        _inputMethodModify = 0;
        _isShowKB = YES;
        return;
    }
    
    NSString *string = [[UITextInputMode currentInputMode] primaryLanguage];
    
    //HiiirLog(@"[UITextInputMode currentInputMode].primaryLanguage = %@", string);
    //NSRange range = [string rangeOfString:@"0x46de50"];
    if ([string isEqualToString:@"zh-Hant"] == YES
        || [string isEqualToString:@"zh-Hans"] == YES) {
    } else
        _inputMethodModify = 0;
    
    
    if (aItem.delegate != nil && [aItem.delegate respondsToSelector:@selector(keyboard:willModifySelectOfItem:)]) {
        [aItem.delegate keyboard:self willModifySelectOfItem:aItem];
    }
    
    [UIView animateWithDuration:0.1 delay:0.0 options:(UIViewAnimationOptionAllowUserInteraction)  animations:^{
        //int i = 0;
        for (UIView *object in aItem.movingViews) {
            NSString *key = [NSString stringWithFormat:@"%p", object];
            float ori =  [[g_RecordY objectForKey:key] floatValue];
            float nextMovingDist = aItem.movingDist;
            nextMovingDist += _inputMethodModify;
            
            CGPoint point = object.center;
            point.y -= (nextMovingDist - ori);
            object.center = point;
            
            [g_RecordY setObject:[NSNumber numberWithFloat:nextMovingDist] forKey:key];
            //_recordY[i] = nextMovingDist;
            //++i;
        }
    } completion:^(BOOL finished) {
        _isShowKB = YES;
        
        if (aItem.delegate != nil && [aItem.delegate respondsToSelector:@selector(keyboard:didModifySelectOfItem:)]) {
            [aItem.delegate keyboard:self didModifySelectOfItem:aItem];
        }
    }];
}

- (void)inputModeDidChange:(NSNotification*)notification
{
    //TMKeyboardItem *item = [notification.userInfo objectForKey:TM_KEYBOARD_ITEM_OBEJCT];
    /*
     NSLog(@"notification.object = %@", notification.object);
     NSLog(@"notification.userInfo = %@", notification.userInfo);
     if (notification.object == _targetTF
     || notification.object == _targetTV) {
     [self _m_showKeyBoard];
     }
     */
    
    for (TMKeyboardItem *item in [g_KBMs allValues]) {
        
        if (item.targetTextField != nil) {
            if ([item.targetTextField isFirstResponder]) {
                [self _m_showKeyBoard:item];
                return ; ///<理論尚同時間只會有一個鍵盤
            }
        }
        else if (item.tartgetTextView != nil) {
            if ([item.tartgetTextView isFirstResponder]) {
                [self _m_showKeyBoard:item];
                return ; ///<理論尚同時間只會有一個鍵盤
            }
        }
    }
}


- (void) beginEdit:(id)sender
{
    [self showKeyBoard:[self makeKey:sender]];
}

- (void) endEdit:(id)sender
{
    [self hideKeyBoard:[self makeKey:sender]];
}

#pragma mark -

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    TMKeyboardItem *item = [self getKeyboardItemWithKey:[self makeKey:textView]];
    
    if (item != nil) {
        if (item.textViewDelegate) {
            if ([item.textViewDelegate respondsToSelector:@selector(textViewShouldBeginEditing:)]) {
                return [item.textViewDelegate textViewShouldBeginEditing:textView];
            }
        }
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    
    TMKeyboardItem *item = [self getKeyboardItemWithKey:[self makeKey:textView]];
    
    if (item != nil) {
        if (item.textViewDelegate) {
            if ([item.textViewDelegate respondsToSelector:@selector(textViewShouldEndEditing:)]) {
                return [item.textViewDelegate textViewShouldEndEditing:textView];
            }
        }
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSString *key = [self makeKey:textView];
    TMKeyboardItem *item = [self getKeyboardItemWithKey:key];
    
    if (item != nil) {
        [self showKeyBoard:key];
        
        if (item.textViewDelegate) {
            if ([item.textViewDelegate respondsToSelector:@selector(textViewDidBeginEditing:)]) {
                [item.textViewDelegate textViewDidBeginEditing:textView];
            }
        }
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSString *key = [self makeKey:textView];
    TMKeyboardItem *item = [self getKeyboardItemWithKey:key];
    
    if (item != nil) {
        [self hideKeyBoard:key];
        
        if (item.textViewDelegate) {
            if ([item.textViewDelegate respondsToSelector:@selector(textViewDidEndEditing:)]) {
                [item.textViewDelegate textViewDidEndEditing:textView];
            }
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    TMKeyboardItem *item = [self getKeyboardItemWithKey:[self makeKey:textView]];
    
    if (item != nil) {
        if (item.textViewDelegate) {
            if ([item.textViewDelegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
                return [item.textViewDelegate textView:textView shouldChangeTextInRange:range replacementText:text];
            }
        }
    }
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView
{
    
    TMKeyboardItem *item = [self getKeyboardItemWithKey:[self makeKey:textView]];
    
    if (item != nil) {
        if (item.textViewDelegate) {
            if ([item.textViewDelegate respondsToSelector:@selector(textViewDidChange:)]) {
                [item.textViewDelegate textViewDidChange:textView];
            }
        }
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    
    TMKeyboardItem *item = [self getKeyboardItemWithKey:[self makeKey:textView]];
    
    if (item != nil) {
        if (item.textViewDelegate) {
            if ([item.textViewDelegate respondsToSelector:@selector(textViewDidChangeSelection:)]) {
                [item.textViewDelegate textViewDidChangeSelection:textView];
            }
        }
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"frame"]) {
        ///一次動作會重複進去兩次
        [self inputModeDidChange:nil];
    }
    else if ([keyPath isEqualToString:@"inputAccessoryView"]) {
        /// todo
    }
}

- (void) _registerHighChangeKVO:(UITextField *)aTextField
{
    if (aTextField.inputAccessoryView == nil) {
        aTextField.inputAccessoryView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 320, 0))];
    }
    
    [aTextField.inputAccessoryView addObserver:self
                                    forKeyPath:@"frame"
                                       options:NSKeyValueObservingOptionNew
                                       context:NULL];
    
    /// 這裡可能要多註冊 inputAccessoryView 變更的話 要在註冊一次
    
    /*[aTextField addObserver:self
     forKeyPath:@"inputAccessoryView"
     options:NSKeyValueObservingOptionNew
     context:NULL];
     */
}

- (void) _registerHighChangeKVOView:(UITextView *)aTextView
{
    if (aTextView.inputAccessoryView == nil) {
        aTextView.inputAccessoryView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 320, 0))];
    }
    
    [aTextView.inputAccessoryView addObserver:self
                                   forKeyPath:@"frame"
                                      options:NSKeyValueObservingOptionNew
                                      context:NULL];
    
    /// 這裡可能要多註冊 inputAccessoryView 變更的話 要在註冊一次
    /*[aTextView addObserver:self
     forKeyPath:@"inputAccessoryView"
     options:NSKeyValueObservingOptionNew
     context:NULL];
     */
}

- (void) _unregisterHighChangeKVO:(UITextField *)aTextField
{
    [aTextField.inputAccessoryView removeObserver:self forKeyPath:@"frame" context:NULL];
    //[aTextField removeObserver:self forKeyPath:@"inputAccessoryView" context:NULL];
}

- (void) _unregisterHighChangeKVOView:(UITextView *)aTextView
{
    [aTextView.inputAccessoryView removeObserver:self forKeyPath:@"frame" context:NULL];
    //[aTextView removeObserver:self forKeyPath:@"inputAccessoryView" context:NULL];
}

#pragma mark -


- (void) registerItem:(TMKeyboardItem *) aItem
{
    [self unregister:aItem];
    
    if (aItem.targetTextField != nil) {
        [aItem.targetTextField addTarget:self action:@selector(beginEdit:) forControlEvents:(UIControlEventEditingDidBegin)];
        
        [aItem.targetTextField addTarget:self action:@selector(endEdit:) forControlEvents:(UIControlEventEditingDidEndOnExit)];
        
        [self _registerHighChangeKVO:aItem.targetTextField];
    }
    else if (aItem.tartgetTextView != nil) {
        aItem.tartgetTextView.delegate = self;
        
        [self _registerHighChangeKVOView:aItem.tartgetTextView];
    }
    
    /// 20120604 Kang+- object 不可以給nil 不然其他物件也會丟 UITextInputCurrentInputModeDidChangeNotification 然後就會亂跳
    /// 20120905 KAng+- object 如果是_targetTF  連接都接不到orz
    
    for (UIView *object in aItem.movingViews) {
        //_recordY[i++] = 0.0;
        NSString *key = [NSString stringWithFormat:@"%p", object];
        [g_RecordY setObject:[NSNumber numberWithFloat:0.0] forKey:key];
    }
}

- (void) unregister:(TMKeyboardItem *) aItem
{
    if (aItem.targetTextField != nil) {
        [aItem.targetTextField removeTarget:self action:@selector(beginEdit:) forControlEvents:UIControlEventEditingDidBegin];
        [aItem.targetTextField removeTarget:self action:@selector(endEdit:) forControlEvents:UIControlEventEditingDidEndOnExit];
        //[_targetTF removeTarget:self action:@selector(endEdit:) forControlEvents:UIControlEventEditingDidEnd];
        
        [self _unregisterHighChangeKVO:aItem.targetTextField];
    }
    else if (aItem.tartgetTextView != nil) {
        aItem.tartgetTextView.delegate = nil;
        
        [self _unregisterHighChangeKVOView:aItem.tartgetTextView];
    }
    
    
    //if (_recordY != NULL) {free(_recordY); _recordY = NULL;}
    for (UIView *object in aItem.movingViews) {
        NSString *key = [NSString stringWithFormat:@"%p", object];
        [g_RecordY removeObjectForKey:key];
    }
}

- (void) _m_showKeyBoard:(TMKeyboardItem *) aItem {
    
    
    
    [UIView animateWithDuration:0.3 delay:0.0 options:(UIViewAnimationOptionAllowUserInteraction) animations:^{
        //int i = 0;
        for (UIView *object in aItem.movingViews) {
            NSString *key = [NSString stringWithFormat:@"%p", object];
            float ori =  [[g_RecordY objectForKey:key] floatValue];
            float nextMovingDist = aItem.movingDist;
            nextMovingDist += _inputMethodModify;
            
            CGPoint point = object.center;
            point.y -= (nextMovingDist - ori);
            object.center = point;
            
            [g_RecordY setObject:[NSNumber numberWithFloat:nextMovingDist] forKey:key];
            //_recordY[i] = nextMovingDist;
            //++i;
        }
    } completion:^(BOOL finished) {
        [self checkInputMethod:aItem];
    }];
}

- (void) showKeyBoard:(NSString *)aKey
{
    ///  20120606 Kang-- 因為如果 isShowKB 就不showKB 的話 可能會導致多個KB的狀況互跳的狀況下 KB不會移動
    /*   if (isShowKB == YES) {
     return;
     }
     */
    TMKeyboardItem *item = [self getKeyboardItemWithKey:aKey];
    
    if ( item != nil) {
        
        [self _m_showKeyBoard:item];
    }
}

- (void) hideKeyBoard:(NSString *)aKey
{
    ///  20120606 Kang-- 因為如果 isShowKB 就不showKB 的話 可能會導致多個KB的狀況互跳的狀況下 KB不會移動
    /*
     if (isShowKB == NO) {
     return;
     }
     */
    
    TMKeyboardItem *item = [self getKeyboardItemWithKey:aKey];
    
    if (item == nil) {
        return;
    }
    
    if (item.targetTextField != nil) {
        if ([item.targetTextField isFirstResponder]) {
            
            [UIView animateWithDuration:0.3 delay:0.0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState )  animations:^{
                //int i = 0;
                for (UIView *object in item.movingViews) {
                    NSString *key = [NSString stringWithFormat:@"%p", object];
                    float ori =  [[g_RecordY objectForKey:key] floatValue];
                    NSLog(@"ori = %f", ori);
                    CGPoint point = object.center;
                    point.y += ori;
                    object.center = point;
                    NSLog(@"point.y = %f", point.y);
                    [g_RecordY setObject:[NSNumber numberWithFloat:0.0] forKey:key];
                    //++i;
                }
            } completion:^(BOOL finished) {
                _isShowKB = NO;
            }];
            
            
            [item.targetTextField resignFirstResponder];
        } else
            _isShowKB = NO;
    } else if (item.tartgetTextView != nil) {
        if ([item.tartgetTextView isFirstResponder]) {
            
            [UIView animateWithDuration:0.3 delay:0.0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState )  animations:^{
                //int i = 0;
                for (UIView *object in item.movingViews) {
                    NSString *key = [NSString stringWithFormat:@"%p", object];
                    float ori =  [[g_RecordY objectForKey:key] floatValue];
                    NSLog(@"ori = %f", ori);
                    CGPoint point = object.center;
                    point.y += ori;
                    object.center = point;
                    NSLog(@"point.y = %f", point.y);
                    [g_RecordY setObject:[NSNumber numberWithFloat:0.0] forKey:key];
                    //++i;
                }
            } completion:^(BOOL finished) {
                _isShowKB = NO;
            }];
            
            
            [item.tartgetTextView resignFirstResponder];
        } else
            _isShowKB = NO;
    } else
        _isShowKB = NO;
    
    
}

- (id) init
{
    self = [super init];
    if (self) {
        //self.modifiedBySpecialKB = NO;
        //self.movingDist = 0;
        
        if (g_RecordY == nil) {
            g_RecordY = [[NSMutableDictionary alloc] init];
        }
        
        _inputMethodModify = 0;
        _isShowKB = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(inputModeDidChange:)
                                                     name:UITextInputCurrentInputModeDidChangeNotification
                                                   object:nil];
        
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextInputCurrentInputModeDidChangeNotification
                                                  object:nil];
    
    for (TMKeyboardItem *object in g_KBMs) {
        [self unregister:object];
    }
    
    g_KBMs = nil;
    g_KBMs = nil;
    
    
    
}



@end
