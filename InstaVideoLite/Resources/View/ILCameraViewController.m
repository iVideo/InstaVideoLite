//
//  ILCameraViewController.m
//  InstaVideoLite
//
//  Created by insta on 9/12/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILCameraViewController.h"

#import "ILPhotosViewController.h"
#import "ILRecordProgressView.h"
#import "ILVideoComposition.h"
#import "ILVideoClip.h"
#import "ILNavBarView.h"
#import "GPUImage.h"

#define OVERLAY_HEIGHT  320.0
#define PAN_TIMING      0.5f
#define IL_DEVICE_SIZE  [[UIScreen mainScreen] bounds].size

@interface ILCameraViewController ()
{
    UIPanGestureRecognizer *selectPanGesture;
    CGPoint finalPoint;
    
    GPUImageVideoCamera     *videoCamera;
    GPUImageView            *videoView;
    GPUImageMovieWriter     *movieWriter;
    ILRecordProgressView    *progressView;
//    NTRecProgressView       *progressView;
    
    ILVideoComposition      *composition;
    ILVideoClip             *videoTake;
    NSURL *movieURL;
    
//    GPUImageMovieWriter     *movieWriter;
//    ILVideoComposition      *composition;
//    ILVideoClip             *videoTake;
//    NSURL *movieURL;
}
@property (strong, nonatomic) ILNavBarView *navBarView;

//@property (strong, nonatomic) GPUImageVideoCamera *videoCamera;
//@property (strong, nonatomic) GPUImageView *videoView;

@property (strong, nonatomic) UIView *controlView;
@property (strong, nonatomic) UIButton *btnDelete;
@property (strong, nonatomic) UIButton *btnRecord;
@property (strong, nonatomic) UIButton *btnCamera;
//@property (strong, nonatomic) ILRecordProgressView *progressView;

@property (strong, nonatomic) ILPhotosViewController *photosView;

@end

@implementation ILCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createControlView];
    [self createCameraView];
    [self createNavBar];
    
//    [self createSelectView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- cameraView ---
- (void)createControlView
{
    //Control view
    CGFloat controlHeight = IL_SCREEN_H - IL_CAMERA_H - IL_NAVBAR_H;
    _controlView = [[UIView alloc] initWithFrame:
                    CGRectMake(0, IL_CAMERA_H, IL_CAMERA_W, controlHeight)];
    [_controlView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_controlView];
    
    //Progress view
    progressView = [[ILRecordProgressView alloc] initWithFrame: CGRectMake(0, 0, IL_CAMERA_W, 10)];
    [_controlView addSubview:progressView];
    
    //Record button
    _btnRecord = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnRecord setFrame:CGRectMake(IL_SCREEN_W/2 - 50, controlHeight/2 - 50, 100, 100)];
    //    [_btnRecord setCenter:_controlView.center];
    [_btnRecord setImage:[UIImage imageNamed:@"Video_btn"] forState:UIControlStateNormal];
    [_btnRecord addTarget:self action:@selector(btnRecordPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_controlView addSubview:_btnRecord];
    
    //Delete button
    _btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnDelete setFrame:CGRectMake(20, controlHeight/2 - 22, 70, 44)];
    [_btnDelete setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [_btnDelete setImage:[UIImage imageNamed:@"delete-"] forState:UIControlStateHighlighted];
    [_btnDelete setImage:[UIImage imageNamed:@"delete_done"] forState:UIControlStateSelected];
    [_btnDelete addTarget:self action:@selector(btnDeletePressed:) forControlEvents:UIControlEventTouchUpInside];
    [_controlView addSubview:_btnDelete];
    
    _btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnCamera setFrame:CGRectMake(IL_SCREEN_W - 90, controlHeight/2 - 26, 64, 52)];
    [_btnCamera setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [_btnCamera addTarget:self action:@selector(btnCameraPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_controlView addSubview:_btnCamera];
}
- (void)createCameraView
{
    // Camera
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    // Preview view
    videoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, IL_CAMERA_W, IL_CAMERA_H)];
    videoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view insertSubview: videoView atIndex: 0];
    
    // Record Settings
    NSString *moviePath = [NSHomeDirectory() stringByAppendingPathComponent:
                           [[NSString alloc] initWithFormat:@"Documents/movie_%u.m4v",arc4random()]
                           ];
    unlink([moviePath UTF8String]);
    movieURL = [[NSURL alloc] initFileURLWithPath:moviePath];
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
    movieWriter.encodingLiveVideo = YES;
    
    // Tap Gesture
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(longPressGestureRecognized:)];
    gesture.minimumPressDuration = 0.25;
    [videoView addGestureRecognizer: gesture];
    
    // Setting
    [videoCamera addTarget: videoView];
    [videoCamera startCameraCapture];
    
    // Video composition
    composition     = [[ILVideoComposition alloc] init];
    progressView.composition = composition;
    
}

