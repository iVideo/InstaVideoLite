//
//  ILFrameViewCell.h
//  InstaVideoLite
//
//  Created by insta on 9/16/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ILFrameViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *selectedBg;
@property (strong, nonatomic) UIImageView *imageView;

- (void)updateCellImage:(UIImage *)image;

@end
