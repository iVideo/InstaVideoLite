//
//  ILPhotoCell.m
//  InstaVideoLite
//
//  Created by insta on 9/12/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILPhotoCell.h"

@implementation ILPhotoCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 72, 72)];
        [imageView setImage:[UIImage imageNamed:@"play.png"]];
        [self addSubview:imageView];
    }
    return self;
}

@end
