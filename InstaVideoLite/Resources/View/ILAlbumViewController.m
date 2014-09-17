//
//  ILAlbumViewController.m
//  InstaVideoLite
//
//  Created by insta on 9/15/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILAlbumViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ILPlayerManager.h"
#import "ILAlbumManager.h"
#import "ILNavBarView.h"

#import "ILAlbumViewCell.h"
#import "ILAlbumHeader.h"

#import "ILAlbumGroupCell.h"

@interface ILAlbumViewController ()
<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,
UITableViewDataSource,UITableViewDelegate>
{
        NSString *path;
    
    CGFloat midHeight;
    
    CGPoint originTopViewPoint;
    CGPoint originMidViewPoint;
    
    CGPoint offsetTogglePoint;
    
    NSString *groupName;
}

@property (strong, nonatomic) UIView *topView; //Container
@property (strong, nonatomic) UIScrollView *playerView;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) UIButton *btnPlay;
@property (strong, nonatomic) UIView *toggleView;

@property (strong, nonatomic) UIView *midView; //Container
@property (strong, nonatomic) UITableView *groupView;
@property (strong, nonatomic) UICollectionView *albumView;

@property (strong, nonatomic) ILNavBarView *navBarView;

@property (strong, nonatomic) NSDictionary *groups; //groupView datasource
@property (strong, nonatomic) NSArray *assets;   //albumView datasource


@end

@implementation ILAlbumViewController

- (void)dealloc
{
    _assets = nil;
    _groups = nil;
    
    _moviePlayer = nil;
    _navBarView = nil;
    
    _albumView = nil;
    _groupView = nil;
    _midView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initialization];
    [self createTopView];
    [self createMidView];
    [self createNavView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialization
{
    path = [[NSBundle mainBundle] pathForResource:@"skateboarding" ofType:@"m4v"];
    
    _groups = [[NSDictionary alloc]initWithDictionary:[IL_ALBUM allVideoGroups]];
    ALAssetsGroup *firstGroup = (ALAssetsGroup *)[[_groups allValues] firstObject];
    groupName = [firstGroup valueForProperty:ALAssetsGroupPropertyName];
    _assets = [[NSArray alloc] initWithArray:[IL_ALBUM getVideoAssetsWithGroup:firstGroup]];
}

#pragma mark - midView

- (void)createMidView
{
    midHeight = IL_SCREEN_H - IL_PLAYER_H - IL_NAVBAR_H;
    _midView = [[UIView alloc] initWithFrame:CGRectMake(.0f, IL_PLAYER_H,2*IL_SCREEN_W,midHeight)];
    _midView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_midView];
    originMidViewPoint = _midView.center;
    
    [self createGroupView];
    [self createAlbumView];
    
    [self hideGroupView:nil];
}

- (void)createGroupView
{
    _groupView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IL_SCREEN_W, midHeight) style:UITableViewStylePlain];
    [_groupView registerClass:[ILAlbumGroupCell class] forCellReuseIdentifier:@"ILAlbumGroupCell"];
    _groupView.dataSource = self;
    _groupView.delegate = self;
    _groupView.backgroundView = nil;
    _groupView.backgroundColor = [UIColor clearColor];
    [_midView addSubview:_groupView];
}

