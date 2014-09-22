//
//  ILTrimViewController.m
//  InstaVideoLite
//
//  Created by insta on 9/17/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILTrimViewController.h"

#define FSPAN_H 116.f
#define THUMB_H 88.f
#define THUMB_W 20.f

@interface ILTrimViewController ()
{
    CGFloat midHeight;
    CGFloat spanTop;
}

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) ILPlayerView *playerView;

@property (strong, nonatomic) UIButton *btnPlay;
@property (strong, nonatomic) UIImageView *imgPreview;
@property (strong, nonatomic) UIView *toggleView;

@property (strong, nonatomic) UIView *midView;
@property (strong, nonatomic) UIScrollView *frameSpan;
@property (strong, nonatomic) UIImageView *timeLine;

@property (strong, nonatomic) UIView *leftView;
@property (strong, nonatomic) UIView *rightView;

@property (strong, nonatomic) UIButton *leftBtn;
@property (strong, nonatomic) UIButton *rightBtn;
@property (strong, nonatomic) UIButton *trackBtn;

@property (strong, nonatomic) ILNavBarView *navBarView;

@property (strong, nonatomic) AVPlayerItem *playerItem;

@property (nonatomic) CGFloat leftPosition;
@property (nonatomic) CGFloat rightPosition;

@end

@implementation ILTrimViewController

- (void)dealloc
{
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [PLAYER pause];
    _playerItem = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    NSInteger idx = [IL_DATA popIndex];
    if (idx < 0) {
        return;
    }
    _playerItem = [[PLAYER.queuePlayer items] objectAtIndex:idx];
}

#pragma mark - midView

- (void)createMidView
{
    midHeight = IL_SCREEN_H - IL_PLAYER_H - IL_NAVBAR_H;
    _midView = [[UIView alloc] initWithFrame:CGRectMake(.0f, IL_PLAYER_H,IL_SCREEN_W,midHeight)];
    _midView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bk_bar"]];
    [self.view addSubview:_midView];
    
    [self createFrameSpan];
    [self createCtrlViews];
    [self addPanGestures];
    [self createScrollView];
}

- (void)createFrameSpan
{
    _frameSpan = [[UIScrollView alloc] initWithFrame:CGRectMake(.0f, midHeight -  FSPAN_H, IL_SCREEN_W , FSPAN_H)]; //bottom
    _frameSpan.showsHorizontalScrollIndicator = NO;
    _frameSpan.showsVerticalScrollIndicator = NO;
    [_midView addSubview:_frameSpan];
    
    _timeLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"time"]]; //bottom
    [_timeLine setFrame:CGRectMake(.0f, FSPAN_H - 26.f, IL_SCREEN_W, 26.f)];
    [_frameSpan addSubview:_timeLine];

}

- (void)createCtrlViews
{
    spanTop = midHeight - FSPAN_H;
    UIColor *bgColor = [UIColor colorWithWhite:.0f alpha:0.8];

    _leftView = [[UIView alloc] initWithFrame:CGRectMake(.0f, spanTop, 10.f, THUMB_H)];
    _leftView.backgroundColor = bgColor;
    [_midView addSubview:_leftView];
    
    _rightView = [[UIView alloc] initWithFrame:CGRectMake(IL_SCREEN_W - 10.f, spanTop, 10.f, THUMB_H)];
    _rightView.backgroundColor = bgColor;
    [_midView addSubview:_rightView];
    
    _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_leftBtn setFrame:CGRectMake(_leftView.frame.size.width - 6.f, 30.f, 4.f, 28.f)];
    [_leftBtn setImage:[UIImage imageNamed:@"compose_small_btn"] forState:UIControlStateNormal];
    [_leftView addSubview:_leftBtn];
    
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightBtn setFrame:CGRectMake(3.f, 30.f, 4.f, 28.f)];
    [_rightBtn setImage:[UIImage imageNamed:@"compose_small_btn"] forState:UIControlStateNormal];
    [_rightView addSubview:_rightBtn];
    
    _trackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_trackBtn setFrame:CGRectMake(20.f, spanTop - 8.f , 4.f, 104.f)];
    [_trackBtn setImage:[UIImage imageNamed:@"compose_big_btn"] forState:UIControlStateNormal];
    [_trackBtn setHidden:YES];
    [_midView addSubview:_trackBtn];
}

