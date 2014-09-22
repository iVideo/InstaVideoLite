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

@interface ILPlayerManager : NSObject

@property (strong, nonatomic) AVQueuePlayer *queuePlayer;

+ (instancetype) sharedInstance;

//- (instancetype)initWithPlayerItems:(NSArray *)items;

- (void)addPlayerItems:(NSArray *)items;
- (NSArray *)allPlayItems;
- (void)clearPlayItems;

- (void)addLastItemWithURL:(NSURL *)url;
- (void)addLastItem:(AVPlayerItem *)item;
- (void)deleteItem:(AVPlayerItem *)item;

- (void)playOrPause:(BOOL)play;
- (void)play;
- (void)pause;

@end

@interface ILPlayerView : UIView

@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) UIButton *btnPlay;

- (instancetype)initWithFrame:(CGRect)frame;


@end