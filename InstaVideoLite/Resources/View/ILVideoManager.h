//
//  ILVideoManager.h
//  InstaVideoLite
//
//  Created by insta on 9/22/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol ILVideoManagerDelegate <NSObject>

@optional
- (void)imageGerneratorFinished:(NSArray *)images;
- (void)imageGerneratorCancel;

@end


@interface ILVideoManager : NSObject

@property(assign, nonatomic) id<ILVideoManagerDelegate> delegate;

+ (instancetype) sharedInstance;

- (void)startImageGenerator:(AVAsset *)asset thumb:(CGSize)size retina:(NSInteger)type;

- (void)stopImageGenerator;

@end
