//
//  ILShareViewController.m
//  InstaVideoLite
//
//  Created by insta on 9/17/14.
//  Copyright (c) 2014 Imagelet Labs. All rights reserved.
//

#import "ILShareViewController.h"

@interface ILShareViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
- (IBAction)btnCancelPressed:(id)sender;

@end

@implementation ILShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)btnCancelPressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end