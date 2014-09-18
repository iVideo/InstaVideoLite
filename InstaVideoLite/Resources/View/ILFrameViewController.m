//
//  ILFrameViewController.m
//  InstaVideoLite
//
//  Created by insta on 9/16/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILFrameViewController.h"
#import "ILFrameViewCell.h"
#import "ILFrameGroupCell.h"
#import "FCFileManager.h"

@interface ILFrameViewController ()
<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,
UITableViewDataSource,UITableViewDelegate>
{
    CGFloat midHeight;
    
    CGPoint originTopViewPoint;
    CGPoint originMidViewPoint;
    
    CGPoint offsetTogglePoint;
    
    int categoryIndex;
    int selectedIndex;
}

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIScrollView *playerView;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) UIButton *btnPlay;

@property (strong, nonatomic) UIView *toggleView;
@property (strong, nonatomic) UIImageView *imgPreview;

@property (strong, nonatomic) UIView *midView;
@property (strong, nonatomic) UITableView *groupView;
@property (strong, nonatomic) UICollectionView *thumbView;

@property (strong, nonatomic) ILNavBarView *navBarView;

@property (strong, nonatomic) NSMutableDictionary *groups; //{dirpath:groupname}

@property (strong, nonatomic) NSMutableArray *images;   //source image
@property (strong, nonatomic) NSMutableArray *thumbs;   //source thumb

@property (strong, nonatomic) NSURL *movieURL;

@end

@implementation ILFrameViewController

- (void)dealloc
{
    _moviePlayer = nil;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMovieNaturalSizeAvailableNotification
                                                  object:_moviePlayer];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initialization];
    [self createTopView];
    [self createPreView];
    [self createMidView];
    [self createNavView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialization
{
    _movieURL = [IL_DATA popURL];
    
    _groups = [[NSMutableDictionary alloc] initWithCapacity:5];
    _images = [[NSMutableArray alloc] initWithCapacity:20];
    _thumbs = [[NSMutableArray alloc] initWithCapacity:20];
    
    NSArray *dirs = [[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:@"RES_FRAME"];
    for (NSString *dir in dirs) {
        if ([FCFileManager isDirectoryItemAtPath:dir]) {
            NSString *groupName = [dir lastPathComponent];
            [_groups setValue:dir forKey:groupName];
        }
    }
    
    selectedIndex = 1;
    categoryIndex = 0;
    
    [self changeCategory];
    
    categoryIndex = 0;
    [self selectTableView];
}


- (void)imgPreviewTaped:(UITapGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:recognizer.view];
    if (CGRectContainsPoint(_btnPlay.frame ,point)) {
        [self btnPlayPressed:_btnPlay];
    }else{
        _btnPlay.hidden = !_btnPlay.hidden;
    }
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)recognizer
{
    switch (recognizer.direction) {
        case UISwipeGestureRecognizerDirectionRight:
            NSLog(@"UISwipeGestureRecognizerDirectionRight");
            selectedIndex += 1;
            [self changePreviewImage];
            break;
            
        case UISwipeGestureRecognizerDirectionLeft:
            NSLog(@"UISwipeGestureRecognizerDirectionLeft");
            selectedIndex -= 1;
            [self changePreviewImage];
            break;
            
        case UISwipeGestureRecognizerDirectionUp:
            NSLog(@"UISwipeGestureRecognizerDirectionUp");
            categoryIndex += 1;
            [self changeCategory];
            break;
            
        case UISwipeGestureRecognizerDirectionDown:
            NSLog(@"UISwipeGestureRecognizerDirectionDown");
            categoryIndex -= 1;
            [self changeCategory];
            break;
            
        default:
            break;
    }
}

- (void)changeCategory
{
    if (categoryIndex < 0) {
        categoryIndex = 0;
        return;
    }
    
    int maxIndex = (int)[_groups count] - 1;
    if (categoryIndex > maxIndex) {
        categoryIndex = maxIndex;
        return;
    }
    
    NSString *groupPath = [[_groups allValues] objectAtIndex:categoryIndex];
    [_images removeAllObjects];
    NSArray *images = [FCFileManager listFilesInDirectoryAtPath:groupPath withExtension:@"png"];
    [_images addObjectsFromArray:images];
    [_thumbs removeAllObjects];
    NSArray *thumbs = [FCFileManager listFilesInDirectoryAtPath:groupPath withExtension:@"jpg"];
    [_thumbs addObjectsFromArray:thumbs];
    
    selectedIndex = 0;
    [self updateThumbView];
    [self selectTableView];
}

- (void)updateThumbView
{
    [_thumbView reloadData];
}

- (void)selectTableView
{
    [UIView animateWithDuration:.5f animations:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:categoryIndex inSection:0];
        [_groupView selectRowAtIndexPath:indexPath animated:NO  scrollPosition:UITableViewScrollPositionTop];
    }];
}

- (void)changePreviewImage
{
    if (selectedIndex < 0) {
        selectedIndex = 0;
        return;
    }
    
    int maxIndex = (int)[_images count] - 1;
    if (selectedIndex > maxIndex) {
        selectedIndex = maxIndex;
        return;
    }
    
    _imgPreview.image = [[UIImage alloc] initWithContentsOfFile:[_images objectAtIndex:selectedIndex]];
    [_imgPreview setNeedsDisplay];
}

