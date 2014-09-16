//
//  ILClipDockView.m
//  InstaVideoLite
//
//  Created by insta on 9/11/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILClipDockView.h"

#define THRUMB_H 70.f
#define THRUMB_W 70.f

@interface ILClipDockView ()
{
    CGFloat beganX;
    CGFloat endedX;

    NSInteger totalBtnCount;
    NSInteger currentBtnTag;
    
    CGAffineTransform originTrans;
}

@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation ILClipDockView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bk_btn.png"]];
        [self createScrollView];
    }
    return self;
}

- (void)deleteScrollView
{
    [_scrollView removeFromSuperview];
}

- (void)createScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:
                   CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollView];
}

- (void)initialize
{
    [self clearContentView];
    [self createContentView];
}

- (void)clearContentView
{
    for (UIView *subView in [_scrollView subviews]) {
        [subView removeFromSuperview];
    }
}

- (void)createContentView
{
    NSArray *assets = [DATASTORE getMovieClips];
    for (int i = 0; i < [assets count]; i ++) {
        AVAsset *asset = [assets objectAtIndex:i];
        [self createThumbView:asset maxCount:i];
    }
    _scrollView.contentSize = CGSizeMake(72*[assets count], self.frame.size.height);
}

//- (void)addLastAsset
//{
//    NSArray *assets = [DATASTORE getMovieClips];
//    AVAsset *asset = [assets lastObject];
//    NSInteger i = [assets count];
//    [self createThumbView:asset maxCount:i];
//    _scrollView.contentSize = CGSizeMake(72*[assets count], self.frame.size.height);
//}

- (void)createThumbView:(AVAsset *)asset maxCount:(NSInteger)i
{
    UIView *thumbView = [[UIView alloc] initWithFrame:CGRectMake((i-1) * THRUMB_W, 1, THRUMB_W, THRUMB_H)];
    thumbView.tag = i;
    NSLog(@"Create ThumbView Tag : %ld", (long)i);
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                             action:@selector(tapThumb:)];
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 1;
    [thumbView addGestureRecognizer:panGesture];
    
    UIImageView *selectView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 66, 66)];
    selectView.image = [UIImage imageNamed:@"edit_btn"];
    [thumbView addSubview:selectView];
    
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    UIImage *coverImage = [UIImage imageWithCGImage:[generator copyCGImageAtTime:kCMTimeZero actualTime:nil error:nil]];
    UIImageView *coverView = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 64, 64)];
    coverView.image = coverImage;
    [thumbView insertSubview:coverView aboveSubview:selectView];
    
//    CGRect btnPlayFrame = CGRectMake(20, 18, 36, 36);
//    UIButton *btnPlay = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btnPlay setFrame:btnPlayFrame];
//    [btnPlay setImage:[UIImage imageNamed:@"play_btn.png"] forState:UIControlStateNormal];
//    [btnPlay addTarget:self action:@selector(btnPlayPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [btnPlay setTag:i];
//    [thumbView insertSubview:btnPlay aboveSubview:coverView];
    
    [_scrollView addSubview:thumbView];
}

- (void)btnPlayPressed:(UIButton *)sender
{
    NSLog(@"%ld",(long)sender.tag);
}

- (void)tapThumb:(UIPanGestureRecognizer *)sender
{
    UIView *view = sender.view;
    if (sender.state == UIGestureRecognizerStateBegan) {
        [_scrollView bringSubviewToFront:view];
        originTrans = view.transform;
        //Transform 10% bigger
        CGAffineTransform trans = CGAffineTransformScale(originTrans, 1.2f, 1.1f);
        view.transform = trans;
        
        NSLog(@"state : UIGestureRecognizerStateBegan");
        currentBtnTag = view.tag;
        totalBtnCount = [[_scrollView subviews] count];
        return;
    }else if (sender.state == UIGestureRecognizerStateEnded) {
        //        NSLog(@"endedX : %f",view.center.x);
//        NSInteger radio = ceil(view.center.x/THRUMB_W *view.tag);
//        NSLog(@"Ended With Radio : %li",(long)radio);
        
        //Transform to orginal
        view.transform = originTrans;
        
        [view setCenter:CGPointMake((view.tag - 1) * 70 + 35 , view.center.y)];
        return;
    }else{
    
        CGPoint offset = [sender translationInView:_scrollView];
        [view setCenter:CGPointMake(view.center.x + offset.x, view.center.y)];
        [sender setTranslation:CGPointMake(0, 0) inView:_scrollView];
    
//        CGFloat radio = view.center.x/THRUMB_W*view.tag;
//        NSLog(@"Changed With Radio : %f",radio);
        
        [self aaa:view];
    }
}

-(void)bbb:(UIView *)view
{
//    NSInteger radio = ceil(view.center.x/THRUMB_W *view.tag);
    
}
    
-(void)aaa:(UIView *)view
{
    //Change current btn to next position
    if (view.center.x > totalBtnCount * 70) { //OffBound
        NSLog(@"View Tag : %li -- OffBound : %f", (long)view.tag, view.center.x);
        return;
    }else if (view.center.x > 70 * view.tag) {
        NSLog(@"View Tag : %li -- rightOff : %f", (long)view.tag, view.center.x);
        for (UIView *subView in [_scrollView subviews]) {
            if (subView.tag == currentBtnTag + 1 ) {
                subView.tag = currentBtnTag;
                [subView setCenter:CGPointMake(subView.center.x - 70, subView.center.y)];
            }
        }
        currentBtnTag +=1;
        view.tag = currentBtnTag;
        //        NSLog(@"currentBtnTag : %ld", (long)currentBtnTag);
        return;
    }else if (70 < view.center.x < 70 * (view.tag - 1)) {
        NSLog(@"View Tag : %li -- leftOff : %f", (long)view.tag, view.center.x);
        //        for (UIView *subView in [_scrollView subviews]) {
        //            if (subView.tag == currentBtnTag - 1 ) {
        //                subView.tag = currentBtnTag;
        //                [subView setCenter:CGPointMake(subView.center.x + 70, subView.center.y)];
        //            }
        //        }
        //        currentBtnTag -=1;
        //        view.tag = currentBtnTag;
        return;
    }else if (70 >= view.center.x) {
        NSLog(@"View Tag : %li -- Less Zero : %f", (long)view.tag, view.center.x);
        return;
    }else{
        NSLog(@"View Tag : %li -- Other Position : %f", (long)view.tag, view.center.x);
        return;
    }
}

@end
