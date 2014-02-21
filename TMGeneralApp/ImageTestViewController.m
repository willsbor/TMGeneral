//
//  ImageTestViewController.m
//  TMGeneral
//
//  Created by willsborKang on 13/5/16.
//  Copyright (c) 2013年 thinkermobile. All rights reserved.
//

#import "ImageTestViewController.h"
#import <GPUImage/GPUImage.h>

@interface ImageTestViewController ()

@end

@implementation ImageTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.targetImage.image = self.originImage.image;
    
    //// GPU Test
    
#if 0   ///iOS 6
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIImage *inputImage = [[CIImage alloc] initWithImage:self.targetImage.image];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    
    [filter setValue:inputImage forKey:kCIInputImageKey];
    
    [filter setValue:[NSNumber numberWithFloat:5.0f] forKey:@"inputRadius"];
    
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    CGImageRef cgImage = [context createCGImage:result fromRect:[result extent]];
    
    self.targetImage.image = [UIImage imageWithCGImage:cgImage];
#else
    UIImage *inputImage = [UIImage imageNamed:@"33.jpg"];
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
    
    // Linear downsampling
    GPUImageGaussianBlurPositionFilter *passthroughFilter = [[GPUImageGaussianBlurPositionFilter alloc] init];
    passthroughFilter.blurSize = 10.0;
    [stillImageSource addTarget:passthroughFilter];
    [stillImageSource processImage];
    UIImage *nearestNeighborImage = [passthroughFilter imageFromCurrentlyProcessedOutput];

    self.targetImage.image = nearestNeighborImage;
    
#endif
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

- (void)viewDidUnload {
    [self setOriginImage:nil];
    [self setTargetImage:nil];
    [super viewDidUnload];
}
@end
