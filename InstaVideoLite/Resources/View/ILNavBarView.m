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

        _btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnNext setFrame:CGRectMake(IL_SCREEN_W - 44, 0, 44, 44)];
        [_btnNext setImage:[UIImage imageNamed:@"Next"] forState:UIControlStateNormal];
        [self addSubview:_btnNext];
        
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_indicator setFrame:CGRectMake(IL_SCREEN_W - 44, 0, 44, 44)];
        _indicator.hidesWhenStopped = YES;
        _indicator.hidden = YES;
        [self insertSubview:_indicator aboveSubview:_btnNext];
        
    }
    return self;
}

- (void)startWaiting
{
    _btnNext.hidden = YES;
    _indicator.hidden = NO;
    [_indicator startAnimating];
}

- (void)stopWaited
{
    [_indicator stopAnimating];
    _indicator.hidden = YES;
    _btnNext.hidden = NO;
}

@end
