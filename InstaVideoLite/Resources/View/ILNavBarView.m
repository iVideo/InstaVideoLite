//
//  ILNavBarView.m
//  InstaVideoLite
//
//  Created by insta on 9/12/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILNavBarView.h"


@implementation ILNavBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bar_btn"]];

        _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnBack setFrame:CGRectMake(0, 0, 44, 44)];
        [_btnBack setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [self addSubview:_btnBack];

        _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnBack setFrame:CGRectMake(276, 0, 44, 44)];
        [_btnBack setImage:[UIImage imageNamed:@"Next"] forState:UIControlStateNormal];
        [self addSubview:_btnBack];
        
    }
    return self;
}

@end
