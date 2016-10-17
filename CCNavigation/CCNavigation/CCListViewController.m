//
//  CCListViewController.m
//  CCNavigation
//
//  Created by wsk on 2016/10/17.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCListViewController.h"
#import "CCDetailViewController.h"

@interface CCListViewController ()

@end

@implementation CCListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"联系人列表";
    self.view.backgroundColor = [UIColor grayColor];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CCDetailViewController *DVC = [[CCDetailViewController alloc]init];
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
