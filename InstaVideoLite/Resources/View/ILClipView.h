//
//  ILClipView.h
//  InstaVideoLite
//
//  Created by insta on 9/17/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ILClipView : UIView

@property (strong, nonatomic) UIImageView *clipBg;
@property (strong, nonatomic) UIImageView *clipImage;

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image;

@end
