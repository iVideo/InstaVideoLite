//
//  ILPlayerManager.m
//  InstaVideoLite
//
//  Created by insta on 9/11/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILPlayerManager.h"

@interface ILPlayerManager ()

//@property (strong, nonatomic) ILPlayerView *playerView;
@property (strong, nonatomic) NSMutableArray *playItems;

@end

@implementation ILPlayerManager

- (void)dealloc
{
    _playItems = nil;
    _queuePlayer = nil;
//    _playerView = nil;
}

+ (instancetype) sharedInstance
{
    static ILPlayerManager *playerManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerManager = [[ILPlayerManager alloc] init];
    });
    return playerManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self createSubView];
    }
    return self;
}

- (instancetype)initWithPlayerItems:(NSArray *)items
{
    if (self = [super init]) {
        _queuePlayer = [AVQueuePlayer queuePlayerWithItems:items];
    }
    return self;
}

- (void)createSubView
{
    _playItems = [[NSMutableArray alloc] initWithCapacity:1];
    _queuePlayer = [[AVQueuePlayer alloc] init];
}

#pragma mark - public

- (void)addPlayerItems:(NSArray *)items
{
    for (AVPlayerItem *item in items) {
        [self addLastItem:item];
    }
}

- (NSArray *)allPlayItems
{
    return [_queuePlayer items];
}

- (void)clearPlayItems
{
    [_queuePlayer removeAllItems];
}

- (void)addLastItemWithURL:(NSURL *)url
{
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    [self addLastItem:item];
}

- (void)addLastItem:(AVPlayerItem *)item
{
    AVPlayerItem *last = [_playItems lastObject];
    if ([_queuePlayer canInsertItem:item afterItem:last]) {
        [_queuePlayer insertItem:item afterItem:last];
        [_playItems addObject:item];
    }
}

- (void)deleteItem:(AVPlayerItem *)item
{
    [_queuePlayer removeItem:item];
}


- (void)playOrPause:(BOOL)play
{
    if (play) {
        [self play];
    }else{
        [self pause];
    }
}

- (void)play
{
    [_queuePlayer play];
}

- (void)pause
{
    [_queuePlayer pause];
}

@end

#pragma mark --- ILPlayerView Class----

@implementation ILPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createLayer:frame];
        [self createBtnPlay:frame];
    }
    return self;
}

- (void)createLayer:(CGRect)frame
{
    _playerLayer = [[AVPlayerLayer alloc] init];
    [_playerLayer setFrame:frame];
    [_playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.layer addSublayer:_playerLayer];
}

- (void)createBtnPlay:(CGRect)frame
{
    CGSize btnSize = CGSizeMake(70.f, 70.f);
    CGRect btnFrame = CGRectMake(frame.size.width/2 - btnSize.width/2, frame.size.height/2 - btnSize.height/2, btnSize.width, btnSize.height);
    _btnPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnPlay setFrame:btnFrame];
    [_btnPlay setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    _btnPlay.userInteractionEnabled = NO;
    [self addSubview:_btnPlay];
    [self bringSubviewToFront:_btnPlay];
}


@end
