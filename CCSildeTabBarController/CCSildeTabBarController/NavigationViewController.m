//
//  NavigationViewController.m
//  CCSildeTabBarController
//
//  Created by cyd on 2018/9/4.
//  Copyright © 2018 cyd. All rights reserved.
//

#import "NavigationViewController.h"
#import "MainTabBarViewController.h"

@implementation NavigationViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    BOOL ishide = [viewController isKindOfClass: MainTabBarViewController.class];
//    [self setNavigationBarHidden:ishide animated:true];
}

@end
