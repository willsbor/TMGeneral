//
//  TMViewController.m
//  TMGeneral
//
//  Created by mac on 12/10/9.
//  Copyright (c) 2012年 ThinkerMobile. All rights reserved.
//

#import "TMViewController.h"
#import "TMImageCacheControl.h"
#import "TMKeyboardController.h"
#import <UIKitCategoryAdditions_kang/UIAlertView+MKBlockAdditions.h>

static NSString *g_defaultEngineerModePassword = @"Ncku";

@interface TMViewController () <TMAPIModelProtocol, UITextViewDelegate, TMKeyboardDelegate>
{
    int _engineerMode;
}
@property (nonatomic, strong) NSMutableArray *loadingImageViews;
@property (nonatomic, strong) NSMutableArray *keyboardWatchList;

@end

@implementation TMViewController

#pragma mark - static

//static NSDictionary *g_ImageCacheOption;

//////// 如果cache中沒有圖的話
////////// 如果需要顯示 placeholder
///////////// 顯示 placeholder

#pragma mark - public

- (void) resultAPI:(TMAPIModel *)aModel withKey:(NSString *)aKey finishWithErrcode:(int)aErrcode AndParam:(NSDictionary *)aParam
{
    /// initial with nothing
}

- (void) cancelAPIForKey:(NSString *)aKey
{
    TMAPIModel *object = [self.activeAPIs objectForKey:aKey];
    if (object != nil) {
        /// 取消api動作
        if (object.mode == TMAPI_Mode_Leave_With_Cancel) {
            [object cancel];
        }
        object.delegate = nil;
        
        /// 從清單中移除
        [self.activeAPIs removeObjectForKey:aKey];
    }
}

- (id) apiModelByKey:(NSString *)aKey
{
    return [self.activeAPIs objectForKey:aKey];
}

- (void) executeAPI:(TMAPIModel *)aModel
{
    [self executeAPI:aModel withKey:[NSString stringWithFormat:@"%@", [NSDate date]]];
}

- (void) executeAPI:(TMAPIModel *)aModel withKey:(NSString *)aKey
{
    TMAPIModel *object = [self.activeAPIs objectForKey:aKey];
    
    if (object != nil) {
        if (object.mode == TMAPI_Mode_Leave_With_Cancel) {
            [object cancel];
        }
        object.delegate = nil;
    }
    
    [self.activeAPIs setObject:aModel forKey:aKey];
    
    aModel.key = aKey;
    [aModel startWithDelegate:self];
}

- (void) loadImage:(UIImageView *)aImageView from:(NSString *)aURL
{
    [self loadImage:aImageView
               from:aURL
            withTag:nil
            andType:(TMImageControl_Type_FirstTime)
        placeholder:nil];
}

- (void) loadImage:(UIImageView *)aImageView from:(NSString *)aURL placeholder:(UIImage *)aPlaceholder
{
    [self loadImage:aImageView
               from:aURL
            withTag:nil
            andType:(TMImageControl_Type_FirstTime)
        placeholder:aPlaceholder];
}

- (void) loadImage:(UIImageView *)aImageView
              from:(NSString *)aURL
           withTag:(NSString *)aTag
           andType:(TMImageControl_Type)aType
       placeholder:(UIImage *)aPlaceholder
{
    TMImageCacheControl *ICC = [TMImageCacheControl defaultTMImageCacheControl];
    NSDictionary *option;
    if (aPlaceholder != nil) {
       option = @{TM_IMAGE_CACHE_ACTIVITY_INDICATOR: @YES,
                  TM_IMAGE_CACHE_PLACEHOLDER_IMAGE: aPlaceholder};
    } else {
        option = @{TM_IMAGE_CACHE_ACTIVITY_INDICATOR: @YES};
    }
    
    [self.loadingImageViews addObject:aImageView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [ICC setImageURL:aURL
             toImageView:aImageView
                 withTag:aTag
                 andType:aType
              andOptions:option];
    });
}


- (void) showKeyBoard:(NSString *)KeyboardKey
{
    [[TMKeyboardController defaultTMKeyboardController] showKeyBoard:KeyboardKey];
}

- (void) hideKeyBoard:(NSString *)KeyboardKey
{
    [[TMKeyboardController defaultTMKeyboardController] hideKeyBoard:KeyboardKey];
}

- (void) hideAllKeyBoard
{
    for (NSString *key in self.keyboardWatchList) {
        [self hideKeyBoard:key];
    }
}