- (void)createAlbumView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(IL_SCREEN_W / 4, IL_SCREEN_W / 4);
    flowLayout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
    flowLayout.minimumLineSpacing = .0f;
    flowLayout.minimumInteritemSpacing = 0.f;
    
    _albumView = [[UICollectionView alloc] initWithFrame:CGRectMake(IL_SCREEN_W, 0, IL_SCREEN_W, midHeight) collectionViewLayout:flowLayout];
    [_albumView registerClass:[ILAlbumHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ILAlbumHeader"];
    [_albumView registerClass:[ILAlbumViewCell class] forCellWithReuseIdentifier:@"ILAlbumViewCell"];
    _albumView.delegate = self;
    _albumView.dataSource = self;
    _albumView.backgroundColor = [UIColor clearColor];
    [_midView addSubview:_albumView];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_groups count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ILAlbumGroupCell *cell = (ILAlbumGroupCell *)[tableView dequeueReusableCellWithIdentifier:@"ILAlbumGroupCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundView = nil;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    ALAssetsGroup *group = [[_groups allValues] objectAtIndex:indexPath.row];
    cell.textLabel.text = [group valueForProperty:ALAssetsGroupPropertyName];
    cell.imageView.image = [UIImage imageWithCGImage:[group posterImage]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ALAssetsGroup *group = [[_groups allValues] objectAtIndex:indexPath.row];
    _assets = [IL_ALBUM getVideoAssetsWithGroup:group];
    groupName = [group valueForProperty:ALAssetsGroupPropertyName];
    [self hideGroupView:nil];
    [_albumView reloadData];
}


#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_assets count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    ILAlbumHeader *header =  [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ILAlbumHeader" forIndexPath:indexPath];
    [header.btnBack addTarget:self action:@selector(showGroupView:) forControlEvents:UIControlEventTouchUpInside];
    header.lblGroup.text = groupName;
    return header;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ILAlbumViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ILAlbumViewCell" forIndexPath:indexPath];
    ALAsset *asset = [_assets objectAtIndex:indexPath.row];
    [cell updateCellImage:[UIImage imageWithCGImage:[asset thumbnail]]
                 duration:[asset valueForProperty:ALAssetPropertyDuration]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    ALAsset *asset = [_assets objectAtIndex:indexPath.row];

    ILAlbumViewCell *cell = (ILAlbumViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectedBg.hidden = NO;
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ILAlbumViewCell *cell = (ILAlbumViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectedBg.hidden = YES;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(IL_SCREEN_W, IL_COMMON_H);
}

- (void)hideGroupView:(id)sender
{
    [UIView animateWithDuration:.5f animations:^{
        _groupView.hidden = YES;
        _albumView.hidden = NO;
        _midView.center = CGPointMake(_midView.center.x - IL_SCREEN_W, _midView.center.y);
    } completion:^(BOOL finished) {
        [_albumView reloadData];
    }];
}

- (void)showGroupView:(id)sender
{
    [UIView animateWithDuration:.5f animations:^{
        _groupView.hidden = NO;
        _albumView.hidden = YES;
        _midView.center = CGPointMake(_midView.center.x + IL_SCREEN_W, _midView.center.y);
    } completion:^(BOOL finished) {
        [_groupView reloadData];
    }];
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
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [_moviePlayer.view setFrame:CGRectMake(0.f, 0.f, IL_PLAYER_W, IL_PLAYER_H)];
    [_moviePlayer setControlStyle:MPMovieControlStyleNone];
    [_moviePlayer setScalingMode:MPMovieScalingModeAspectFill];
    [_moviePlayer setRepeatMode:MPMovieRepeatModeOne];
    [_moviePlayer setShouldAutoplay:YES];
    [_moviePlayer prepareToPlay];
    
    _playerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.f, 0.f, IL_PLAYER_W, IL_PLAYER_H)];
    [_playerView addSubview:_moviePlayer.view];
    
    [_topView addSubview:_playerView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieNaturalSizeAvailable:) name:MPMovieNaturalSizeAvailableNotification object:_moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieThumbnailLoadComplete:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:_moviePlayer];
    
    [_moviePlayer requestThumbnailImagesAtTimes:[NSArray arrayWithObject:[NSNumber numberWithDouble:0]] timeOption:MPMovieTimeOptionNearestKeyFrame];
    
}

- (void)movieThumbnailLoadComplete:(NSNotification*)notification
{
//    NSDictionary *userInfo = [notification userInfo];
}

- (void)movieNaturalSizeAvailable:(NSNotification*)notification
{
    float height = _moviePlayer.naturalSize.height;
    float width = _moviePlayer.naturalSize.width;
    float ratio = MAX(IL_PLAYER_H / height, IL_PLAYER_W / width);
    
    [_moviePlayer.view setFrame:CGRectMake(0.f, 0.f, width*ratio, height*ratio)];
    [_playerView setContentSize:_moviePlayer.view.frame.size];
    
    [_topView bringSubviewToFront:_btnPlay];
    [_topView bringSubviewToFront:_toggleView];
}

- (void)createPlayButton
{
    CGRect btnPlayFrame = CGRectMake(IL_PLAYER_W/2 - 35.f, IL_PLAYER_H/2, 70.f, 70.f);
    _btnPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnPlay.frame = btnPlayFrame;
    _btnPlay.center = _moviePlayer.view.center;
    [_btnPlay setImage:[UIImage imageNamed:@"Pause"] forState:UIControlStateNormal];
    [_btnPlay setImage:[UIImage imageNamed:@"play"] forState:UIControlStateSelected];
    [_btnPlay addTarget:self action:@selector(btnPlayPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_btnPlay];
}

- (void)btnPlayPressed:(UIButton *)sender
{
    if (!sender.selected) {
        sender.selected = YES;
        [_moviePlayer pause];
        return;
    }
    sender.selected = NO;
    [_moviePlayer play];
}

- (void)createToggleView
{
    _toggleView = [[UIView alloc] initWithFrame:CGRectMake(.0f, IL_PLAYER_H - IL_COMMON_H, IL_SCREEN_W, IL_COMMON_H)];
    _toggleView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
    [_topView addSubview:_toggleView];
    
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
            [_topView setCenter:CGPointMake(_topView.center.x, _topView.center.y + offsetTogglePoint.y)];
            [_midView setCenter:CGPointMake(_midView.center.x, _midView.center.y + offsetTogglePoint.y)];
            [recognizer setTranslation:CGPointZero inView:self.view];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (offsetTogglePoint.y < 0 ) {
                [_topView setCenter:CGPointMake(_topView.center.x, originTopViewPoint.y - IL_PLAYER_H/2 -80.f)];
                [_midView setCenter:CGPointMake(_midView.center.x, originMidViewPoint.y - IL_PLAYER_H/2 -80.f)];
            }else{
                [_topView setCenter:CGPointMake(_topView.center.x,originTopViewPoint.y)];
                [_midView setCenter:CGPointMake(_midView.center.x,originMidViewPoint.y)];
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
