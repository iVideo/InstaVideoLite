//
//  ILTrimViewController.m
//  InstaVideoLite
//
//  Created by insta on 9/17/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILTrimViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ILNavBarView.h"

@interface ILTrimViewController ()
{
    CGFloat midHeight;
    AVAssetImageGenerator *generator;
    
    NSURL *assetURL;
}

@property (strong, nonatomic) UIView *topView; //Container
@property (strong, nonatomic) UIScrollView *playerView;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) UIButton *btnPlay;
@property (strong, nonatomic) UIImageView *imgPreview;
@property (strong, nonatomic) UIView *toggleView;

@property (strong, nonatomic) UIView *midView;
@property (strong, nonatomic) UIView *controlView;
@property (strong, nonatomic) UIImageView *timespanView;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *leftBar;
@property (strong, nonatomic) UIButton *rightBar;
@property (strong, nonatomic) UIButton *trackBar;

@property (strong, nonatomic) ILNavBarView *navBarView;

@end

@implementation ILTrimViewController

- (void)dealloc
{
    _moviePlayer = nil;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerThumbnailImageRequestDidFinishNotification
                                                  object:_moviePlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMovieNaturalSizeAvailableNotification
                                                  object:_moviePlayer];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initialization];
    [self createTopView];
    [self createMidView];
    [self createNavView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init

- (void)initialization
{
    assetURL = [IL_DATA popURL];
}

#pragma mark - midView

- (void)createMidView
{
    midHeight = IL_SCREEN_H - IL_PLAYER_H - IL_NAVBAR_H;
    _midView = [[UIView alloc] initWithFrame:CGRectMake(.0f, IL_PLAYER_H,IL_SCREEN_W,midHeight)];
    _midView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bk_bar"]];
    [self.view addSubview:_midView];
    
    _timespanView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"time"]];
    [_timespanView setFrame:CGRectMake(.0f, midHeight - 26.f, IL_SCREEN_W, 26.f)];
    [_midView addSubview:_timespanView];
    
    [self createFrameView];
    [self addPanGestures];
    [self createScrollView];
}

- (void)createFrameView
{
    _controlView = [[UIView alloc] initWithFrame:CGRectMake(0.f, midHeight/2 - 57.f, IL_SCREEN_W, 88.f)];
    _controlView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"blue_btn"]];
    [_midView addSubview:_controlView];
    
    _trackBar = [UIButton buttonWithType:UIButtonTypeCustom];
    [_trackBar setFrame:CGRectMake(22.f, midHeight/2 - 65.f, 4.f, 104.f)];
    [_trackBar setImage:[UIImage imageNamed:@"compose_big_btn"] forState:UIControlStateNormal];
    [_midView insertSubview:_trackBar aboveSubview:_controlView];
    
    _leftBar = [UIButton buttonWithType:UIButtonTypeCustom];
    [_leftBar setFrame:CGRectMake(10.f, 30.f, 4.f, 28.f)];
    [_leftBar setImage:[UIImage imageNamed:@"compose_small_btn"] forState:UIControlStateNormal];
    [_controlView addSubview:_leftBar];
    
    _rightBar = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightBar setFrame:CGRectMake(IL_SCREEN_W - 14.f, 30.f, 4.f, 28.f)];
    [_rightBar setImage:[UIImage imageNamed:@"compose_small_btn"] forState:UIControlStateNormal];
    [_controlView addSubview:_rightBar];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(20.f, 1.f, IL_SCREEN_W - 40.f, 86.f)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [_controlView insertSubview:_scrollView atIndex:0 ];

}

- (void)addPanGestures
{
    UIPanGestureRecognizer *lefebarPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panLeftBar:)];
    [_leftBar addGestureRecognizer:lefebarPan];
    
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRightBar:)];
    [_rightBar addGestureRecognizer:rightPan];
    
    UIPanGestureRecognizer *trackPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panTrackBar:)];
    [_trackBar addGestureRecognizer:trackPan];
}

- (void)createScrollView
{
    AVAsset *asset = [AVAsset assetWithURL:assetURL];
    //300px 15sec
    Float64 rectsize = 88.f;
    generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    Float64 duration = CMTimeGetSeconds([asset duration]);
    CGFloat contentsize = rectsize * ceilf(duration) ;
    generator.maximumSize = CGSizeMake(contentsize, rectsize);
    generator.appliesPreferredTrackTransform = YES;
    CMTime actualTime;
    NSError *error;
    for (int i = 0; i < duration; i++) {
        CMTime time = CMTimeMakeWithSeconds(i, 600);
        CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:imgRef]];
        CGImageRelease(imgRef);
        imageView.frame = CGRectMake(i * rectsize, 1.f, rectsize-1.f, rectsize-1.f);
        [_scrollView addSubview:imageView];
    }

    [_scrollView setContentSize:CGSizeMake(contentsize, rectsize - 2)];
}

