//
//  ILPlayerView.h
//  InstaVideoLite
//
//  Created by insta on 9/16/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ILPlayerView : UIView

@property (strong, nonatomic) AVPlayerLayer *playerLayer;

- (instancetype)initWithFrame:(CGRect)frame;

@end
