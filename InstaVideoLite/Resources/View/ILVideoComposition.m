//
//  ILVideoComposition.m
//  InstaVideoLite
//
//  Created by insta on 9/15/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILVideoComposition.h"

static float kMaxDuration = 20.0;

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

- (NSString *)description
{
    return [NSString stringWithFormat:@"composition contains %ld takes", [clips count]];
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

- (BOOL) canAddVideoClip
{
    return ([self duration] < kMaxDuration);
}

- (void) setRecording: (BOOL) recording
{
    _isRecording = recording;
    
    if (_isRecording){
        startedAt = [NSDate date];
        timer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target:self selector:@selector(notifyDurationChanges) userInfo:nil repeats:YES];
    } else {
        [self notifyDurationChanges];
        [timer invalidate]; timer = nil;
        startedAt = nil;
    }
}

- (float) recordingDuration
{
    if (!_isRecording) return  0.0;
    else {
        return [startedAt timeIntervalSinceNow] * -1;
    }
}

- (float) recordedDuration
{
    float dur = 0;
    for (ILVideoClip *take in clips){
        dur += take.duration;
    }
    NSLog(@"recordedDuration %f",dur);
    return dur;
}

- (void) notifyDurationChanges
{
    NSLog(@"notifyDurationChanges");
    [self willChangeValueForKey: @"duration"];
    [self didChangeValueForKey: @"duration"];
}

#pragma mark


- (void) concatenateVideosWithCompletionHandler:(void (^)(BOOL))handler
{
    if (self.duration == 0){
        NSLog(@"No video clips to stitch");
        handler(NO);
        return;
    }
    
    
    NSMutableArray *assets = [NSMutableArray array];
    for (ILVideoClip *take in clips){
        [assets addObject: [take videoAsset]];
    }
    AVMutableComposition *composition = [AVMutableComposition composition];
    CMTime current = kCMTimeZero;
    NSError *compositionError = nil;
    for(AVAsset *asset in assets) {
        BOOL result = [composition insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration])
                                           ofAsset:asset atTime:current error:&compositionError];
        if(!result) {
            handler(NO);
            return;
        } else {
            current = CMTimeAdd(current, [asset duration]);
        }
    }
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:composition];
    AVAssetExportSession *exportSession;
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    } else if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetMediumQuality];
    } else if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality]) {
        exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetLowQuality];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *outputURL = paths[0];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    outputURL = [outputURL stringByAppendingPathComponent: @"output.mp4"];
    unlink([outputURL UTF8String]);
    
    exportSession.outputURL = [NSURL fileURLWithPath:outputURL];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        BOOL success = ([exportSession status] == AVAssetExportSessionStatusCompleted);
        handler(success);
    }];
}

@end
