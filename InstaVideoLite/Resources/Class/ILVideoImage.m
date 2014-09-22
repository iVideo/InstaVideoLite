//
//  ILVideoImage.m
//  InstaVideoLite
//
//  Created by insta on 9/22/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILVideoImage.h"
#import <UIKit/UIKit.h>

@interface ILVideoImage ()

@property (strong, nonatomic) AVAssetImageGenerator *generator;

@end

@implementation ILVideoImage

+ (instancetype) sharedInstance
{
    static ILVideoImage *videoImage;
    static dispatch_once_t onceToke;
    dispatch_once(&onceToke, ^{
        videoImage = [[ILVideoImage alloc] init];
    });
    return videoImage;
}

- (NSArray *)imagesPerSecondWithVideo:(AVAsset *)asset imageSize:(CGSize)size
{
    Float64 durationSeconds = CMTimeGetSeconds(asset.duration);
    int picnum = ceilf(durationSeconds) + 1; //last second added
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.maximumSize = CGSizeMake(size.width, size.height);
    generator.appliesPreferredTrackTransform = YES;//image rotate
    generator.requestedTimeToleranceBefore = kCMTimeZero;//time ajust
    generator.requestedTimeToleranceAfter = kCMTimeZero;//time ajust
    
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:picnum];
    for (int i = 1; i <= picnum; i++) {//kCMTimeZero igonore ,first image ignore
        CMTime frame = CMTimeMakeWithSeconds(i, asset.duration.timescale);
        [frames addObject:[NSValue valueWithCMTime:frame]];
    }
    NSArray *times = [NSArray arrayWithArray:frames];
    NSMutableArray *timeImages = [NSMutableArray arrayWithCapacity:picnum];
    [generator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        //UIImage *timeImage = [[UIImage alloc] initWithCGImage:image scale:2.0f orientation:UIImageOrientationUp]; //retina support
        UIImage *timeImage = [[UIImage alloc] initWithCGImage:image];
        [timeImages addObject:timeImage];
    }];
    
    return timeImages;
}

- (NSArray *)imageGeneratorPerSecond:(AVAsset *)asset imageSize:(CGSize)size
{
    
}

- (void)cancelImageGenerator
{
    
}

@end
