//
//  ILAlbumViewCell.m
//  InstaVideoLite
//
//  Created by insta on 9/15/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILAlbumViewCell.h"

@implementation ILAlbumViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(0.f, 0.f, 80.f, 80.f);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _selectedBg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"play_edit_btn"]];
        _selectedBg.frame = CGRectMake(1.f, 1.f, 78.f, 78.f);
        _selectedBg.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_selectedBg];
        
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(2.f, 2.f, 76.f, 76.f)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self insertSubview:_imageView aboveSubview:_selectedBg];
        
        _infoView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 50.f, 80.f, 30.f)];
        
        _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_icon"]];
        _iconView.frame = CGRectMake(.0f, .0f, 40.f, 30.f);
        _iconView.contentMode = UIViewContentModeCenter;
        [_infoView addSubview:_iconView];
        
        _lblDuration = [[UILabel alloc]initWithFrame:CGRectMake(40.f, 4.f, 40.f, 22.f)];
        _lblDuration.textAlignment = NSTextAlignmentCenter;
        _lblDuration.textColor = [UIColor whiteColor];
        [_infoView addSubview:_lblDuration];
        
        [self insertSubview:_infoView aboveSubview:_imageView];
        
    }
    return self;
}

- (void)updateCellImage:(UIImage *)image duration:(NSString *)duration
{
    _imageView.image = image;
    _lblDuration.text = duration;
    [self setNeedsDisplay];
}

@end
