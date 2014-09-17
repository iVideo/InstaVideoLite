//
//  ILPlayerView.m
//  InstaVideoLite
//
//  Created by insta on 9/16/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILPlayerView.h"

@implementation ILPlayerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)dealloc
{
    _playerLayer = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        //TODO: scroll by videosize
        [_playerLayer setFrame:frame];
        [self.layer addSublayer:_playerLayer];
    }
    return self;
}


@end
