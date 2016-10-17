//
//  CCNavigationController.m
//  CCNavigation
//
//  Created by wsk on 2016/10/17.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCNavigationController.h"

@interface CCNavigationController ()

@end

@implementation CCNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.translucent = NO; // 禁用毛玻璃效果
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