- (NSString *) registerTextField:(UITextField *) aTargetTextField
                     toMoveViews:(NSArray *)aMovedViews
              withMovingDistance:(float) aMovingDistance
            andModifyBySelectBar:(BOOL) aSelectBar
                       andOption:(NSDictionary *)aOptions
{
    NSString *key = [[TMKeyboardController defaultTMKeyboardController] makeKey:aTargetTextField];
    
    TMKeyboardItem *item;
    if ( [self.keyboardWatchList containsObject:key] ) {
        item = [[TMKeyboardController defaultTMKeyboardController] getKeyboardItemWithKey:key];
    } else {
        [self.keyboardWatchList addObject:key];
        
        item = [[TMKeyboardItem alloc] init];
        item.targetTextField = aTargetTextField;
        
        [[TMKeyboardController defaultTMKeyboardController] addKeyboardItem:item
                                                                    withKey:key];
    }
    
    item.movingDist = aMovingDistance;
    item.modifiedBySelectedBar = aSelectBar;
    item.movingViews = aMovedViews;
    item.delegate = self;
    
    return key;
}

- (NSString *) registerTextField:(UITextField *) aTargetTextField
                     toMoveViews:(NSArray *)aMovedViews
              withMovingDistance:(float) aMovingDistance
            andModifyBySelectBar:(BOOL) aSelectBar
{
    return [self registerTextField:aTargetTextField toMoveViews:aMovedViews withMovingDistance:aMovingDistance andModifyBySelectBar:aSelectBar andOption:nil];
}

- (NSString *) registerTextView:(UITextView *) aTargetTextView
                     toMoveViews:(NSArray *)aMovedViews
             withMovingDistance:(float) aMovingDistance
           andModifyBySelectBar:(BOOL) aSelectBar
                      andOption:(NSDictionary *)aOptions
{
    NSString *key = [[TMKeyboardController defaultTMKeyboardController] makeKey:aTargetTextView];
    
    TMKeyboardItem *item;
    if ( [self.keyboardWatchList containsObject:key] ) {
        item = [[TMKeyboardController defaultTMKeyboardController] getKeyboardItemWithKey:key];
    } else {
        [self.keyboardWatchList addObject:key];
        
        item = [[TMKeyboardItem alloc] init];
        item.tartgetTextView = aTargetTextView;
        item.textViewDelegate = self;
        
        [[TMKeyboardController defaultTMKeyboardController] addKeyboardItem:item
                                                                    withKey:key];
    }
    
    item.movingDist = aMovingDistance;
    item.modifiedBySelectedBar = aSelectBar;
    item.movingViews = aMovedViews;
    item.delegate = self;
    
    return key;
}

- (NSString *) registerTextView:(UITextView *) aTargetTextView
                     toMoveViews:(NSArray *)aMovedViews
             withMovingDistance:(float) aMovingDistance
           andModifyBySelectBar:(BOOL) aSelectBar
{
    return [self registerTextView:aTargetTextView toMoveViews:aMovedViews withMovingDistance:aMovingDistance andModifyBySelectBar:aSelectBar andOption:nil];
}

#pragma mark - private

#pragma mark - TMKeyboardDelegate
/*
- (void) keyboard:(TMKeyboardController *)aKeyControl didModifySelectHigh:(CGFloat)aKeyBoardHeight OfItem:(TMKeyboardItem *)aKeyItem
{
    
}

- (void) keyboard:(TMKeyboardController *)aKeyControl willModifySelectHigh:(CGFloat)aKeyBoardHeight OfItem:(TMKeyboardItem *)aKeyItem
{
    
}
*/

#pragma mark - TMAPIModelProtocol

- (void) _workOnMain:(TMAPIModel *)aModel
{
    [self resultAPI:aModel withKey:aModel.key finishWithErrcode:aModel.errcode AndParam:aModel.outputParam];
}

- (void) apiModel:(TMAPIModel *)aModel finishWithErrcode:(int)aErrcode AndParam:(NSDictionary *)aParam
{
    [self performSelectorOnMainThread:@selector(_workOnMain:) withObject:aModel waitUntilDone:YES];
}

#pragma mark - touch

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if ([_touchHiddenKeyBoardsByViews containsObject:[touch view]]) {
        for (NSString *key in self.keyboardWatchList) {
            [self hideKeyBoard:key];
        }
    }
}

#pragma mark - engineer 

