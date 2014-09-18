//
//  ILVideoClip.h
//  InstaVideoLite
//
//  Created by insta on 9/15/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ILVideoClip : NSObject

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic) float duration;
@property (nonatomic) float startAt;

- (CGSize) timeRange;
- (AVAsset *)videoAsset;

@end
