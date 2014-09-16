//
//  ILAlbumViewController.m
//  InstaVideoLite
//
//  Created by insta on 9/15/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILAlbumViewController.h"
#import "ILPlayerManager.h"
#import "ILNavBarView.h"

#import "ILAlbumViewCell.h"
#import "ILAlbumHeader.h"

@interface ILAlbumViewController ()
<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    CGFloat midHeight;
    
    CGPoint originTopViewPoint;
    CGPoint originMidViewPoint;
    
    CGPoint offsetTogglePoint;
}

@property (strong, nonatomic) UIView *topView; //Container
@property (strong, nonatomic) UIView *toggleView;
@property (strong, nonatomic) UIButton *btnPlay;
@property (strong, nonatomic) ILPlayerView *playerView;

@property (strong, nonatomic) UIView *midView; //Container
@property (strong, nonatomic) UITableView *groupView;
@property (strong, nonatomic) UICollectionView *albumView;

@property (strong, nonatomic) ILNavBarView *navBarView;

@end

@implementation ILAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createTopView];
    [self createMidView];
    [self createNavView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - midView

- (void)createMidView
{
    midHeight = IL_SCREEN_H - IL_PLAYER_H - IL_NAVBAR_H;
    _midView = [[UIView alloc] initWithFrame:CGRectMake(.0f, IL_PLAYER_H,IL_SCREEN_W,midHeight)];
    _midView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_midView];
    originMidViewPoint = _midView.center;
    
//    _groupView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IL_SCREEN_W, midHeight) style:UITableViewStylePlain];
//    _groupView.backgroundColor = [UIColor redColor];
//    [_midView addSubview:_groupView];
//    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(IL_SCREEN_W / 4, IL_SCREEN_W / 4);
    flowLayout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
    flowLayout.minimumLineSpacing = .0f;
    flowLayout.minimumInteritemSpacing = 0.f;
    
//    UICollectionReusableView *sectionHeader = [[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, IL_SCREEN_W, IL_COMMON_H)];
//    sectionHeader.
    
    _albumView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, IL_SCREEN_W, midHeight) collectionViewLayout:flowLayout];
    [_albumView registerClass:[ILAlbumHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ILAlbumHeader"];
    [_albumView registerClass:[ILAlbumViewCell class] forCellWithReuseIdentifier:@"ILAlbumViewCell"];
    _albumView.delegate = self;
    _albumView.dataSource = self;
    _albumView.backgroundColor = [UIColor clearColor];
    [_midView addSubview:_albumView];
    
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 29;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    ILAlbumHeader *header =  [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ILAlbumHeader" forIndexPath:indexPath];
    header.lblGroup.text = @"Camera Roll";
    return header;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    ILAlbumViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    NSLog(@"%ld",(long)indexPath.row);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ILAlbumViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ILAlbumViewCell" forIndexPath:indexPath];
    [cell updateCellImage:nil duration:@"0:00"];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(IL_SCREEN_W, IL_COMMON_H);
}


#pragma mark - topView

- (void)createTopView
{
    _topView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, IL_PLAYER_W, IL_PLAYER_H)];
    _topView.backgroundColor = [UIColor blackColor];
    originTopViewPoint = _topView.center;
    [self.view addSubview:_topView];
    
    [self createPlayerView];
    [self createPlayButton];
    [self createToggleView];
}

- (void)createPlayerView
{
    _playerView = [[ILPlayerView alloc] initWithFrame:CGRectMake(.0f, .0f, IL_PLAYER_W, IL_PLAYER_H)];
    [_playerView setBackgroundColor:[UIColor blackColor]];
    [_topView insertSubview:_playerView atIndex:0];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"jerryfish" ofType:@"m4v"];
    [PLAYER setPlayerItemWithAssets:@[[AVAsset assetWithURL:[[NSURL alloc]initFileURLWithPath:path]]]];
    [self.playerView.playerLayer setPlayer:PLAYER.queuePlayer];
    [PLAYER play];
}

- (void)createPlayButton
{
    CGRect btnPlayFrame = CGRectMake(IL_PLAYER_W/2 - 35.f, IL_PLAYER_H/2, 70.f, 70.f);
    _btnPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnPlay setFrame:btnPlayFrame];
    [_btnPlay setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [_btnPlay setImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    [_btnPlay addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
    [_playerView addSubview:_btnPlay];
    _btnPlay.center = _playerView.center;
    _btnPlay.selected = NO;
}

- (void)createToggleView
{
    _toggleView = [[UIView alloc] initWithFrame:CGRectMake(.0f, IL_PLAYER_H - IL_COMMON_H, IL_SCREEN_W, IL_COMMON_H)];
    _toggleView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
    [_topView insertSubview:_toggleView aboveSubview:_playerView];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panToggle:)];
    [_toggleView addGestureRecognizer:panGesture];
}

- (void)panToggle:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            offsetTogglePoint = [recognizer translationInView:self.view];
            NSLog(@"%f",offsetTogglePoint.y);
            [_topView setCenter:CGPointMake(_topView.center.x, _topView.center.y + offsetTogglePoint.y)];
            [_midView setCenter:CGPointMake(_midView.center.x, _midView.center.y + offsetTogglePoint.y)];
            [recognizer setTranslation:CGPointZero inView:self.view];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (offsetTogglePoint.y < 0 ) {
                [_topView setCenter:CGPointMake(_topView.center.x, originTopViewPoint.y - IL_PLAYER_H/2 -80.f)];
                [_midView setCenter:CGPointMake(_topView.center.x, originMidViewPoint.y - IL_PLAYER_H/2 -80.f)];
            }else{
                [_topView setCenter:CGPointMake(_topView.center.x,originTopViewPoint.y)];
                [_midView setCenter:CGPointMake(_topView.center.x,originMidViewPoint.y)];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)playPause:(UIButton *)sender
{
    if (sender.selected == YES) {
        sender.selected = NO;
        [PLAYER pause];
        return;
    }
    sender.selected = YES;
    [PLAYER play];
}

#pragma mark - naviBarView

- (void)createNavView
{
    _navBarView = [[ILNavBarView alloc] initWithFrame:CGRectMake(.0f, IL_SCREEN_H - IL_COMMON_H, IL_SCREEN_W, IL_COMMON_H)];
    [_navBarView.btnBack addTarget:self action:@selector(btnBackPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_navBarView.btnNext addTarget:self action:@selector(btnNextPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_navBarView];
}

- (void)btnBackPressed:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnNextPressed:(UIButton *)sender
{
    
}

@end