- (IBAction)enterEngineerMode1:(id)sender {
    if ([[sender class] isSubclassOfClass:[UILongPressGestureRecognizer class]]) {
        UILongPressGestureRecognizer *longPGR = sender;
        if (UIGestureRecognizerStateBegan == longPGR.state) {
            _engineerMode = 1;
        }
        else if (UIGestureRecognizerStateEnded == longPGR.state
                 || UIGestureRecognizerStateCancelled == longPGR.state
                 || UIGestureRecognizerStateFailed == longPGR.state) {
            _engineerMode = 0;
        }
    }
    
}

- (IBAction)enterEngineerMode2:(id)sender {
    if ([[sender class] isSubclassOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tapGR = sender;
#if !(TARGET_IPHONE_SIMULATOR)
        if (_engineerMode == 1) {
            if (tapGR.state == UIGestureRecognizerStateEnded) {
                [self checkPassword2EnterEngineerMode];
            }
        }
#else
        if (tapGR.state == UIGestureRecognizerStateEnded) {
            [self checkPassword2EnterEngineerMode];
        }
#endif
    }

}

- (void) checkPassword2EnterEngineerMode
{
    UIAlertView *alert = [UIAlertView alertViewWithTitle:@"who are you?"
                            message:@""
                  cancelButtonTitle:@"cancel"
                  otherButtonTitles:@[@"enter"]
                          onDismiss:^(id respond, int buttonIndex) {
                              NSString *pw = [((UIAlertView *)respond)textFieldAtIndex:1].text;
                              if ([pw isEqualToString:g_defaultEngineerModePassword]) {
                                  [self activeEnterEngineerFunction];
                              }
                          } onCancel:^(id respond) {
                              
                          }];

    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    
    [alert show];
}

- (void) activeEnterEngineerFunction
{
    
}

#pragma mark - life

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    //// 離開View時  取消需要取消的api
    //// 不需要取消的則會繼續執行 但是delegate清掉
    for (TMAPIModel *object in [self.activeAPIs allValues]) {
        if (object.mode == TMAPI_Mode_Leave_With_Cancel) {
            [object cancel];
        }
        
        object.delegate = nil;
    }
    
    /// 從觀察清單中移除
    [self.activeAPIs removeAllObjects];
    
    //// 移除keyboardWatchItem
    for (NSString *key in self.keyboardWatchList) {
        [[TMKeyboardController defaultTMKeyboardController] removeWithKey:key];
    }
    
}

- (id) initWithUniversal
{
    NSString *className = NSStringFromClass([self class]);
    NSString *nibName = nil;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        nibName = [NSString stringWithFormat:@"%@_iPhone", className];
    } else {
        nibName = [NSString stringWithFormat:@"%@_iPad", className];
    }
    
    return [self initWithNibName:nibName bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSMutableDictionary *) activeAPIs
{
    if (_activeAPIs) {
        return _activeAPIs;
    }
    
    _activeAPIs = [[NSMutableDictionary alloc] init];
    return _activeAPIs;
}

- (NSMutableArray *) loadingImageViews
{
    if (_loadingImageViews) {
        return _loadingImageViews;
    }
    
    _loadingImageViews = [[NSMutableArray alloc] init];
    return _loadingImageViews;
}

- (NSMutableArray *) keyboardWatchList
{
    if (_keyboardWatchList) {
        return _keyboardWatchList;
    }
    
    _keyboardWatchList = [[NSMutableArray alloc] init];
    return _keyboardWatchList;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    //// 清除掉已經結束的api
    NSMutableArray *removeObjs = [[NSMutableArray alloc] init];
    for (TMAPIModel *object in [self.activeAPIs allValues]) {
        if (object.state == TMAPI_State_Finished
            || (object.cacheType == TMAPI_Cache_Type_None && object.state == TMAPI_State_Failed)) {
            [removeObjs addObject:object.key];
        }
    }
    
    [self.activeAPIs removeObjectsForKeys:removeObjs];
    
    
    if ([self isViewLoaded] && [self.view window] == nil)
    {
        // Add code to preserve data stored in the views that might be
        // needed later.
        
        // Add code to clean up other strong references to the view in
        // the view hierarchy.
        
        //// 移除 all url -> iv 的連結 (但是圖片還是會繼續下載到Cache中)
        [[TMImageCacheControl defaultTMImageCacheControl] removeListonImageViews:self.loadingImageViews];
        self.loadingImageViews = nil;
        
        self.view = nil;
    }
}

@end
