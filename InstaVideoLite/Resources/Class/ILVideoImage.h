//
//  ILVideoImage.h
//  InstaVideoLite
//
//  Created by insta on 9/22/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ILVideoImage : NSObject

+ (instancetype) sharedInstance;

- (NSArray *)imageGeneratorPerSecond:(AVAsset *)asset imageSize:(CGSize)size;
- (void)cancelImageGenerator;

@end
