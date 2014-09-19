//
//  ILCameraViewController.m
//  InstaVideoLite
//
//  Created by insta on 9/12/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILCameraViewController.h"

#import "ILRecordProgressView.h"
#import "ILVideoComposition.h"
#import "ILVideoClip.h"

#import "GPUImage.h"

//#define OVERLAY_HEIGHT  320.f
//#define PAN_TIMING      0.5f

@interface ILCameraViewController ()
{
    UIPanGestureRecognizer *selectPanGesture;
    CGPoint finalPoint;
    
    GPUImageVideoCamera     *videoCamera;
    GPUImageView            *videoView;
    GPUImageMovieWriter     *movieWriter;
    ILRecordProgressView    *progressView;
    
    ILVideoClip             *videoTake;
    NSURL *movieURL;
    
    BOOL isFinished;
}
@property (strong, nonatomic) ILNavBarView *navBarView;

@property (strong, nonatomic) ILVideoComposition *composition;

@property (strong, nonatomic) UIView *controlView;
@property (strong, nonatomic) UIButton *btnDelete;
@property (strong, nonatomic) UIButton *btnRecord;
@property (strong, nonatomic) UIButton *btnCamera;
@property (strong, nonatomic) UIButton *btnAlbums;

//@property (strong, nonatomic) ILAlbumViewController *albumView;

@end

@implementation ILCameraViewController

- (void)dealloc
{
//    [self removeSelectView];
}

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
    progressView = [[ILRecordProgressView alloc] initWithFrame: CGRectMake(0, 0, IL_CAMERA_W - 10, 10)];
    [_controlView addSubview:progressView];
    
    //Record button
    _btnRecord = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnRecord setFrame:CGRectMake(IL_SCREEN_W/2 - 50, controlHeight/2 - 50, 100, 100)];
    //    [_btnRecord setCenter:_controlView.center];
    [_btnRecord setImage:[UIImage imageNamed:@"Video_btn"] forState:UIControlStateNormal];
//    [_btnRecord addTarget:self action:@selector(btnRecordPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_btnRecord addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnRecordLongPressed:)]];
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
    _btnCamera.hidden = YES;
    
    _btnAlbums = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnAlbums setFrame:CGRectMake(IL_SCREEN_W - 90, controlHeight/2 - 26, 64, 52)];
    [_btnAlbums setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [_btnAlbums addTarget:self action:@selector(btnAlbumsPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_controlView addSubview:_btnAlbums];
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
    
    // Tap Gesture
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(longPressGestureRecognized:)];
    gesture.minimumPressDuration = 0.25;
    [videoView addGestureRecognizer: gesture];
    
    // Setting
    [videoCamera addTarget: videoView];
    [videoCamera startCameraCapture];
    
    // Video composition
    _composition     = [[ILVideoComposition alloc] init];
    progressView.composition = _composition;
    
}

- (void)btnRecordLongPressed:(UILongPressGestureRecognizer *)gesture
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

- (void)btnRecordPressed:(UIButton *)sender
{
    if (!sender.selected) {
        [self startRecording];
    }
    else {
        [self pauseRecording];
    }
    sender.selected = !sender.selected;
}

- (void)btnDeletePressed:(UIButton *)sender
{
    if ([_composition isLastTakeReadyToRemove]){
        [_composition removeLastVideoClip];
    } else {
        _composition.isLastTakeReadyToRemove = YES;
    }
    sender.selected = _composition.isLastTakeReadyToRemove;
    [progressView setNeedsDisplay];
}

- (void)btnCameraPressed:(UIButton *)sender
{
    [videoCamera rotateCamera];
}

- (void)btnAlbumsPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"photos" sender:self];
}

#pragma mark

- (void) startRecording
{
    [self doesStartRecording];
}

- (void) doesStartRecording
{
    if ([_composition canAddVideoClip]){
        [_composition setRecording: YES];
        _btnDelete.selected = NO;
        isFinished = NO;
        
        // Record Settings
        NSString *moviePath = [NSTemporaryDirectory() stringByAppendingPathComponent:
                               [[NSString alloc] initWithFormat:@"movie_%u.m4v",arc4random()]];
        unlink([moviePath UTF8String]);
        movieURL = [[NSURL alloc] initFileURLWithPath:moviePath];
        movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL
                                                               size:CGSizeMake(480.0, 640.0)];
        movieWriter.encodingLiveVideo = YES;
        
        videoTake = [[ILVideoClip alloc] init];
        videoTake.videoURL = movieURL;
        [_composition addVideoClip: videoTake];
        
        [videoCamera addTarget: movieWriter];
        videoCamera.audioEncodingTarget = movieWriter;
        [movieWriter startRecording];
    }
}

