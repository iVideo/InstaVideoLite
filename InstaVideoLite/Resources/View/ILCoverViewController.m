//
//  ILCoverViewController.m
//  InstaVideoLite
//
//  Created by insta on 9/17/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILCoverViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ILNavBarView.h"
#import "ILShareViewController.h"


@interface ILCoverViewController ()
{
    NSString *path;
    
    CGFloat midHeight;
    
    AVAssetImageGenerator *generator;
    NSMutableArray *images;
}

@property (strong, nonatomic) UIView *topView; //Container
@property (strong, nonatomic) UIScrollView *playerView;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) UIButton *btnPlay;

@property (strong, nonatomic) UIView *midView;
@property (strong, nonatomic) UIView *coverView;
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) UIImageView *postImage;

@property (strong, nonatomic) ILNavBarView *navBarView;

@end

@implementation ILCoverViewController

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
    images = [[NSMutableArray alloc] initWithCapacity:1];
    
    path = [[NSBundle mainBundle] pathForResource:@"skateboarding" ofType:@"m4v"];
}

#pragma mark - MidView

- (void)createMidView
{
    midHeight = IL_SCREEN_H - IL_PLAYER_H - IL_NAVBAR_H;
    _midView = [[UIView alloc] initWithFrame:CGRectMake(.0f, IL_PLAYER_H,IL_SCREEN_W,midHeight)];
    _midView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bk_bar"]];;
    [self.view addSubview:_midView];
    
    [self createCoverView];
    [self generateImages];
    [self createPostImage];
}

- (void)createCoverView
{
    _coverView = [[UIView alloc] initWithFrame:CGRectMake(.0f, midHeight/2 - 39.f, IL_SCREEN_W, 78.f)];
    [_midView addSubview:_coverView];
    
    _maskView = [[UIView alloc] initWithFrame:_coverView.frame];
    _maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [_midView insertSubview:_maskView aboveSubview:_coverView];
    
}

- (void)generateImages
{
    Float64 rect_h = 78.f;
    
    AVAsset *asset = [AVAsset assetWithURL:[[NSURL alloc] initFileURLWithPath:path]];
    generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(IL_SCREEN_W - 2.f, rect_h - 2.f);
    Float64 duration = CMTimeGetSeconds([asset duration]);
    Float64 rect_w = IL_SCREEN_W / ceilf(duration);
    
    CMTime actualTime;
    NSError *error;
    for (int i = 0; i <= duration; i++) {
        CMTime time = CMTimeMakeWithSeconds(i, 600);
        CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage *image = [UIImage imageWithCGImage:imgRef];CGImageRelease(imgRef);[images addObject:image];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(i * rect_w + 1.f, 1.f, rect_w - 2.f, rect_h - 2.f);
        [_coverView addSubview:imageView];
    }
}

- (void)createPostImage
{
    CGImageRef postRef = [generator copyCGImageAtTime:kCMTimeZero actualTime:nil error:nil];
    _postImage = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:postRef]];
    [_postImage setFrame:CGRectMake(.0f, midHeight/2 - 46.f, 92.f, 92.f)];
    _postImage.userInteractionEnabled = YES;
    [_midView insertSubview:_postImage aboveSubview:_maskView];
    CGImageRelease(postRef);
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPostImage:)];
    [_postImage addGestureRecognizer:panGesture];
}

- (void)panPostImage:(UIPanGestureRecognizer *)recognizer
{
    UIView *view = recognizer.view;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint offset = [recognizer translationInView:view];
            view.center = CGPointMake(view.center.x + offset.x, view.center.y);
            [recognizer setTranslation:CGPointZero inView:view];
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (view.center.x < 49.f) {
                view.center = CGPointMake(49.f, view.center.y);
            }else if (view.center.x > IL_SCREEN_W - 49.f)
            {
                view.center = CGPointMake(IL_SCREEN_W - 49.f, view.center.y);
            }
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
    
    [_moviePlayer requestThumbnailImagesAtTimes:[NSArray arrayWithObject:[NSNumber numberWithDouble:0]] timeOption:MPMovieTimeOptionNearestKeyFrame];
}

- (void)movieThumbnailLoadComplete:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    _postImage.image = [userInfo objectForKey: @"MPMoviePlayerThumbnailImageKey"];
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
    
    NSLog(@"movieNaturalSizeAvailable notification");
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
    [_navBarView.btnNext setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [self.view addSubview:_navBarView];
}

- (void)btnBackPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnNextPressed:(UIButton *)sender
{
    ILShareViewController *shareView = [[ILShareViewController alloc] initWithNibName:@"ILShareViewController" bundle:nil];
//    [self addChildViewController:shareView];
    [self showViewController:shareView sender:self];
}

@end
