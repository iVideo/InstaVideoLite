//
//  ILDataStore.m
//  InstaVideoLite
//
//  Created by insta on 9/13/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILDataStore.h"

@interface ILDataStore ()

@property (strong, nonatomic) NSMutableArray *assets;
@property (strong, nonatomic) NSMutableArray *clips;

@end

@implementation ILDataStore

+ (instancetype)sharedInstance
{
    static ILDataStore *dataStore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataStore = [[ILDataStore alloc] init];
    });
    return dataStore;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        _assets = [[NSMutableArray alloc]initWithCapacity:1];
        _clips = [[NSMutableArray alloc]initWithCapacity:1];
    }
    return self;
}

- (void)setEditClip:(AVAsset *)clip
{
    [_clips removeAllObjects];
    [_clips addObject:clip];
}

- (AVAsset *)getEditClip
{
    return [_clips lastObject];
}


- (NSArray *)getMovieClips
{
    return _assets;
}

- (void)addMovieClip:(AVAsset *)clip
{
    [_assets addObject:clip];
}

- (void)addMovieClip:(AVAsset *)clip atIndex:(NSUInteger)idx;
{
    [_assets insertObject:clip atIndex:idx];
}

- (void)deleteMovieClipAtIndex:(NSUInteger)idx
{
    [_assets removeObjectAtIndex:idx];
}

- (void)deleteAllMovieClips
{
    [_assets removeAllObjects];
}

- (void)moveMovieClipAtIndex:(NSUInteger)idxSource toIndex:(NSUInteger)idxDestination
{
    AVAsset *assetSource = [_assets objectAtIndex:idxSource];
    [_assets insertObject:assetSource atIndex:idxDestination];
}

@end
