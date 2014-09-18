//
//  ILVideoClip.m
//  InstaVideoLite
//
//  Created by insta on 9/15/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILVideoClip.h"

@implementation ILVideoClip

- (AVAsset *)videoAsset
{
    return [AVAsset assetWithURL:_videoURL];
}

- (CGSize) timeRange
{
    return CGSizeMake(_startAt, _duration);
}

@end