- (void) pauseRecording
{
//    [_navBarView startWaiting];
    [_composition setRecording: NO];
    
    [videoCamera removeTarget:movieWriter];
    videoCamera.audioEncodingTarget = nil;
    
    float duration = CMTimeGetSeconds(movieWriter.duration);
    videoTake.duration = duration;
    
    [movieWriter finishRecordingWithCompletionHandler:^{
//        [_navBarView stopWaited];
        isFinished = YES;
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
    if (isFinished == NO) {
        return;
    }
    NSArray *clips = [[_composition getVideoClips] copy];
    [_composition clearVideoClips];
    for (ILVideoClip *clip in clips) {
        [IL_DATA addClipURL:[clip videoURL]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//#pragma mark -- selectView ---
//
//- (void)removeSelectView
//{
//    [_albumView removeFromParentViewController];
//    _albumView = nil;
//}
//
//- (void)createSelectView
//{
//
//    if (_albumView == nil) {
//        _albumView = [[ILAlbumViewController alloc] init];
////        _albumView = [[ILAlbumViewController alloc] initWithFrame:CGRectMake(0, IL_PLAYER_H, IL_SCREEN_W, IL_SCREEN_H)];
//        //add the overlay as child view controller
//        [self addChildViewController:_albumView];
//        [self.view addSubview:_albumView.view];
//        
//        [_albumView didMoveToParentViewController:self];
//    }
//
//    selectPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSelectView:)];
//    [selectPanGesture setDelegate:self];
//    [_albumView.view  addGestureRecognizer:selectPanGesture];
//    
////    UITapGestureRecognizer *selectTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelectVC:)];
////    [selectTapGesture setDelegate:self];
////    [_photosView.view addGestureRecognizer:selectTapGesture];
//    
//}
//
//
//- (void)tapSelectVC:(id)sender
//{
//    
//}
//
//-(void)toggleSelectView:(id)sender
//{
//    UIGestureRecognizerState state = [(UIPanGestureRecognizer *) sender state];
//    if (state == UIGestureRecognizerStateBegan) {
//        
//    } else if (state == UIGestureRecognizerStateChanged) {
//        
//        [self changedTranslateSelectView:sender];
//        [self resetFinalPoint:sender];
//        
//    } else if (state == UIGestureRecognizerStateEnded) {
//        [self endedTranslateSelectView:sender];
//    }
//}
//
//- (void)changedTranslateSelectView:(id)sender
//{
//    CGPoint translatedPoint = [(UIPanGestureRecognizer *) sender translationInView:self.view];
//    CGRect selectFrame = _albumView.view.frame ;
//    selectFrame.origin.y = selectFrame.origin.y + translatedPoint.y;
//    _albumView.view.frame = selectFrame;
//    [sender setTranslation:CGPointZero inView:self.view];
//}
//
//- (void)endedTranslateSelectView:(id)sender
//{
//    [UIView animateWithDuration:PAN_TIMING delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//        
//        CGRect selectFrame = _albumView.view.frame;
//        selectFrame.origin = finalPoint;
//        _albumView.view.frame = selectFrame;
//        [sender setTranslation:CGPointZero inView:self.view];
//        
//    } completion:^(BOOL finished) {
//        
//        
//    }];
//}
//
//- (void)resetFinalPoint:(id)sender
//{
//    CGPoint velocity = [(UIPanGestureRecognizer *)sender velocityInView:self.view];
//    if (velocity.y < IL_PLAYER_H) {
//        finalPoint = CGPointMake(0, - IL_PLAYER_H/2);
//    } else if (velocity.y > IL_SCREEN_H*3/4) {
//        finalPoint = CGPointMake(0, IL_SCREEN_H);
//    }else {
//        finalPoint = CGPointMake(0, IL_PLAYER_H);
//    }
//}


@end
