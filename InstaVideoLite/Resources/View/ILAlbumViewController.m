//
//  ILAlbumViewController.m
//  InstaVideoLite
//
//  Created by insta on 9/15/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILAlbumViewController.h"
#import "ILAlbumManager.h"

#import "ILAlbumViewCell.h"
#import "ILAlbumHeader.h"

#import "ILAlbumGroupCell.h"

@interface ILAlbumViewController ()
<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,
UITableViewDataSource,UITableViewDelegate>
{
    CGFloat midHeight;
    
    CGPoint originTopViewPoint;
    
    CGRect originGroupFrame;
    CGRect originAlbumFrame;
    CGRect originMidViewFrame;
    
    CGPoint offsetPoint;
    
    NSString *groupName;
}

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIScrollView *playerView;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) UIButton *btnPlay;
@property (strong, nonatomic) UIView *toggleView;

@property (strong, nonatomic) UIView *midView;
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
    
    _navBarView = nil;

    _albumView = nil;
    _groupView = nil;
    _midView = nil;
    
    _moviePlayer = nil;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:MPMoviePlayerThumbnailImageRequestDidFinishNotification
//                                                  object:_moviePlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMovieNaturalSizeAvailableNotification
                                                  object:_moviePlayer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_groups == nil || [_groups count] < 1) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self firstAlbumSelected];
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
    _groups = [[NSDictionary alloc]initWithDictionary:[IL_ALBUM allVideoGroups]];
    ALAssetsGroup *firstGroup = (ALAssetsGroup *)[[_groups allValues] firstObject];
    groupName = [firstGroup valueForProperty:ALAssetsGroupPropertyName];
    _assets = [[NSArray alloc] initWithArray:[IL_ALBUM getVideoAssetsWithGroup:firstGroup]];
}

- (void)firstAlbumSelected
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_albumView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionTop];
    [self selectedAlbumWithIndexPath:indexPath];
    
}

#pragma mark - midView

- (void)createMidView
{
    midHeight = IL_SCREEN_H - IL_PLAYER_H - IL_NAVBAR_H;
    originMidViewFrame = CGRectMake(.0f, IL_PLAYER_H,2*IL_SCREEN_W,midHeight);
    _midView = [[UIView alloc] initWithFrame:originMidViewFrame];
    _midView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_midView];
    
    [self createGroupView];
    [self createAlbumView];
    
    [self hideGroupView:nil];
}

- (void)createGroupView
{
    originGroupFrame = CGRectMake(0, 0, IL_SCREEN_W, midHeight);
    _groupView = [[UITableView alloc]initWithFrame:originGroupFrame style:UITableViewStylePlain];
    [_groupView registerClass:[ILAlbumGroupCell class] forCellReuseIdentifier:@"ILAlbumGroupCell"];
    _groupView.dataSource = self;
    _groupView.delegate = self;
    _groupView.backgroundView = nil;
    _groupView.backgroundColor = [UIColor clearColor];
    _groupView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_midView addSubview:_groupView];
}

- (void)createAlbumView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(IL_SCREEN_W / 4, IL_SCREEN_W / 4);
    flowLayout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
    flowLayout.minimumLineSpacing = .0f;
    flowLayout.minimumInteritemSpacing = 0.f;
    
    originAlbumFrame = CGRectMake(IL_SCREEN_W, 0, IL_SCREEN_W, midHeight);
    _albumView = [[UICollectionView alloc] initWithFrame:originAlbumFrame collectionViewLayout:flowLayout];
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
    [self firstAlbumSelected];
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
    [self selectedAlbumWithIndexPath:indexPath];
}

- (void)selectedAlbumWithIndexPath:(NSIndexPath *)indexPath
{
    ALAsset *asset = [_assets objectAtIndex:indexPath.row];
    [_moviePlayer stop];
    _moviePlayer.contentURL = [[asset defaultRepresentation] url];
    NSLog(@" Album moviePlayer.contentURL %@",_moviePlayer.contentURL);
    [_moviePlayer prepareToPlay];
    ILAlbumViewCell *cell = (ILAlbumViewCell *)[_albumView cellForItemAtIndexPath:indexPath];
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
    self.view.backgroundColor = [UIColor blackColor];
    _topView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, IL_PLAYER_W, IL_PLAYER_H)];
    _topView.backgroundColor = [UIColor clearColor];
    originTopViewPoint = _topView.center;
    [self.view addSubview:_topView];
    
    [self createPlayerView];
    [self createPlayButton];
    [self createToggleView];
}

- (void)createPlayerView
{
    _moviePlayer = [[MPMoviePlayerController alloc] init];
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
    [_playerView setScrollsToTop:NO];
    [_playerView setCenter:_topView.center];
    [_topView bringSubviewToFront:_btnPlay];
    [_topView bringSubviewToFront:_toggleView];
    NSLog(@"movieNaturalSizeAvailable notification");
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
    [_btnPlay setSelected:YES];
    [_topView addSubview:_btnPlay];
}

