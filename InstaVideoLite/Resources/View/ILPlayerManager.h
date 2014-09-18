//
//  ILPlayerManager.h
//  InstaVideoLite
//
//  Created by insta on 9/11/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ILPlayerView.h"

@interface ILPlayerManager : NSObject

@property (strong, nonatomic) AVQueuePlayer *queuePlayer;

+ (instancetype) sharedInstance;

- (void)setPlayerItemWithURLs:(NSArray *)urls;
//- (void)setPlayerItemWithPaths:(NSArray *)paths;
//- (void)setPlayerItemWithAssets:(NSArray *)assets;
- (void)playWithIndex:(NSInteger)index;

- (void)play;
- (void)pause;

@end