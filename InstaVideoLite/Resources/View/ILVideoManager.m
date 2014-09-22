//
//  ILVideoManager.m
//  InstaVideoLite
//
//  Created by insta on 9/22/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILVideoManager.h"
#import <UIKit/UIKit.h>

@interface ILVideoManager ()

@property (strong, nonatomic) AVAssetImageGenerator *generator;

@property (strong, nonatomic) NSMutableArray *singleImages;
@property (strong, nonatomic) NSMutableArray *doubleImages;
@property (strong, nonatomic) NSMutableArray *tripleImages;

@end

@implementation ILVideoManager

+ (instancetype) sharedInstance
{
    static ILVideoManager *videoManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        videoManager = [[ILVideoManager alloc] init];
    });
    return videoManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _generator = [[AVAssetImageGenerator alloc] init];
        _generator.appliesPreferredTrackTransform = YES;//image rotate
        _generator.requestedTimeToleranceBefore = kCMTimeZero;//time ajust
        _generator.requestedTimeToleranceAfter = kCMTimeZero;//time ajust
        
        _singleImages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)startImageGenerator:(AVAsset *)asset thumb:(CGSize)size retina:(NSInteger)type;
{
    Float64 durationSeconds = CMTimeGetSeconds(asset.duration);
    int picnum = ceilf(durationSeconds) + 1; //last second added
    
    _generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    _generator.maximumSize = CGSizeMake(size.width, size.height);
    
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:picnum];
    for (int i = 1; i <= picnum; i++) {//kCMTimeZero igonore ,first image ignore
        CMTime frame = CMTimeMakeWithSeconds(i, asset.duration.timescale);
        [frames addObject:[NSValue valueWithCMTime:frame]];
    }
    NSArray *times = [NSArray arrayWithArray:frames];
    _singleImages = [NSMutableArray arrayWithCapacity:picnum];
    
    __block int i = picnum;
    [_generator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        i-- ;
        if (i <= 0 ) {
            NSLog(@"Finished %d images" ,i);
            if ([_delegate respondsToSelector:@selector(imageGerneratorFinished:)]) {
                [_delegate imageGerneratorFinished:_singleImages]; //not support double and trible yet
            }
        }
        [self getImage:image retina:type];
    }];
}

- (void)stopImageGenerator
{
    if (_generator == nil) return;
    [_generator cancelAllCGImageGeneration];
    if ([_delegate respondsToSelector:@selector(imageGerneratorCancel)]) {
        [_delegate imageGerneratorCancel];
    }
}

#pragma mark - private
- (void)getImage:(CGImageRef)image retina:(NSInteger)type
{
    switch (type) {
        case 0:
        {
            UIImage *singleImage = [[UIImage alloc] initWithCGImage:image];
            [_singleImages addObject:singleImage];
        }
            break;
        case 1:
        {
            UIImage *doubleImage = [[UIImage alloc] initWithCGImage:image scale:2.0f orientation:UIImageOrientationUp]; //retina support
            [_doubleImages addObject:doubleImage];
        }
            
            break;
        case 2:
        {
            UIImage *tripleImage = [[UIImage alloc] initWithCGImage:image scale:3.0f orientation:UIImageOrientationUp]; //iphone plus support
            [_tripleImages addObject:tripleImage];
        }
            break;
            
        default:
            break;
    }
}

@end
