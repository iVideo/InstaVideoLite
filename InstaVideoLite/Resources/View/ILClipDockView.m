//
//  ILClipDockView.m
//  InstaVideoLite
//
//  Created by insta on 9/11/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILClipDockView.h"
#import "ILClipView.h"

#define THRUMB_H 70.f
#define THRUMB_W 70.f

@interface ILClipDockView ()
{
    ILClipView *lastView;
    
    NSInteger selectedIndex;
    
    CGPoint originalCenter;
    
    BOOL hasContain;
    
    CGFloat beganX;
    CGFloat endedX;

    NSInteger totalBtnCount;
    NSInteger currentBtnTag;
    
    CGAffineTransform originTrans;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *thumbArray;//<ILClipView>
@property (strong, nonatomic) NSMutableArray *assetArray;//<URL>

@end

@implementation ILClipDockView

#pragma mark - public

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bk_btn.png"]];
        [self initDockView];
    }
    return self;
}

- (void)updateDockView
{
    NSArray *urls = [IL_DATA getClipURLs];
    if ([urls count] < 1) {
        return;
    }else{
        [_assetArray addObjectsFromArray:urls];
        [IL_DATA clearClips];
        [self rebuildContent];
    }
}

- (void)removeSelectedItem
{
    if (selectedIndex < 0) {
        return;
    }
    if ([_assetArray count] > selectedIndex) {
        [_assetArray removeObjectAtIndex:selectedIndex];
        [self rebuildContent];
    }
}

- (void)replaceSelectedItem:(NSURL *)url
{
    if (selectedIndex < 0) {
        return;
    }
    if ([_assetArray count] > selectedIndex) {
        [_assetArray replaceObjectAtIndex:selectedIndex withObject:url];
        [self rebuildContent];
    }
}

- (NSURL *)getSelectedItem
{
    if (selectedIndex < 0) {
        return nil;
    }
    if ([_assetArray count] > selectedIndex) {
        return _assetArray[selectedIndex];
    }
        return nil;
}

#pragma mark - private

- (void)initDockView
{
    _assetArray = [[NSMutableArray alloc] initWithCapacity:1];
    _thumbArray = [[NSMutableArray alloc] initWithCapacity:1];
    selectedIndex = -1;
    [self createScrollView];
}

- (void)createScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:
                   CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollView];
}

- (void)deleteScrollView
{
    [_scrollView removeFromSuperview];
}

- (void)rebuildContent
{
    selectedIndex = -1;
    [self clearContentView];
    [self createContentView];
}

- (void)clearContentView
{
    for (UIView *subView in [_scrollView subviews]) {
        [subView removeFromSuperview];
    }
    
    [_thumbArray removeAllObjects];
}

- (void)createContentView
{
    for (int i = 0; i < [_assetArray count]; i++) {
        [self createThumbView:[_assetArray objectAtIndex:i] index:i];
    }
    _scrollView.contentSize = CGSizeMake(THRUMB_W*([_assetArray count]), self.frame.size.height);
}

- (void)createThumbView:(NSURL *)url index:(NSInteger)idx
{
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc]initWithAsset:[AVAsset assetWithURL:url]];
    generator.maximumSize = CGSizeMake(THRUMB_W, THRUMB_H);
    generator.appliesPreferredTrackTransform = YES;
    CMTime actualTime; NSError *error;
    CGImageRef imgRef = [generator copyCGImageAtTime:kCMTimeZero actualTime:&actualTime error:&error];
    UIImage *image = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    ILClipView *thumbView = [[ILClipView alloc] initWithFrame:CGRectMake(idx * THRUMB_W, 1.f,THRUMB_W, THRUMB_W) image:image];
    
    [_thumbArray addObject:thumbView];
    [_scrollView addSubview:thumbView];
    
    UITapGestureRecognizer *tapGusture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapThumb:)];
    [thumbView addGestureRecognizer:tapGusture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self
                                                                                action:@selector(thumbViewPan:)];
    panGesture.minimumNumberOfTouches = 1;
    panGesture.maximumNumberOfTouches = 1;
    [thumbView addGestureRecognizer:panGesture];
}

- (void)tapThumb:(UITapGestureRecognizer *)recognizer
{
    lastView.clipBg.hidden = YES;
    [lastView setNeedsDisplay];
    
    ILClipView *clipView = (ILClipView *)recognizer.view;
    clipView.clipBg.hidden = NO;
    [clipView setNeedsDisplay];
    
    selectedIndex = [_thumbArray indexOfObject:clipView];
    lastView = clipView;
}


- (NSInteger)indexOfPoint:(CGPoint)point inView:(UIView *)view
{
    for (UIView *thumb in _thumbArray) {
        if (thumb != view) {
            if (CGRectContainsPoint(thumb.frame, point))
            {
                return [_thumbArray indexOfObject:thumb];
            }
        }
    }
    return -1;
}

- (void)thumbViewPan:(UIPanGestureRecognizer *)recognizer
{
    UIView *view = recognizer.view;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self bringSubviewToFront:view];
            originalCenter = view.center;
            [UIView animateWithDuration:.2f animations:^{
                view.transform = CGAffineTransformMakeScale(1.1, 1.1);
                view.alpha = 0.7;
            }];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint offset = [recognizer translationInView:view];
            view.center = CGPointMake(view.center.x + offset.x, view.center.y);
            [recognizer setTranslation:CGPointZero inView:view];
            
            NSInteger idxOfPoint = [self indexOfPoint:view.center inView:view];
            if (idxOfPoint < 0) {
                hasContain = NO;
            }else{
                [UIView animateWithDuration:.2f animations:^{
                    UIView *viewOfPoint = _thumbArray[idxOfPoint];
                    CGPoint viewOfPointCenter = viewOfPoint.center;
                    viewOfPoint.center = originalCenter;
                    originalCenter = viewOfPointCenter;
                    hasContain = YES;
                }];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [UIView animateWithDuration:.2f animations:^{
                view.transform = CGAffineTransformIdentity;
                view.alpha = 1.0;
                if (!hasContain)
                {
                    view.center = originalCenter;
                }
            }];
        }
            break;
            
        default:
            break;
    }
}

@end
