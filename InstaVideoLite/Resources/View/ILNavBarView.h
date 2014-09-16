//
//  ILNavBarView.h
//  InstaVideoLite
//
//  Created by insta on 9/12/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILPreDefine.h"

@interface ILNavBarView : UIView

@property (strong, nonatomic) UIButton *btnBack;
@property (strong, nonatomic) UIButton *btnNext;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)startWaiting;
- (void)stopWaited;

@end
