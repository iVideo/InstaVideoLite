//
//  ILDataStore.h
//  InstaVideoLite
//
//  Created by insta on 9/13/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ILDataStore : NSObject

+ (instancetype)sharedInstance;

- (void)setEditClip:(AVAsset *)clip;
- (AVAsset *)getEditClip;

- (NSArray *)getMovieClips;

- (void)addMovieClip:(AVAsset *)clip;
- (void)addMovieClip:(AVAsset *)clip atIndex:(NSUInteger)idx;

- (void)deleteMovieClipAtIndex:(NSUInteger)idx;
- (void)deleteAllMovieClips;

- (void)moveMovieClipAtIndex:(NSUInteger)idxSource toIndex:(NSUInteger)idxDestination;

@end
