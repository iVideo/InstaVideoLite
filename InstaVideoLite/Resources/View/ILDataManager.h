//
//  ILDataManager.h
//  InstaVideoLite
//
//  Created by insta on 9/18/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ILDataManager : NSObject

+ (instancetype)sharedInstance;

- (void)addClipURL:(NSURL *)url;
- (NSArray *)getClipURLs;
- (void)clearClips;

- (void)pushURL:(NSURL *)url;
- (NSURL *)popURL;

@end
