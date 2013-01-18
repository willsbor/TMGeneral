//
//  TMTableViewController.m
//  TMGeneral
//
//  Created by willsborKang on 13/1/18.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import "TMTableViewController.h"
#import "TMImageCacheControl.h"
#import "TMKeyboardController.h"

@interface TMTableViewController () <TMAPIModelProtocol, UITextViewDelegate, TMKeyboardDelegate>
{
    NSMutableArray *_loadingImageViews;
    NSMutableArray *_keyboardWatchList;
}

@end

@implementation TMTableViewController

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
    TMAPIModel *object = [_activeAPIs objectForKey:aKey];
    if (object != nil) {
        /// 取消api動作
        if (object.mode == TMAPI_Mode_Leave_With_Cancel) {
            [object cancel];
        }
        object.delegate = nil;
        
        /// 從清單中移除
        [_activeAPIs removeObjectForKey:aKey];
    }
}

- (id) apiModelByKey:(NSString *)aKey
{
    return [_activeAPIs objectForKey:aKey];
}

- (void) executeAPI:(TMAPIModel *)aModel
{
    [self executeAPI:aModel withKey:[NSString stringWithFormat:@"%@", [NSDate date]]];
}

- (void) executeAPI:(TMAPIModel *)aModel withKey:(NSString *)aKey
{
    TMAPIModel *object = [_activeAPIs objectForKey:aKey];
    
    if (object != nil) {
        if (object.mode == TMAPI_Mode_Leave_With_Cancel) {
            [object cancel];
        }
        object.delegate = nil;
    }
    
    [_activeAPIs setObject:aModel forKey:aKey];
    
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
    if (aPlaceholder != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ICC setImageURL:aURL
                 toImageView:aImageView
                     withTag:aTag
                     andType:aType
                  andOptions:[NSDictionary dictionaryWithObjectsAndKeys:
                              aPlaceholder, TM_IMAGE_CACHE_PLACEHOLDER_IMAGE,
                              nil]];
        });
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ICC setImageURL:aURL
                 toImageView:aImageView
                     withTag:aTag
                     andType:aType];
        });
    }
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
    for (NSString *key in _keyboardWatchList) {
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
    if ( [_keyboardWatchList containsObject:key] ) {
        item = [[TMKeyboardController defaultTMKeyboardController] getKeyboardItemWithKey:key];
    } else {
        [_keyboardWatchList addObject:key];
        
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
    if ( [_keyboardWatchList containsObject:key] ) {
        item = [[TMKeyboardController defaultTMKeyboardController] getKeyboardItemWithKey:key];
    } else {
        [_keyboardWatchList addObject:key];
        
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
        for (NSString *key in _keyboardWatchList) {
            [self hideKeyBoard:key];
        }
    }
}

#pragma mark - life

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //// 離開View時  取消需要取消的api
    //// 不需要取消的則會繼續執行 但是delegate清掉
    for (TMAPIModel *object in [_activeAPIs allValues]) {
        if (object.mode == TMAPI_Mode_Leave_With_Cancel) {
            [object cancel];
        }
        
        object.delegate = nil;
    }
    
    /// 從觀察清單中移除
    [_activeAPIs removeAllObjects];
    
    //// 移除keyboardWatchItem
    for (NSString *key in _keyboardWatchList) {
        [[TMKeyboardController defaultTMKeyboardController] removeWithKey:key];
    }
    
    //// 移除 all url -> iv 的連結 (但是圖片還是會繼續下載到Cache中)
    [[TMImageCacheControl defaultTMImageCacheControl] removeListonImageViews:_loadingImageViews];
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
        _activeAPIs = [[NSMutableDictionary alloc] init];
        _loadingImageViews = [[NSMutableArray alloc] init];
        _keyboardWatchList = [[NSMutableArray alloc] init];
    }
    return self;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        _activeAPIs = [[NSMutableDictionary alloc] init];
        _loadingImageViews = [[NSMutableArray alloc] init];
        _keyboardWatchList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    _loadingImageViews = nil;
    _keyboardWatchList = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    //// 清除掉已經結束的api
    NSMutableArray *removeObjs = [[NSMutableArray alloc] init];
    for (TMAPIModel *object in [_activeAPIs allValues]) {
        if (object.state == TMAPI_State_Finished
            || (object.cacheType == TMAPI_Cache_Type_None && object.state == TMAPI_State_Failed)) {
            [removeObjs addObject:object.key];
        }
    }
    
    [_activeAPIs removeObjectsForKeys:removeObjs];
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
 
}
*/
@end
