//
//  ILRecordProgressView.m
//  InstaVideoLite
//
//  Created by insta on 9/15/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILRecordProgressView.h"

@implementation ILRecordProgressView

- (void)dealloc
{
    [_composition removeObserver: self forKeyPath: @"isLastTakeReadyToRemove"];
    [_composition removeObserver: self forKeyPath: @"duration"];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat fixedColors []  = { 38/255.0,200/255.0,210/255.0, 1.0, 38/255.0,191/255.0,162/255.0, 1.0 };
    CGFloat recColors []    = { 244/255.0,121/255.0,99/255.0, 1.0, 241/255.0,58/255.0,58/255.0, 1.0 };
    
    
    float maxDuration = [_composition maxDurationAllowed];
    float w         = self.frame.size.width;
    float h         = self.frame.size.height;
    
    // Background
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.25);
    CGContextFillRect(context, rect);
    
    // Recorded clips
    float duration              = [_composition recordedDuration];
    float lastCompDuration      = [_composition recordingDuration];
    if (_composition.isLastTakeReadyToRemove){
        CGSize range    = [_composition lastVideoClipRange];
        lastCompDuration   = range.height;
        duration          -= lastCompDuration;
    }
    float length = duration / maxDuration * w;
    CGRect fixed    = CGRectMake(0, 0, length, h);
    [self drawRect: fixed withColors: fixedColors context: context];
    
    // Recording clip or last clip to be removed
    if (_composition.isRecording || _composition.isLastTakeReadyToRemove){
        float addedLength       = lastCompDuration / maxDuration * w;
        CGRect added            = CGRectMake(length, 0, addedLength, h);
        [self drawRect: added withColors: recColors context: context];
    }
}

- (void) drawRect: (CGRect) rect withColors: (CGFloat *) colors context: (CGContextRef) context
{
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    CGContextAddRect(context, rect);
}

- (void) setComposition:(ILVideoComposition *)composition
{
    _composition = composition;
    
    if (_composition){
        [_composition addObserver: self forKeyPath: @"isLastTakeReadyToRemove" options: NSKeyValueObservingOptionNew context: nil];
        [_composition addObserver: self forKeyPath:@"duration" options: NSKeyValueObservingOptionInitial context: nil];
        
    } else {
        [_composition removeObserver: self forKeyPath: @"isLastTakeReadyToRemove"];
        [_composition removeObserver: self forKeyPath: @"duration"];
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (_composition == object){
        if ( [keyPath isEqualToString: @"isLastTakeReadyToRemove"] || [keyPath isEqualToString: @"duration"]){
            [self setNeedsDisplay];
        }
    }
}
@end
