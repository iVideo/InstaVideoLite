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

@protocol ILClipDockViewDelegate <NSObject>

@required

- (void)dockView:(ILClipDockView *)dockView didSelectAtIndex:(NSUInteger)idx;
- (void)dockView:(ILClipDockView *)dockView didDeleteAtIndex:(NSUInteger)idx;
- (void)dockView:(ILClipDockView *)dockView didMoveToIndex:(NSUInteger)idx;

@end

@interface ILClipDockView : UIView
<UITableViewDelegate>

- (instancetype)initWithFrame:(CGRect)frame;

- (void)addLastAsset;

@end
