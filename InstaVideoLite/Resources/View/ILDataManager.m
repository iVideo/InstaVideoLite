//
//  ILDataManager.m
//  InstaVideoLite
//
//  Created by insta on 9/18/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILDataManager.h"

@interface ILDataManager ()

@property (strong, nonatomic) NSMutableArray *clipURLs;
@property (strong, nonatomic) NSMutableArray *itemURLs;

@end

@implementation ILDataManager

+ (instancetype)sharedInstance
{
    static ILDataManager *dataManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[ILDataManager alloc] init];
    });
    return dataManager;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        _clipURLs = [[NSMutableArray alloc]initWithCapacity:1];
        _itemURLs = [[NSMutableArray alloc]initWithCapacity:1];
    }
    return self;
}


- (void)addClipURL:(NSURL *)url
{
    [_clipURLs addObject:url];
}

- (NSArray *)getClipURLs
{
    return [NSArray arrayWithArray:_clipURLs];
}

- (void)clearClips
{
    [_clipURLs removeAllObjects];
}

#pragma mark - editable item
- (void)pushURL:(NSURL *)url
{
    [_itemURLs removeAllObjects];
    [_itemURLs addObject:url];
}

- (NSURL *)popURL
{
    return [_itemURLs lastObject];
}

@end