- (void)btnPlayPressed:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (!sender.selected) {
        [_moviePlayer pause];
        return;
    }
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
            offsetPoint = [recognizer translationInView:self.view];
            CGFloat offsetY = offsetPoint.y;
            [UIView animateWithDuration:IL_DURA animations:^{
                [self resetViewHeight:offsetY];
                [_topView setCenter:CGPointMake(_topView.center.x, _topView.center.y + offsetY)];
                [_midView setCenter:CGPointMake(_midView.center.x, _midView.center.y + offsetY)];
            }];
            [self.view setNeedsDisplay];
            [recognizer setTranslation:CGPointZero inView:self.view];
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGFloat offsetY = offsetPoint.y;
            [UIView animateWithDuration:IL_DURA animations:^{
                [self endedTopView:offsetY];
                [self endedMidView:offsetY];
            }];
            [self.view bringSubviewToFront:_topView];
            [self.view setNeedsDisplay];
        }
            break;
            
        default:
            break;
    }
}

- (void)resetViewHeight:(CGFloat)offsetY
{
    [self resetAView:offsetY];
    [self resetMView:offsetY];
    [self resetGView:offsetY];
}

- (void)endedTopView:(CGFloat)offsetY
{
    CGFloat centerY;
    if (offsetY < 0 ) {
        CGFloat top_view_offset_y = 0.75 * _topView.frame.size.height;// 3/4 topView
        centerY = originTopViewPoint.y - top_view_offset_y;
    }else{
        centerY = originTopViewPoint.y;
    }
    [_topView setCenter:CGPointMake(_topView.center.x, centerY)];
}

- (void)endedMidView:(CGFloat)offsetY
{
    if (offsetY < 0 ) {
        CGFloat mid_origin_y = 0.25 * _topView.frame.size.height; // 1/4 topView
        CGFloat mid_size_h = IL_SCREEN_H - mid_origin_y - IL_NAVBAR_H;
        
        CGFloat originX = _midView.frame.origin.x;
        CGFloat originY = mid_origin_y;
        CGFloat size_W = _midView.frame.size.width;
        CGFloat size_H = mid_size_h;
//        NSLog(@"X %f,Y %f,W %f,H %f",originX,originY,size_W,size_H);
        _midView.frame = CGRectMake(originX,originY,size_W,size_H);
        
        [UIView animateWithDuration:IL_DURA * 3 animations:^{
            [self resetAlbumViewHeight:mid_size_h];
            [self resetGroupViewHeight:mid_size_h];
        }];
        
    }else{
        
        CGFloat originX = _midView.frame.origin.x;
        CGFloat originY = originMidViewFrame.origin.y;
        CGFloat size_W = _midView.frame.size.width;
        CGFloat size_H = originMidViewFrame.size.height;
        _midView.frame = CGRectMake(originX,originY,size_W,size_H);
        
        [UIView animateWithDuration:IL_DURA * 3 animations:^{
            _groupView.frame = originGroupFrame;
            _albumView.frame = originAlbumFrame;
        }];
    }
}

- (void)resetGroupViewHeight:(CGFloat)height
{
    CGFloat originX = _groupView.frame.origin.x;
    CGFloat originY = _groupView.frame.origin.y;
    CGFloat size_W = _groupView.frame.size.width;
    CGFloat size_H = height;
    //    NSLog(@"X %f,Y %f,W %f,H %f",originX,originY,size_W,size_H);
    _groupView.frame = CGRectMake(originX,originY,size_W,size_H);
    [_groupView setNeedsDisplay];
}

- (void)resetAlbumViewHeight:(CGFloat)height
{
    CGFloat originX = _albumView.frame.origin.x;
    CGFloat originY = _albumView.frame.origin.y;
    CGFloat size_W = _albumView.frame.size.width;
    CGFloat size_H = height;
    //    NSLog(@"X %f,Y %f,W %f,H %f",originX,originY,size_W,size_H);
    _albumView.frame = CGRectMake(originX,originY,size_W,size_H);
    [_albumView setNeedsDisplay];
}

- (void)resetMView:(CGFloat)offsetY
{
    CGFloat originX = _midView.frame.origin.x;
    CGFloat originY = _midView.frame.origin.y;
    CGFloat size_W = _midView.frame.size.width;
    CGFloat size_H = _midView.frame.size.height - offsetY;
//    NSLog(@"X %f,Y %f,W %f,H %f",originX,originY,size_W,size_H);
    _midView.frame = CGRectMake(originX,originY,size_W,size_H);
}

- (void)resetGView:(CGFloat)offsetY
{
    CGFloat originX = _groupView.frame.origin.x;
    CGFloat originY = _groupView.frame.origin.y;
    CGFloat size_W = _groupView.frame.size.width;
    CGFloat size_H = _groupView.frame.size.height - offsetY;
//    NSLog(@"X %f,Y %f,W %f,H %f",originX,originY,size_W,size_H);
    _groupView.frame = CGRectMake(originX,originY,size_W,size_H);
}

- (void)resetAView:(CGFloat)offsetY
{
    CGFloat originX = _albumView.frame.origin.x;
    CGFloat originY = _albumView.frame.origin.y;
    CGFloat size_W = _albumView.frame.size.width;
    CGFloat size_H = _albumView.frame.size.height - offsetY;
//    NSLog(@"offsetY %f X %f,Y %f,W %f,H %f",offsetY,originX,originY,size_W,size_H);
    _albumView.frame = CGRectMake(originX,originY,size_W,size_H);
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
    [IL_DATA addClipURL:_moviePlayer.contentURL];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
