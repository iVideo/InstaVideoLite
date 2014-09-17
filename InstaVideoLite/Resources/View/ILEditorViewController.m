//
//  ILEditorViewController.m
//  InstaVideoLite
//
//  Created by insta on 9/11/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILEditorViewController.h"
#import "ILNavBarView.h"
#import "ILClipDockView.h"
#import "ILPlayerManager.h"
#import "ILAlbumManager.h"

#define DOCK_H 72.0f
#define DOCK_W 72.0f

@interface ILEditorViewController ()
{
    NSInteger currentIndex;
}

@property (strong, nonatomic) ILNavBarView *navBarView;

@property (strong, nonatomic) ILPlayerView *playerView;
@property (strong, nonatomic) UIView *editorBar;
@property (strong, nonatomic) UIButton *btnPlay;
@property (strong, nonatomic) ILClipDockView *clipDock;
@property (strong, nonatomic) UIButton *btnAdd;

@end

@implementation ILEditorViewController

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        
//    }
//    return self;
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initializeClipDock];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self initialization];
    [self createPlayerView];
    [self createEditorBar];
    [self createNavView];
    [self createAddButon];
    [self createClipDock];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)initialization
{
    [IL_ALBUM updateAssets];
}

- (void)initializeClipDock
{
    [_clipDock initialize];
}

//TODO: Testing Code
//- (void)test
//{
//    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"jerryfish" ofType:@"m4v"];
//    [DATASTORE addMovieClip:[AVAsset assetWithURL:[[NSURL alloc]initFileURLWithPath:path1]] atIndex:currentIndex];
//    currentIndex += 1;
    
//    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"skateboarding" ofType:@"m4v"];
//    [DATASTORE addMovieClip:[AVAsset assetWithURL:[[NSURL alloc]initFileURLWithPath:path2]] atIndex:currentIndex];
//    currentIndex += 1;
//}

# pragma mark - UI Initialization

- (void)createEditorBar
{
    CGFloat editorBarHeight = IL_SCREEN_H - IL_PLAYER_H - DOCK_H - IL_NAVBAR_H;
    CGRect editorBarFrame =
    CGRectMake(0, IL_PLAYER_H + DOCK_H,IL_SCREEN_W, editorBarHeight);
    _editorBar = [[UIView alloc] initWithFrame:editorBarFrame];
    _editorBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bk_bar"]];
    
    CGRect btnDelFrame = CGRectMake(1 * (editorBarFrame.size.width/4 - 15), editorBarHeight/2 -15, 30, 30);
    UIButton *btnDel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDel setFrame:btnDelFrame];
    [btnDel setImage:[UIImage imageNamed:@"compose_delete"] forState:UIControlStateNormal];
    [btnDel addTarget:self action:@selector(btnDelPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_editorBar addSubview:btnDel];
    
    CGRect btnTrimFrame = CGRectMake(2 * (editorBarFrame.size.width/4 - 15), editorBarHeight/2 -15, 30, 30);
    UIButton *btnTrim = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnTrim setFrame:btnTrimFrame];
    [btnTrim setImage:[UIImage imageNamed:@"compose_crop"] forState:UIControlStateNormal];
    [btnTrim addTarget:self action:@selector(btnTrimPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_editorBar addSubview:btnTrim];
    
    CGRect btnFxFrame = CGRectMake(3 * (editorBarFrame.size.width/4 - 15), editorBarHeight/2 -15, 30, 30);
    UIButton *btnFx = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnFx setFrame:btnFxFrame];
    [btnFx setImage:[UIImage imageNamed:@"compose_fx"] forState:UIControlStateNormal];
    [btnFx addTarget:self action:@selector(btnFxPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_editorBar addSubview:btnFx];
    
    [self.view addSubview:_editorBar];
}

- (void)btnDelPressed:(UIButton *)sender
{
    
}

- (void)btnTrimPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"timespan" sender:self];
}

- (void)btnFxPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"frame" sender:self];
    
}

- (void)createPlayerView
{
    _playerView = [[ILPlayerView alloc] initWithFrame:CGRectMake(0, 0,IL_PLAYER_W, IL_PLAYER_H)];
    [_playerView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_playerView];
    
    CGRect btnPlayFrame = CGRectMake(IL_PLAYER_W/2 - 35, IL_PLAYER_H/2, 70, 70);
    _btnPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnPlay setFrame:btnPlayFrame];
    [_btnPlay setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [_btnPlay setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateHighlighted];
    [_btnPlay addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
    [_playerView addSubview:_btnPlay];
    _btnPlay.center = _playerView.center;
    
    [PLAYER setPlayerItemWithAssets:[DATASTORE getMovieClips]];
    [self.playerView.playerLayer setPlayer:PLAYER.queuePlayer];
    
    currentIndex = 0;
    
    [PLAYER play];
    _btnPlay.selected = YES;

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

- (void)createClipDock
{
    CGRect clipDockFrame = CGRectMake(0, IL_PLAYER_H, IL_SCREEN_W - DOCK_H , DOCK_H);
    _clipDock = [[ILClipDockView alloc] initWithFrame:clipDockFrame];
    [self.view addSubview:_clipDock] ;
}
- (void)btnPlayPressed:(UIButton *)sender
{
    NSLog(@"%ld",(long)sender.tag);
}

- (void)createAddButon
{
    CGRect btnAddFrame = CGRectMake(IL_SCREEN_W - DOCK_H, IL_PLAYER_H, DOCK_H, DOCK_H);
    _btnAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnAdd.backgroundColor = [UIColor grayColor];
    [_btnAdd setFrame:btnAddFrame];
    [_btnAdd setImage:[UIImage imageNamed:@"add_video.png"] forState:UIControlStateNormal];
    [_btnAdd addTarget:self action:@selector(addClip:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnAdd];
}

- (void)addClip:(UIButton *)sender
{
    [PLAYER pause];
//    [self test];
//    [_clipDock addLastAsset];
//    [self select:sender];
    [self album:sender];
    
}

- (void)createNavView
{
    _navBarView = [[ILNavBarView alloc] initWithFrame:CGRectMake(0, IL_SCREEN_H - 44, IL_SCREEN_W, 44)];
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
    [self performSegueWithIdentifier:@"compose" sender:self];
}

- (void)album:(id)sender
{
    [self performSegueWithIdentifier:@"album" sender:self];
}

- (void)select:(id)sender
{
    [self performSegueWithIdentifier:@"select" sender:self];
}

- (void)compose:(id)sender
{
    [self performSegueWithIdentifier:@"compose" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
