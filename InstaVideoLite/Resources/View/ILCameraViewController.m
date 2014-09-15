//
//  ILCameraViewController.m
//  InstaVideoLite
//
//  Created by insta on 9/12/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILCameraViewController.h"

#import "ILPhotosViewController.h"
//#import "GPUImage.h"

#define OVERLAY_HEIGHT  320.0
#define PAN_TIMING      0.5f
#define IL_DEVICE_SIZE  [[UIScreen mainScreen] bounds].size

@interface ILCameraViewController ()
{
    UIPanGestureRecognizer *selectPanGesture;
    CGPoint finalPoint;
}

//@property (strong, nonatomic) GPUImageVideoCamera *videoCamera;
//@property (strong, nonatomic) GPUImageView *videoView;

@property (strong, nonatomic) ILPhotosViewController *photosView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

- (IBAction)btnBackPressed:(id)sender;
- (IBAction)btnNextPressed:(id)sender;

@end

@implementation ILCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _photosView = [[ILPhotosViewController alloc] initWithNibName:@"ILPhotosViewController" bundle:nil];
    _photosView.view.frame = CGRectMake(0, OVERLAY_HEIGHT, _photosView.view.frame.size.width, _photosView.view.frame.size.height);
    
    //add the overlay as child view controller
    [self addChildViewController:_photosView];
    [self.view addSubview:_photosView.view];
    
    [_photosView didMoveToParentViewController:self];
    
    
    selectPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSelectView:)];
    [selectPanGesture setDelegate:self];
    [_photosView.view  addGestureRecognizer:selectPanGesture];
    
    UITapGestureRecognizer *selectTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelectVC:)];
    [selectTapGesture setDelegate:self];
    [_photosView.view addGestureRecognizer:selectTapGesture];
    
    
    
    
    
    
    // Camera
//    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
//    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
//    _videoCamera.horizontallyMirrorFrontFacingCamera = NO;
//    _videoCamera.horizontallyMirrorRearFacingCamera = NO;
//    
//    // Preview view
//    _videoView = [[GPUImageView alloc] initWithFrame: self.view.frame];
//    _videoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
//    [self.view insertSubview: _videoView atIndex: 0];
//    
//    // Setting
//    [_videoCamera addTarget: _videoView];
//    [_videoCamera startCameraCapture];
    
    
    //    // Record Settings
    //    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    //    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    //    movieURL        = [NSURL fileURLWithPath:pathToMovie];
    //    movieWriter     = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
    //    movieWriter.encodingLiveVideo = YES;
    //
    //
    //    // Tap Gesture
    //    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(longPressGestureRecognized:)];
    //    gesture.minimumPressDuration = 0.25;
    //    [videoView addGestureRecognizer: gesture];
    //
    //
    //    // Video composition
    //    composition     = [[NTVideoComposition alloc] init];
    //    progressView.composition = composition;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- selectView ---


- (void)tapSelectVC:(id)sender
{
    
}

-(void)toggleSelectView:(id)sender
{
    UIGestureRecognizerState state = [(UIPanGestureRecognizer *) sender state];
    if (state == UIGestureRecognizerStateBegan) {
        
    } else if (state == UIGestureRecognizerStateChanged) {
        
        [self changedTranslateSelectView:sender];
        [self resetFinalPoint:sender];
        
    } else if (state == UIGestureRecognizerStateEnded) {
        [self endedTranslateSelectView:sender];
    }
}

- (void)changedTranslateSelectView:(id)sender
{
    CGPoint translatedPoint = [(UIPanGestureRecognizer *) sender translationInView:self.view];
    CGRect selectFrame = _photosView.view.frame ;
    selectFrame.origin.y = selectFrame.origin.y + translatedPoint.y;
    _photosView.view.frame = selectFrame;
    [sender setTranslation:CGPointZero inView:self.view];
}

- (void)endedTranslateSelectView:(id)sender
{
    [UIView animateWithDuration:PAN_TIMING delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        CGRect selectFrame = _photosView.view.frame;
        selectFrame.origin = finalPoint;
        _photosView.view.frame = selectFrame;
        [sender setTranslation:CGPointZero inView:self.view];
        
    } completion:^(BOOL finished) {
        
        
    }];
}

- (void)resetFinalPoint:(id)sender
{
    CGPoint velocity = [(UIPanGestureRecognizer *)sender velocityInView:self.view];
    if (velocity.y < 0) {
        finalPoint = CGPointMake(0, 0);
    } else if (velocity.y > 360) {
        finalPoint = CGPointMake(0, IL_DEVICE_SIZE.height);
    }else {
        finalPoint = CGPointMake(0, OVERLAY_HEIGHT);
    }
}


- (IBAction)btnBackPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnNextPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}



@end
