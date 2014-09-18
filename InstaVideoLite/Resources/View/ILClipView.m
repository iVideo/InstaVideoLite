//
//  ILClipView.m
//  InstaVideoLite
//
//  Created by insta on 9/17/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILClipView.h"

@implementation ILClipView

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _clipBg = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 66, 66)];
        _clipBg.image = [UIImage imageNamed:@"edit_btn"];
        _clipBg.hidden = YES;
        [self addSubview:_clipBg];
        
        _clipImage = [[UIImageView alloc] initWithFrame:CGRectMake(3.f, 3.f, 64.f, 64.f)];
        _clipImage.image = image;
        [self addSubview:_clipImage];
        
        //    CGRect btnPlayFrame = CGRectMake(20, 18, 36, 36);
        //    UIButton *btnPlay = [UIButton buttonWithType:UIButtonTypeCustom];
        //    [btnPlay setFrame:btnPlayFrame];
        //    [btnPlay setImage:[UIImage imageNamed:@"play_btn.png"] forState:UIControlStateNormal];
        //    [btnPlay addTarget:self action:@selector(btnPlayPressed:) forControlEvents:UIControlEventTouchUpInside];
        //    [btnPlay setTag:i];
        //    [self insertSubview:btnPlay aboveSubview:coverView];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
