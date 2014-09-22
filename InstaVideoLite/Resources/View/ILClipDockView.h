//
//  ILClipDockView.h
//  InstaVideoLite
//
//  Created by insta on 9/11/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILPreDefine.h"

@class ILClipDockView;

@interface ILClipDockView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

- (void)updateDockWithItems:(NSArray *)items;

- (void)removeSelectedItem;

- (AVPlayerItem *)getSelectedItem;
- (NSInteger)getSelectedIndex;

@end
