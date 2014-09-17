//
//  ILAlbumHeader.m
//  InstaVideoLite
//
//  Created by insta on 9/16/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILAlbumHeader.h"

@implementation ILAlbumHeader

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnBack setFrame:CGRectMake(.0f, 7.f, 40.f, 30.f)];
        [_btnBack setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [self addSubview:_btnBack];
        
        _lblGroup = [[UILabel alloc]initWithFrame:CGRectMake(40.f, 11.f, frame.size.width - 80.f, 22.f)];
        _lblGroup.textAlignment = NSTextAlignmentCenter;
        _lblGroup.textColor = [UIColor whiteColor];
        [self addSubview:_lblGroup];
        
    }
    return self;
}

@end