#pragma mark - panGesture
- (void)panLeftBar:(UIPanGestureRecognizer *)recognizer
{
    UIView *view = recognizer.view;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (view.center.x < 6) {
                return;
            }
            if (view.center.x > IL_SCREEN_W - 6) {
                return;
            }
            
            CGPoint offset = [recognizer translationInView:view];
            view.center = CGPointMake(view.center.x + offset.x, view.center.y);
            [recognizer setTranslation:CGPointZero inView:view];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            
        }
            break;
            
        default:
            break;
    }
    
}

- (void)panRightBar:(UIPanGestureRecognizer *)recognizer
{
    UIView *view = recognizer.view;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (view.center.x < 6) {
                return;
            }
            if (view.center.x > IL_SCREEN_W - 6) {
                return;
            }
            
            CGPoint offset = [recognizer translationInView:view];
            view.center = CGPointMake(view.center.x + offset.x, view.center.y);
            [recognizer setTranslation:CGPointZero inView:view];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            
        }
            break;
            
        default:
            break;
    }
    
}

- (void)panTrackBar:(UIPanGestureRecognizer *)recognizer
{
    UIView *view = recognizer.view;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (view.center.x < 6) {
                return;
            }
            if (view.center.x > IL_SCREEN_W - 6) {
                return;
            }
            
            CGPoint offset = [recognizer translationInView:view];
            view.center = CGPointMake(view.center.x + offset.x, view.center.y);
            [recognizer setTranslation:CGPointZero inView:view];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - topView

- (void)createTopView
{
    _topView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, IL_PLAYER_W, IL_PLAYER_H)];
    _topView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_topView];
    
    [self createPlayerView];
    [self createPlayButton];
}

- (void)createPlayerView
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"skateboarding" ofType:@"m4v"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [_moviePlayer.view setFrame:CGRectMake(0.f, 0.f, IL_PLAYER_W, IL_PLAYER_H)];
    [_moviePlayer setControlStyle:MPMovieControlStyleNone];
    [_moviePlayer setScalingMode:MPMovieScalingModeAspectFill];
    [_moviePlayer setRepeatMode:MPMovieRepeatModeOne];
    [_moviePlayer setShouldAutoplay:YES];
    [_moviePlayer prepareToPlay];
    
    _playerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.f, 0.f, IL_PLAYER_W, IL_PLAYER_H)];
    [_playerView addSubview:_moviePlayer.view];
    
    [_topView addSubview:_playerView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieNaturalSizeAvailable:) name:MPMovieNaturalSizeAvailableNotification object:_moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieThumbnailLoadComplete:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:_moviePlayer];
}

- (void)movieThumbnailLoadComplete:(NSNotification*)notification
{
    NSLog(@"movieThumbnailLoadComplete notification");
}

- (void)movieNaturalSizeAvailable:(NSNotification*)notification
{
    float height = _moviePlayer.naturalSize.height;
    float width = _moviePlayer.naturalSize.width;
    float ratio = MAX(IL_PLAYER_H / height, IL_PLAYER_W / width);
    
    [_moviePlayer.view setFrame:CGRectMake(0.f, 0.f, width*ratio, height*ratio)];
    [_playerView setContentSize:_moviePlayer.view.frame.size];
    [_playerView setScrollsToTop:NO];
    [_playerView setCenter:_topView.center];
    [_topView bringSubviewToFront:_btnPlay];
}

- (void)createPlayButton
{
    CGRect btnPlayFrame = CGRectMake(IL_PLAYER_W/2 - 35.f, IL_PLAYER_H/2, 70.f, 70.f);
    _btnPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnPlay.frame = btnPlayFrame;
    _btnPlay.center = _moviePlayer.view.center;
    [_btnPlay setImage:[UIImage imageNamed:@"Pause"] forState:UIControlStateNormal];
    [_btnPlay setImage:[UIImage imageNamed:@"play"] forState:UIControlStateSelected];
    [_btnPlay addTarget:self action:@selector(btnPlayPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_btnPlay];
}

- (void)btnPlayPressed:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (!sender.selected) {
        [_moviePlayer pause];
        return;
    }
    [_moviePlayer play];
}

#pragma mark - naviBarView

- (void)createNavView
{
    _navBarView = [[ILNavBarView alloc] initWithFrame:CGRectMake(.0f, IL_SCREEN_H - IL_COMMON_H, IL_SCREEN_W, IL_COMMON_H)];
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
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
