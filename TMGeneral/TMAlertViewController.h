//
//  TMAlertViewController.h
//  TMGeneral
//
//  Created by willsborKang on 13/10/7.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import "TMViewController.h"

typedef enum
{
    TMAlertType_OK,
    TMAlertType_Cancel_OK,
    TMAlertType_None,
} TMAlertType;

@interface TMAlertViewController : TMViewController

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *contentTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentTextLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cancelBtns;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *okBtns;
@property (weak, nonatomic) IBOutlet UIView *cancelokView;
@property (weak, nonatomic) IBOutlet UIView *okView;
@property (weak, nonatomic) IBOutlet UIView *noneProcessingView;

@property (weak, nonatomic) IBOutlet UIView *grayBackgroundView;
@property (strong, nonatomic) UIColor *grayColorOfBackground;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic) TMAlertType type;

@property (copy, nonatomic) void (^action)(void);
@property (copy, nonatomic) void (^actionForCancel)(void);

//// 有預設動作
//// 如果有客製化動作則輸入新的block
@property (copy, nonatomic) void (^showAnimation)(TMAlertViewController *alertVC, void (^animationfinish)(void));
@property (copy, nonatomic) void (^hideAnimation)(TMAlertViewController *alertVC, void (^animationfinish)(void));

+ (void) resetGrayMaskCount;

/// 主動顯示用這個
- (void) show;

/// 主動消失用 下面兩個其中一個
- (void) clickDoAction;
- (void) clickCancel;

/// over load if need
- (BOOL) shouldClickCancel;
- (BOOL) shouldClickDoAction;

/// 如果base vc 無法藉由預設方式取得時，需要重新設計
- (UIViewController *) baseVC;

@end
