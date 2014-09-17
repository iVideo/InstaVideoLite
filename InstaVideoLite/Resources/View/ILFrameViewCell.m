//
//  ILFrameViewCell.m
//  InstaVideoLite
//
//  Created by insta on 9/16/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILFrameViewCell.h"

@implementation ILFrameViewCell

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
        _selectedBg.hidden = YES;
        [self addSubview:_selectedBg];
        
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(2.f, 2.f, 76.f, 76.f)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self insertSubview:_imageView aboveSubview:_selectedBg];
    }
    return self;
}

- (void)updateCellImage:(UIImage *)image
{
    _imageView.image = image;
    [self setNeedsDisplay];
}
@end