- (void)btnRecordPressed:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (!sender.selected) {
        [self startRecording];
    }
    else {
        [self pauseRecording];
    }
}

- (void)btnDeletePressed:(UIButton *)sender
{
    if ([composition isLastTakeReadyToRemove]){
        [composition removeLastVideoClip];
    } else {
        composition.isLastTakeReadyToRemove = YES;
    }
    sender.selected = composition.isLastTakeReadyToRemove;
    [progressView setNeedsDisplay];
}

- (void)btnCameraPressed:(UIButton *)sender
{
    [videoCamera rotateCamera];
}


#pragma mark

- (void) startRecording
{
    [self doesStartRecording];
}

- (void) doesStartRecording
{
    if ([composition canAddVideoClip]){
        [composition setRecording: YES];
        _btnDelete.selected = NO;
        
        // Record Settings
        NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate] * 1000; // Create random unique path for the temporary video file
        NSString *path = [NSString stringWithFormat: @"Movie_%d.m4v", (int)time];
        NSString *pathToMovie = [NSTemporaryDirectory() stringByAppendingPathComponent:path];
        unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
        movieURL        = [NSURL fileURLWithPath:pathToMovie];
        movieWriter     = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
        
        videoTake = [[ILVideoClip alloc] init];
        videoTake.videoPath = movieURL;
        [composition addVideoClip: videoTake];
        
        [videoCamera addTarget: movieWriter];
        videoCamera.audioEncodingTarget = movieWriter;
        [movieWriter startRecording];
    }
}

- (void) pauseRecording
{
    [composition setRecording: NO];
    
    [videoCamera removeTarget:movieWriter];
    videoCamera.audioEncodingTarget = nil;
    
    float duration          = CMTimeGetSeconds(movieWriter.duration);
    videoTake.duration    = duration;
    
    [movieWriter finishRecordingWithCompletionHandler:^{
        NSLog(@"finishRecording");
    }];
}

- (void) longPressGestureRecognized:(UILongPressGestureRecognizer *) gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self startRecording];
            break;
        case UIGestureRecognizerStateEnded:
            [self pauseRecording];
            break;
        default:
            break;
    }
}

- (IBAction) stopRecording:(id)sender
{
    [composition concatenateVideosWithCompletionHandler:^(AVAssetExportSessionStatus status){
        if (status == AVAssetExportSessionStatusCompleted){
            [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error == nil) {
                    NSLog(@"Movie saved");
                } else {
                    NSLog(@"Error %@", error);
                }
            }];
        }
    }];
}

#pragma mark -- navbarView ---
- (void)createNavBar
{
    _navBarView = [[ILNavBarView alloc] initWithFrame:CGRectMake(0, IL_SCREEN_H - 44, IL_SCREEN_W, 44)];
    [_navBarView.btnBack addTarget:self action:@selector(btnBackPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_navBarView.btnNext addTarget:self action:@selector(btnNextPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_navBarView];
}

- (void)btnBackPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnNextPressed:(UIButton *)sender
{
    
}

#pragma mark -- selectView ---

- (void)createSelectView
{
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
    
}


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


@end
