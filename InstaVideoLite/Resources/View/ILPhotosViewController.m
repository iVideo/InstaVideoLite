//
//  ILPhotosViewController.m
//  InstaVideoLite
//
//  Created by insta on 9/12/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILPhotosViewController.h"
#import "ILPlayerManager.h"
#import "ILPhotoCell.h"

@interface ILPhotosViewController ()

@property (strong, nonatomic) ILPlayerView *playerView;

@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation ILPhotosViewController

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.view.frame = frame;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createPlayerView];
    [self createPhotosGrid];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createPhotosGrid
{
    UICollectionViewLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, IL_PLAYER_H, IL_SCREEN_W, IL_SCREEN_H - IL_PLAYER_H) collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[ILPhotoCell class] forCellWithReuseIdentifier:@"photocell"];
    [self.view addSubview:_collectionView];
}

- (void)createPlayerView
{
    _playerView = [[ILPlayerView alloc] initWithFrame:CGRectMake(0, 0,IL_PLAYER_W, IL_PLAYER_H)];
    [_playerView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_playerView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"skateboarding" ofType:@"m4v"];
    [PLAYER setPlayerItemWithURLs:[NSArray arrayWithObject:[NSURL URLWithString:path]]];
    [self.playerView.playerLayer setPlayer:PLAYER.queuePlayer];
    [PLAYER play];
    
}

#pragma mark - UICollectionViewDelegation

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ILPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photocell" forIndexPath:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
