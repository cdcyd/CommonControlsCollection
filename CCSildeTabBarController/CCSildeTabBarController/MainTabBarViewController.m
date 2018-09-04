//
//  MainTabBarViewController.m
//  CCSildeTabBarController
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "TransitionController.h"
#import "TransitionAnimation.h"
#import "ViewController.h"

@interface MainTabBarViewController ()<UITabBarControllerDelegate>

@property(nonatomic, strong)UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.selectedIndex = 0;
    [self.view addGestureRecognizer:self.panGestureRecognizer];

    NSArray<UIColor *> *colors = @[[UIColor orangeColor], [UIColor redColor], [UIColor blueColor], [UIColor yellowColor], [UIColor purpleColor]];
    NSMutableArray *vcs = [[NSMutableArray alloc] init];
    for (UIColor *color in colors) {
        ViewController *vc = [[ViewController alloc]init];
        vc.view.backgroundColor = color;
        [vcs addObject:vc];
    }
    self.viewControllers = vcs;
    
    for (int i = 0; i < self.tabBar.items.count; i ++) {
        NSDictionary *dic = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.451 green:0.553 blue:0.584 alpha:1.00]};
        NSDictionary *selecteddic = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.384 green:0.808 blue:0.663 alpha:1.00]};
        
        UITabBarItem *item = [self.tabBar.items objectAtIndex:i];
        [item setTitleTextAttributes:dic forState:UIControlStateNormal];
        [item setTitleTextAttributes:selecteddic forState:UIControlStateSelected];
        
        switch (i) {
            case 0:
                item.title = @"壹";
                break;
            case 1:
                item.title = @"贰";
                break;
            case 2:
                item.title = @"叁";
                break;
            case 3:
                item.title = @"肆";
                break;
            case 4:
                item.title = @"伍";
                break;
            default:
                break;
        }
    }
}

- (UIPanGestureRecognizer *)panGestureRecognizer{
    if (_panGestureRecognizer == nil){
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    }
    return _panGestureRecognizer;
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)pan{
    if (self.transitionCoordinator) {
        return;
    }
    
    if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged){
        [self beginInteractiveTransitionIfPossible:pan];
    }
}

- (void)beginInteractiveTransitionIfPossible:(UIPanGestureRecognizer *)sender{
    CGPoint translation = [sender translationInView:self.view];
    if (translation.x > 0.f && self.selectedIndex > 0) {
        self.selectedIndex --;
    } 
    else if (translation.x < 0.f && self.selectedIndex + 1 < self.viewControllers.count) {
        self.selectedIndex ++;
    } 
}

- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    // 打开注释 可以屏蔽点击item时的动画效果
//    if (self.panGestureRecognizer.state == UIGestureRecognizerStateBegan || self.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSArray *viewControllers = tabBarController.viewControllers;
        if ([viewControllers indexOfObject:toVC] > [viewControllers indexOfObject:fromVC]) {
            return [[TransitionAnimation alloc] initWithTargetEdge:UIRectEdgeLeft];
        } 
        else {
            return [[TransitionAnimation alloc] initWithTargetEdge:UIRectEdgeRight];
        }
//    }
//    else{
//        return nil;
//    }
}

- (id<UIViewControllerInteractiveTransitioning>)tabBarController:(UITabBarController *)tabBarController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController{
    if (self.panGestureRecognizer.state == UIGestureRecognizerStateBegan || self.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        return [[TransitionController alloc] initWithGestureRecognizer:self.panGestureRecognizer];
    } 
    else {
        return nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