- (void)addPanGestures
{
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panLeftView:)];
    [_leftView addGestureRecognizer:leftPan];
    
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRightView:)];
    [_rightView addGestureRecognizer:rightPan];

}

- (void)createScrollView
{
    Float64 durationSeconds = CMTimeGetSeconds(_playerItem.duration);
    int picnum = ceilf(durationSeconds) + 1; //last second added
    CGFloat contentsize = THUMB_W * picnum; //preset "1 pic per second" or "20 pix per secsecond"
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:[_playerItem asset]];
    generator.maximumSize = CGSizeMake(THUMB_H, THUMB_H);
    generator.appliesPreferredTrackTransform = YES;//image rotate
    generator.requestedTimeToleranceBefore = kCMTimeZero;//time ajust
    generator.requestedTimeToleranceAfter = kCMTimeZero;//time ajust
    
    NSMutableArray *timeFrames = [[NSMutableArray alloc] initWithCapacity:1];
    for (int i = 1; i <= picnum; i++) {//kCMTimeZero igonore ,first image ignore
        CMTime timeFrame = CMTimeMakeWithSeconds(i, _playerItem.duration.timescale);
        [timeFrames addObject:[NSValue valueWithCMTime:timeFrame]];
    }
    NSArray *times = [NSArray arrayWithArray:timeFrames];
    __block int i = 0;
    [generator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        UIImage *thumb = [[UIImage alloc] initWithCGImage:image scale:1.0f orientation:UIImageOrientationUp];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:thumb];
        imageView.frame = CGRectMake(i * THUMB_W + THUMB_W, 2.f, THUMB_W, THUMB_H - 4.f); //1 pic left space
        i++;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_frameSpan addSubview:imageView];
        });
        
    }];
    
    [_frameSpan setContentSize:CGSizeMake(contentsize + THUMB_H, THUMB_H)]; //1 pic left space
    [_frameSpan setNeedsDisplay];
}


#pragma mark - panGesture
- (void)panLeftView:(UIPanGestureRecognizer *)recognizer
{
    UIView *view = recognizer.view;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            [PLAYER pause];
            
            CGFloat centerY = _trackBtn.center.y;
            _trackBtn.center = CGPointMake(view.frame.size.width, centerY);
            [UIView animateWithDuration:IL_DURA animations:^{
                _trackBtn.hidden = NO;
                [_midView bringSubviewToFront:_trackBtn];
            }];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint offset = [recognizer translationInView:view];
            view.center = CGPointMake(view.center.x + offset.x, view.center.y);
            [recognizer setTranslation:CGPointZero inView:view];
            
            _leftPosition = [recognizer locationOfTouch:0 inView:_frameSpan].x;
            [self seekTimePlayer:_leftPosition];
            
            CGFloat leftWidth = view.frame.size.width + offset.x;
            view.frame = CGRectMake(.0f, spanTop , leftWidth, THUMB_H);
            _leftBtn.frame = CGRectMake(leftWidth - 6.f, 30.f, 4.f, 28.f);
            _trackBtn.frame = CGRectMake(leftWidth, spanTop - 8.f, 4.f, 104.f);
            
            if (_rightView.center.x - view.frame.size.width < 60.f) {
                view.frame = CGRectMake(.0f, spanTop, IL_SCREEN_W - _rightView.center.x -70.f, THUMB_H);
                return;
            }
            if (view.frame.size.width < 9.f) {
                view.frame = CGRectMake(.0f, spanTop, 10.f, THUMB_H);
                return;
            }
            if (view.frame.size.width > IL_SCREEN_W - 80.f) {
                view.frame = CGRectMake(.0f, spanTop, IL_SCREEN_W -70.f, THUMB_H);
                return;
            }
        
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [UIView animateWithDuration:IL_DURA animations:^{
                _trackBtn.hidden = YES;
            }];
            
        }
            break;
            
        default:
            break;
    }
    
}

