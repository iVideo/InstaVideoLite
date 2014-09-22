//
//  ILPreDefine.h
//  InstaVideoLite
//
//  Created by insta on 9/11/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#ifndef InstaVideoLite_ILPreDefine_h
#define InstaVideoLite_ILPreDefine_h

#import "ILDataStore.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ILPlayerManager.h"
#import "ILNavBarView.h"
#import "ILDataManager.h"
#import "ILVideoManager.h"
#import "SVProgressHUD.h"
#import "ILCommon.h"

#define iOS7_OR_LATER [[[UIDevice currentDevice] systemVersion] floatValue] >= 7;
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define isRetina ([UIScreen instancesRespondToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))


#define IL_SCREEN_H      [[UIScreen mainScreen] bounds].size.height
#define IL_SCREEN_W      [[UIScreen mainScreen] bounds].size.width

#define IL_COMMON_H      44.0f
#define IL_NAVBAR_H      IL_COMMON_H

#define IL_PLAYER_H      [[UIScreen mainScreen] bounds].size.width
#define IL_PLAYER_W      [[UIScreen mainScreen] bounds].size.width

#define IL_CAMERA_H      [[UIScreen mainScreen] bounds].size.width
#define IL_CAMERA_W      [[UIScreen mainScreen] bounds].size.width

#define IL_USER_DEFAULT [NSUserDefaults standardUserDefaults]

#define IL_ALBUM    [ILAlbumManager sharedInstance]
#define PLAYER      [ILPlayerManager sharedInstance]
#define IL_DATA     [ILDataManager sharedInstance]
#define IL_VIDEO    [ILVideoManager sharedInstance]

#define IL_DURA     .3f


#endif
