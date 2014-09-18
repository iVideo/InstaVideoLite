//
//  ILAlbumManager.m
//  InstaVideoLite
//
//  Created by insta on 9/16/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILAlbumManager.h"

@interface ILAlbumManager ()

@property (strong, nonatomic) ALAssetsLibrary *library;

@property (strong, nonatomic) NSMutableDictionary *albums; //@{assets:grouppid} ALAsset : String
@property (strong, nonatomic) NSMutableDictionary *groups; //@{group:grouppid} ALAssetsGroup : String

@end

@implementation ILAlbumManager

+ (instancetype)sharedInstance
{
    static ILAlbumManager *albumManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        albumManager = [[ILAlbumManager alloc] init];
    });
    return albumManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _library = [[ALAssetsLibrary alloc]init];
        _albums = [[NSMutableDictionary alloc] initWithCapacity:1];
        _groups = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return self;
}

- (void)updateAssets
{
    [self clearDatasets];
    [self readVideoAssets];
}

- (void)clearDatasets
{
    [_groups removeAllObjects];
    [_albums removeAllObjects];
}

- (void)readVideoAssets
{
    [_library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil) {
            
            NSArray *array = [self getVideoAssetsWithGroup:group];
            if ([array count] > 0) {
                NSString *key = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
                [_groups setValue:group forKey:key];
                [_albums setObject:array forKey:key];
            }
        }
        
    } failureBlock:^(NSError *error) {
        NSLog(@"%@",error.description);
    }];
}

- (NSDictionary *)allVideoGroups
{
    return [[NSDictionary alloc] initWithDictionary:_groups];
}

- (NSDictionary *)allVideoAssets
{
    //TODO:
    return nil;
}

- (ALAssetsGroup *)getVideoGroupWithPID:(NSString *)pid
{
    return [_groups objectForKey:pid];
}

- (NSArray *)getVideoAssetsWithPID:(NSString *)pid
{
    ALAssetsGroup *group = [_groups objectForKey:pid];
    return [self getVideoAssetsWithGroup:group];
}

- (NSArray *)getVideoAssetsWithGroup:(ALAssetsGroup *)group
{
    [group setAssetsFilter:[ALAssetsFilter allVideos]];
    NSMutableArray *assets = [[NSMutableArray alloc] initWithCapacity:1];
    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result != nil) {
            [assets addObject:result];
        }
    }];
    return [NSArray arrayWithArray:assets];
}

@end