- (void)panRightView:(UIPanGestureRecognizer *)recognizer
{
    UIView *view = recognizer.view;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            [PLAYER pause];
            CGFloat centerY = _trackBtn.center.y;
            _trackBtn.center = CGPointMake(view.frame.origin.x, centerY);
            [UIView animateWithDuration:IL_DURA animations:^{
                _trackBtn.hidden = NO;
                [_midView bringSubviewToFront:_trackBtn];
            }];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint offset = [recognizer translationInView:view];
            view.center = CGPointMake(view.center.x + offset.x, view.center.y);
            [recognizer setTranslation:CGPointZero inView:view];
            
            _rightPosition = [recognizer locationOfTouch:0 inView:_frameSpan].x;
            [self seekTimePlayer:_rightPosition];
            
            CGFloat rightWidth = view.frame.size.width - offset.x;
            view.frame = CGRectMake(IL_SCREEN_W - rightWidth, spanTop, rightWidth, THUMB_H);
            
            CGFloat centerY = _trackBtn.center.y;
            _trackBtn.center = CGPointMake(view.frame.origin.x, centerY);
            
            if (view.center.x - _leftView.frame.size.width < 60.f) {
                view.center = CGPointMake(view.center.x - 10.f, view.center.y);
                return;
            }
            
            if (view.center.x < 70.f) {
                view.center = CGPointMake(80.f, view.center.y);
                return;
            }
            
            if (view.center.x > IL_SCREEN_W - 11.f) {
                view.center = CGPointMake(IL_SCREEN_W - 10.f, view.center.y);
                return;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [UIView animateWithDuration:IL_DURA animations:^{
                _trackBtn.hidden = YES;
            }];
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
}
- (void)createPlayerView
{
    _playerView = [[ILPlayerView alloc] initWithFrame:CGRectMake(0, 0,IL_PLAYER_W, IL_PLAYER_H)];
    [_playerView setBackgroundColor:[UIColor clearColor]];
    _playerView.btnPlay.hidden = YES;
    [self.view addSubview:_playerView];
    
    [self.playerView.playerLayer setPlayer:PLAYER.queuePlayer];
    [PLAYER play];
    [self.view bringSubviewToFront:_playerView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playerTaped:)];
    [_playerView addGestureRecognizer:tapGesture];
}

- (void)playerTaped:(UITapGestureRecognizer *)recognizer
{
    _playerView.btnPlay.hidden = !_playerView.btnPlay.hidden;
    [PLAYER playOrPause:_playerView.btnPlay.hidden];
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
    [SVProgressHUD show];
    
    NSString *movieName = [[NSString alloc] initWithFormat:@"instavideo_%u.mov",arc4random()];
    NSString *moviePath = [NSTemporaryDirectory() stringByAppendingPathComponent:movieName];
    unlink([moviePath UTF8String]);
    
    AVAssetExportSession *export = [[AVAssetExportSession alloc] initWithAsset:[_playerItem asset]
                                                                    presetName:AVAssetExportPresetHighestQuality];
    export.outputURL = [[NSURL alloc] initFileURLWithPath:moviePath];
    export.outputFileType = AVFileTypeQuickTimeMovie;
    
    CMTime timestart = [self covertCMTime:_leftPosition];
    CMTime duration = [self covertCMTime:(_rightPosition - _leftPosition)];
    export.timeRange = CMTimeRangeMake(timestart,duration);

    [export exportAsynchronouslyWithCompletionHandler:^{
        switch (export.status) {
            case AVAssetExportSessionStatusCompleted:
            {
                [SVProgressHUD dismiss];
                
                AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:export.outputURL];
                [IL_DATA pushItem:item];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Failed:%@",export.error);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Canceled:%@",export.error);
                break;
            default:
                break;
        }
    }];
}

- (void)seekTimePlayer:(CGFloat)position
{
    [PLAYER.queuePlayer seekToTime:[self covertCMTime:position]];
}

- (CMTime)covertCMTime:(CGFloat)position
{
    CMTime newtime = CMTimeMakeWithSeconds(position / THUMB_W, _playerItem.duration.timescale);//"20 pix per secsecond"
    NSLog(@"seekTime %lld ", newtime.value / _playerItem.duration.timescale);
    return newtime;
}


@end
