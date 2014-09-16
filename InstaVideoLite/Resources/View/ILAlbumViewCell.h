//
//  ILAlbumViewCell.h
//  InstaVideoLite
//
//  Created by insta on 9/15/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ILAlbumViewCell : UICollectionViewCell

@property (strong, nonatomic) UIView *infoView;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *lblDuration;

@property (strong, nonatomic) UIImageView *selectedBg;
@property (strong, nonatomic) UIImageView *imageView;

- (void)updateCellImage:(UIImage *)image duration:(NSString *)duration;

@end