#pragma mark - midView

- (void)createMidView
{
    midHeight = IL_SCREEN_H - IL_PLAYER_H - IL_NAVBAR_H;
    _midView = [[UIView alloc] initWithFrame:CGRectMake(.0f, IL_PLAYER_H,IL_SCREEN_W,midHeight)];
    _midView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_midView];
    
    [self createGroupView];
    [self createThumbView];

}

- (void)createGroupView
{
    _groupView = [[UITableView alloc]initWithFrame:CGRectMake(-10.f, .0f, 90.f, midHeight) style:UITableViewStylePlain];
    [_groupView registerClass:[ILFrameGroupCell class] forCellReuseIdentifier:@"ILFrameGroupCell"];
    _groupView.dataSource = self;
    _groupView.delegate = self;
    _groupView.backgroundView = nil;
    _groupView.backgroundColor = [UIColor clearColor];
    [_midView addSubview:_groupView];
}

- (void)createThumbView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(IL_SCREEN_W / 4, IL_SCREEN_W / 4);
    flowLayout.sectionInset = UIEdgeInsetsMake(0,0,0,0);
    flowLayout.minimumLineSpacing = .0f;
    flowLayout.minimumInteritemSpacing = 0.f;
    
    _thumbView = [[UICollectionView alloc] initWithFrame:CGRectMake(80.f, 0, IL_SCREEN_W - 80, midHeight) collectionViewLayout:flowLayout];
    [_thumbView registerClass:[ILFrameViewCell class] forCellWithReuseIdentifier:@"ILFrameViewCell"];
    _thumbView.delegate = self;
    _thumbView.dataSource = self;
    _thumbView.backgroundColor = [UIColor clearColor];
    [_midView addSubview:_thumbView];
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
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ILFrameGroupCell *cell = (ILFrameGroupCell *)[tableView dequeueReusableCellWithIdentifier:@"ILFrameGroupCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.backgroundView = nil;
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.image = [UIImage imageNamed:[[_groups allKeys] objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    categoryIndex = (int)indexPath.row;
    [self changeCategory];
    [self changePreviewImage];
}


#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource & UICollectionViewDelegateFlowLayout

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_thumbs count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ILFrameViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ILFrameViewCell" forIndexPath:indexPath];
    [cell updateCellImage:[[UIImage alloc]initWithContentsOfFile:_thumbs[indexPath.row]]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndex = (int)indexPath.row;
    [self changePreviewImage];
    ILFrameViewCell *cell = (ILFrameViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectedBg.hidden = NO;
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ILFrameViewCell *cell = (ILFrameViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.selectedBg.hidden = YES;
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
    _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:_movieURL];
    [_moviePlayer.view setFrame:CGRectMake(0.f, 0.f, IL_PLAYER_W, IL_PLAYER_H)];
    [_moviePlayer setControlStyle:MPMovieControlStyleNone];
    [_moviePlayer setScalingMode:MPMovieScalingModeAspectFit];
    [_moviePlayer setRepeatMode:MPMovieRepeatModeOne];
    [_moviePlayer setShouldAutoplay:YES];
    [_moviePlayer prepareToPlay];
    
    _playerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.f, 0.f, IL_PLAYER_W, IL_PLAYER_H)];
    [_playerView addSubview:_moviePlayer.view];
    
    [_topView addSubview:_playerView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieNaturalSizeAvailable:) name:MPMovieNaturalSizeAvailableNotification object:_moviePlayer];
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

- (void)createPreView
{
    _imgPreview = [[UIImageView alloc] initWithFrame:CGRectMake(.0f, .0f, IL_PLAYER_W, IL_PLAYER_H)];
    _imgPreview.center = _topView.center;
    [self.view addSubview:_imgPreview];
    
    selectedIndex = 0;
    [self changePreviewImage];
    
    _imgPreview.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgPreviewTaped:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    [_imgPreview addGestureRecognizer:singleTapRecognizer];
    
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [_imgPreview addGestureRecognizer:rightSwipeRecognizer];
    
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [_imgPreview addGestureRecognizer:leftSwipeRecognizer];
    
    UISwipeGestureRecognizer *upSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    upSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [_imgPreview addGestureRecognizer:upSwipeRecognizer];
    
    UISwipeGestureRecognizer *downSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    downSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [_imgPreview addGestureRecognizer:downSwipeRecognizer];
}

- (void)createToggleView
{
    _toggleView = [[UIView alloc] initWithFrame:CGRectMake(.0f, IL_PLAYER_H - IL_COMMON_H, IL_SCREEN_W, IL_COMMON_H)];
    _toggleView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
    [_topView insertSubview:_toggleView aboveSubview:_moviePlayer.view];
    
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
    sender.selected = !sender.selected;
    if (!sender.selected) {
        [_moviePlayer pause];
        return;
    }
    [_moviePlayer play];
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
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
