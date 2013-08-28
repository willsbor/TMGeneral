//
//  TMRotateNavigationController.m
//  TMGeneral
//
//  Created by willsborKang on 13/8/28.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import "TMRotateNavigationController.h"

@interface TMRotateNavigationController ()

@end

@implementation TMRotateNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _rotateStateMask = UIInterfaceOrientationMaskAll;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _rotateStateMask = UIInterfaceOrientationMaskAll;
    }
    
    return self;
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
}

- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations
{
    return _rotateStateMask;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (_rotateStateMask & (1 << toInterfaceOrientation));
}

@end
