//
//  ILVideoComposition.h
//  InstaVideoLite
//
//  Created by insta on 9/15/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILVideoClip.h"

@interface ILVideoComposition : NSObject

@property (nonatomic, readonly) float duration;
@property (nonatomic, setter=setRecording:) BOOL  isRecording;
@property (nonatomic) BOOL  isLastTakeReadyToRemove;

- (BOOL) canAddVideoClip;

- (void) addVideoClip: (ILVideoClip *) take;

- (NSArray *)getVideoClips;
- (void)clearVideoClips;

- (void) removeLastVideoClip;
- (CGSize) lastVideoClipRange;

- (float) recordingDuration;
- (float) recordedDuration;

- (float) maxDurationAllowed;

@end
