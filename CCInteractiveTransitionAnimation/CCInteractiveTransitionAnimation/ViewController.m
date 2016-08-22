//
//  ViewController.m
//  CCInteractiveTransitionAnimation
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *colors = @[[UIColor purpleColor],[UIColor orangeColor],[UIColor brownColor],[UIColor blueColor],[UIColor greenColor],[UIColor yellowColor],[UIColor redColor]];
    self.view.backgroundColor = colors[arc4random()%7];
    
    if(self.titles == 0) {
        self.title = @"首页";
    }
    else{
        self.title = [NSString stringWithFormat:@"第%ld页",(long)self.titles];
    }
    self.titles++;
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    nextButton.frame = CGRectMake(0, 00, 80, 40);
    [nextButton setTitle:@"下一页" forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:nextButton];
}

-(void)buttonClick:(UIButton *)btn{
    ViewController *vc = [[ViewController alloc]init];
    vc.titles = self.titles;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
