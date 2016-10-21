//
//  CCBaseViewController.m
//  CCNavigation
//
//  Created by wsk on 2016/10/17.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCBaseViewController.h"

@interface CCBaseViewController ()

@end

@implementation CCBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1) {
        [self setupBackButton];
    }
}

-(void)setupBackButton{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 60, 30);
    [btn setTitle:@" 返回" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [btn setImage:[UIImage imageNamed:@"back_yellow"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = item;
}

-(void)backClick:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
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
