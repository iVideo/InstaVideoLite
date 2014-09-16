//
//  ILAlbumHeader.h
//  InstaVideoLite
//
//  Created by insta on 9/16/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ILAlbumHeader : UICollectionReusableView

@property (strong, nonatomic) UIButton *btnBack;
@property (strong, nonatomic) UILabel *lblGroup;

-(instancetype)initWithFrame:(CGRect)frame;

@end
