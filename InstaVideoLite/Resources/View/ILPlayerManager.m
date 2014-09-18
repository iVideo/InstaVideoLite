//
//  ILPlayerManager.m
//  InstaVideoLite
//
//  Created by insta on 9/11/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILPlayerManager.h"

@interface ILPlayerManager ()

@property (strong, nonatomic) ILPlayerView *playerView;
@property (strong, nonatomic) NSMutableArray *playItems;

@end

@implementation ILPlayerManager

- (void)dealloc
{
    _queuePlayer = nil;
    _playerView = nil;
    _playItems = nil;
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
        _playItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setPlayerItemWithURLs:(NSArray *)urls
{
    for (NSURL *url in urls) {
        [_playItems addObject:[AVPlayerItem playerItemWithURL:url]];
    }
    _queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithArray:_playItems]];
}

//- (void)setPlayerItemWithPaths:(NSArray *)paths
//{
//    for (NSString *path in paths) {
//        [_playItems addObject:[AVPlayerItem playerItemWithURL:[NSURL URLWithString:path]]];
//    }
//    _queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithArray:_playItems]];
//}
//
//- (void)setPlayerItemWithAssets:(NSArray *)assets
//{
//    for (AVAsset *asset in assets) {
//        [_playItems addObject:[AVPlayerItem playerItemWithAsset:asset]];
//    }
//    _queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithArray:_playItems]];
//}

- (void)playWithIndex:(NSInteger)index
{
    
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
