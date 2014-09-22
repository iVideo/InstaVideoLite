//
//  ILAlbumViewCell.m
//  InstaVideoLite
//
//  Created by insta on 9/15/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILAlbumViewCell.h"

@interface ILAlbumViewCell ()

@property (strong, nonatomic) UIImageView *selectedBg;

@end

@implementation ILAlbumViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(0.f, 0.f, 80.f, 80.f);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundView = nil;
        self.backgroundColor = [UIColor clearColor];
        
        _selectedBg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"play_edit_btn"]];
        _selectedBg.frame = CGRectMake(1.f, 1.f, 78.f, 78.f);
        _selectedBg.contentMode = UIViewContentModeScaleAspectFill;
//        _selectedBg.hidden = YES;
//        [self addSubview:_selectedBg];
        self.selectedBackgroundView = _selectedBg;
        
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(2.f, 2.f, 76.f, 76.f)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self insertSubview:_imageView aboveSubview:_selectedBg];
        
        _choosenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _choosenBtn.frame = CGRectMake(50.f, 8.f, 22.f, 22.f);
        [_choosenBtn setImage:[UIImage imageNamed:@"home_choose_btn"] forState:UIControlStateNormal];
        [_choosenBtn setImage:[UIImage imageNamed:@"home_choose_btn-"] forState:UIControlStateSelected];
        _choosenBtn.selected = NO;
        _choosenBtn.userInteractionEnabled = NO;
        [self addSubview:_choosenBtn];
        
        _infoView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 50.f, 80.f, 30.f)];
        
        _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_icon"]];
        _iconView.frame = CGRectMake(.0f, .0f, 40.f, 30.f);
        _iconView.contentMode = UIViewContentModeCenter;
        [_infoView addSubview:_iconView];
        
        _lblDuration = [[UILabel alloc]initWithFrame:CGRectMake(40.f, 4.f, 40.f, 22.f)];
        _lblDuration.backgroundColor = [UIColor clearColor];
        _lblDuration.textAlignment = NSTextAlignmentCenter;
        _lblDuration.textColor = [UIColor whiteColor];
        [_lblDuration setFont:[UIFont systemFontOfSize:11.f]];
        [_infoView addSubview:_lblDuration];
        
        [self insertSubview:_infoView aboveSubview:_imageView];
        
    }
    return self;
}

- (void)updateCellImage:(UIImage *)image duration:(NSNumber *)duration
{
    long long time = [duration longLongValue]; int minute = (int)time / 60; int sec = (int)time % 60;
    if(minute >= 0 && minute < 60 && sec >= 0 && sec < 60){
        _lblDuration.text = [NSString stringWithFormat:@"%02d:%02d", minute, sec];
    }else{
        _lblDuration.text = @"00:00";
    }
    _imageView.image = image;
    
    [self setNeedsDisplay];
}

@end
