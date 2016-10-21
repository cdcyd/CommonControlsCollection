//
//  CCDetailViewController.m
//  CCNavigation
//
//  Created by wsk on 2016/10/17.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCDetailViewController.h"

@interface CCDetailViewController ()

@end

@implementation CCDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"聊天界面";
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[ViewController sharedInstance] setSelectedIndex:0];
    [self.navigationController setViewControllers:@[[ViewController sharedInstance],self]];
}

-(void)backClick:(UIButton *)btn{
    [self.navigationController popToRootViewControllerAnimated:YES];
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

@end
