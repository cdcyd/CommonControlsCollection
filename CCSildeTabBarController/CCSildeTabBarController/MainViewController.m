//
//  MainViewController.m
//  CCSildeTabBarController
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "MainViewController.h"
#import "TransitionAnimation.h"
#import "TransitionController.h"

#import "壹ViewController.h"
#import "贰ViewController.h"
#import "叁ViewController.h"
#import "肆ViewController.h"
#import "伍ViewController.h"

@interface MainViewController ()<UITabBarControllerDelegate>

@property(nonatomic ,strong)UITabBarController *tabbarController;
@property(nonatomic, strong)UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    [self addChildViewController:self.tabbarController];
    [self.view addSubview:self.tabbarController.view];
}

- (UITabBarController *)tabbarController{
    if (_tabbarController == nil) {
        _tabbarController = [[UITabBarController alloc]init];
        _tabbarController.delegate = self;
        _tabbarController.selectedIndex = 0;
        [_tabbarController.view addGestureRecognizer:self.panGestureRecognizer];
        壹ViewController *vc1 = [[壹ViewController alloc]init];
        贰ViewController *vc2 = [[贰ViewController alloc]init];
        叁ViewController *vc3 = [[叁ViewController alloc]init];
        肆ViewController *vc4 = [[肆ViewController alloc]init];
        伍ViewController *vc5 = [[伍ViewController alloc]init];
        _tabbarController.viewControllers = @[vc1,vc2,vc3,vc4,vc5];
        
        for (int i = 0; i < self.tabbarController.tabBar.items.count; i ++) {
            NSDictionary *dic = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.451 green:0.553 blue:0.584 alpha:1.00]};
            NSDictionary *selecteddic = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.384 green:0.808 blue:0.663 alpha:1.00]};
            
            UITabBarItem *item = [self.tabbarController.tabBar.items objectAtIndex:i];
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
    return _tabbarController;
}

- (UIPanGestureRecognizer *)panGestureRecognizer{
    if (_panGestureRecognizer == nil){
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    }
    return _panGestureRecognizer;
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)pan{
    if (self.tabbarController.transitionCoordinator) {
        return;
    }
    
    if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged){
        [self beginInteractiveTransitionIfPossible:pan];
    }
}

- (void)beginInteractiveTransitionIfPossible:(UIPanGestureRecognizer *)sender{
    CGPoint translation = [sender translationInView:self.tabbarController.view];
    if (translation.x > 0.f && self.tabbarController.selectedIndex > 0) {
        self.tabbarController.selectedIndex --;
    } 
    else if (translation.x < 0.f && self.tabbarController.selectedIndex + 1 < self.tabbarController.viewControllers.count) {
        self.tabbarController.selectedIndex ++;
    } 
    else {
        if (!CGPointEqualToPoint(translation, CGPointZero)) {
            sender.enabled = NO;
            sender.enabled = YES;
        }
    }
    
    [self.tabbarController.transitionCoordinator animateAlongsideTransitionInView:self.tabbarController.view animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if ([context isCancelled] && sender.state == UIGestureRecognizerStateChanged){
            [self beginInteractiveTransitionIfPossible:sender];
        }
    }];
}

- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    NSArray *viewControllers = tabBarController.viewControllers;
    if ([viewControllers indexOfObject:toVC] > [viewControllers indexOfObject:fromVC]) {
        return [[TransitionAnimation alloc] initWithTargetEdge:UIRectEdgeLeft];
    } 
    else {
        return [[TransitionAnimation alloc] initWithTargetEdge:UIRectEdgeRight];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
