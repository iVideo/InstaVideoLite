//
//  ILCommon.m
//  InstaVideoLite
//
//  Created by insta on 9/11/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILCommon.h"

@implementation ILCommon

+ (instancetype)sharedInstance
{
    static ILCommon *common;
    static dispatch_once_t *onceToke;
    dispatch_once(onceToke, ^{
        common = [[ILCommon alloc] init];
    });
    return common;
}

-(BOOL) isRetina{
    return ([UIScreen instancesRespondToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0));
}

@end
