//
//  ILAlbumManager.h
//  InstaVideoLite
//
//  Created by insta on 9/16/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ILAlbumManager : NSObject

+ (instancetype)sharedInstance;

- (void)updateAssets;

- (NSDictionary *)allVideoGroups;
- (NSDictionary *)allVideoAssets;

- (ALAssetsGroup *)getVideoGroupWithPID:(NSString *)pid;

- (NSArray *)getVideoAssetsWithPID:(NSString *)pid;
- (NSArray *)getVideoAssetsWithGroup:(ALAssetsGroup *)group;

@end
