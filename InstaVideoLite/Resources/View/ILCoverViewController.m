//
//  ILCoverViewController.m
//  InstaVideoLite
//
//  Created by insta on 9/17/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILCoverViewController.h"

#define THUMB_H 78.f
#define THUMB_W 39.f

#define COVER_H 92.f
#define COVER_W 92.f

@interface ILCoverViewController ()
{
    CGFloat midHeight;
    
    AVAssetImageGenerator *generator;
    NSMutableArray *images;
    
    int picnum;
}

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIScrollView *playerView;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) UIButton *btnPlay;

@property (strong, nonatomic) UIView *midView;
@property (strong, nonatomic) UIView *coverView;
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) UIImageView *postImage;

@property (strong, nonatomic) ILNavBarView *navBarView;

@property (strong, nonatomic) NSURL *movieURL;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    images = [[NSMutableArray alloc] initWithCapacity:1];
    _movieURL = [IL_DATA popURL];
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
    _coverView = [[UIView alloc] initWithFrame:CGRectMake(THUMB_W/2, midHeight/2 - THUMB_H/2, IL_SCREEN_W - THUMB_W, THUMB_H)];
    [_midView addSubview:_coverView];
    
    _maskView = [[UIView alloc] initWithFrame:_coverView.frame];
    _maskView.backgroundColor = [UIColor colorWithWhite:.2f alpha:0.8f];
    [_midView insertSubview:_maskView aboveSubview:_coverView];
    
}

- (void)generateImages
{
    Float64 view_w = IL_SCREEN_W - THUMB_H;
    
    AVAsset *asset = [AVAsset assetWithURL:_movieURL];
    generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(view_w, THUMB_H - 2.f);
    
    Float64 duration = CMTimeGetSeconds([asset duration]);
    picnum = ceilf(view_w / (THUMB_W/2));
    
    CMTime actualTime;NSError *error;
    for (int i = 0; i <= picnum; i++) {
        CMTime time = CMTimeMakeWithSeconds(i * duration/picnum, 600);
        CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage *image = [UIImage imageWithCGImage:imgRef];CGImageRelease(imgRef);[images addObject:image];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(i * THUMB_W/2 + 3.f, 1.f, THUMB_W/2 - 1.f, THUMB_H - 2.f);
        [_coverView addSubview:imageView];
    }
}

- (void)createPostImage
{
    _postImage = [[UIImageView alloc] initWithImage:[images firstObject]];
    [_postImage setFrame:CGRectMake(.0f, midHeight/2 - COVER_H/2, COVER_W, COVER_H)];
    [_midView addSubview:_postImage];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPostImage:)];
    [_postImage addGestureRecognizer:panGesture];
    _postImage.userInteractionEnabled = YES;
    
    [_midView bringSubviewToFront:_postImage];
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
            [self updatePostImage:view.center.x];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (view.center.x < COVER_W/2) {
                view.center = CGPointMake(COVER_W/2, view.center.y);
                [self updatePostImage:view.center.x];
            }else if (view.center.x > IL_SCREEN_W - COVER_W/2)
            {
                view.center = CGPointMake(IL_SCREEN_W - COVER_W/2, view.center.y);
                [self updatePostImage:view.center.x];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)updatePostImage:(CGFloat)centerX
{
    Float64 pos = centerX / (THUMB_W/2);
    int num = ceilf(pos);
    if (num < 0) {
        num = 0;
    }else if (num >= picnum)
    {
        num = picnum - 1;
    }
    if (_postImage.image != [images objectAtIndex:num]) {
        _postImage.image = [images objectAtIndex:num];
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
    _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:_movieURL];
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
    [_btnPlay setSelected:YES];
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
    [self pushWithEditType:@"share"];
}

- (void)pushWithEditType:(NSString *)editType
{
    NSURL *url = _movieURL;
    if (url == nil) {
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [IL_DATA pushURL:url];
    [self performSegueWithIdentifier:editType sender:self];
    
}

@end
