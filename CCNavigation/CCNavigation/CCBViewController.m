//
//  CCBViewController.m
//  CCNavigation
//
//  Created by wsk on 2016/10/17.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCBViewController.h"
#import "CCListViewController.h"

@interface CCBViewController ()

@end

@implementation CCBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [ViewController sharedInstance].title = @"联系人";
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CCListViewController *DVC = [[CCListViewController alloc]init];
    [self.navigationController pushViewController:DVC animated:YES];
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
