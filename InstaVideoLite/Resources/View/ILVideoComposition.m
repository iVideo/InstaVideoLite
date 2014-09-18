//
//  ILVideoComposition.m
//  InstaVideoLite
//
//  Created by insta on 9/15/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILVideoComposition.h"

static float kMaxDuration = 15.0f;

@interface ILVideoComposition ()
{
    NSMutableArray *clips;
    
    // For checking recording duration
    NSDate          *startedAt;
    NSTimer         *timer;
}

@end

@implementation ILVideoComposition

- (instancetype)init
{
    self = [super init];
    if (self) {
        clips = [[NSMutableArray alloc] init];
    }
    return self;
}

- (float) maxDurationAllowed
{
    return  kMaxDuration;
}

- (NSArray *)getVideoClips
{
    return [NSArray arrayWithArray:clips];
}

- (void)clearVideoClips
{
    [clips removeAllObjects];
}

- (void)addVideoClip:(ILVideoClip *) take
{
    float duration = [self duration];
    take.startAt = duration;
    [clips addObject: take];
    self.isLastTakeReadyToRemove = NO;
    [self notifyDurationChanges];
}

- (void)removeLastVideoClip
{
    [clips removeLastObject];
    self.isLastTakeReadyToRemove = NO;
}

- (float) duration
{
    return [self recordedDuration] + [self recordingDuration];
}

- (CGSize)lastVideoClipRange
{
    ILVideoClip *take = [clips lastObject];
    return  take.timeRange;
}

#pragma mark

- (BOOL)canAddVideoClip
{
    return ([self duration] < kMaxDuration);
}

- (void)setRecording: (BOOL) recording
{
    _isRecording = recording;
    
    if (_isRecording){
        startedAt = [NSDate date];
        timer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target:self selector:@selector(notifyDurationChanges) userInfo:nil repeats:YES];
        [timer fire];
    } else {
        [self notifyDurationChanges];
        [timer invalidate];
        timer = nil;
        startedAt = nil;
    }
}

- (float)recordingDuration
{
    if (!_isRecording) return  0.0;
    else {
        return [startedAt timeIntervalSinceNow] * -1;
    }
}

- (float)recordedDuration
{
    float dur = 0;
    for (ILVideoClip *take in clips){
        dur += take.duration;
    }
    NSLog(@"recordedDuration %f",dur);
    return dur;
}

- (void)notifyDurationChanges
{
    NSLog(@"notifyDurationChanges");
    [self willChangeValueForKey: @"duration"];
    [self didChangeValueForKey: @"duration"];
}

@end
