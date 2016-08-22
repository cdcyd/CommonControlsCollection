//
//  ScaleAnimation.m
//  CCInteractiveTransitionAnimation
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "ScaleAnimation.h"

@implementation ScaleAnimation

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [self animateTransition:transitionContext fromVC:fromVC toVC:toVC fromView:fromVC.view toView:toVC.view];
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView{
    [[transitionContext containerView] addSubview:toView];
    
    BOOL isPush = ([toVC.navigationController.viewControllers indexOfObject:toVC] > [fromVC.navigationController.viewControllers indexOfObject:fromVC]);
    
    if (isPush) {
        [[transitionContext containerView] bringSubviewToFront:toView];
        toView.transform = CGAffineTransformMakeScale(0.3, 0.3);
        toView.alpha = 0;
    }
    else{
        [[transitionContext containerView] bringSubviewToFront:fromView];
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        if (isPush) {
            toView.transform = CGAffineTransformIdentity;
            toView.alpha = 1;
        }
        else{
            fromView.transform = CGAffineTransformMakeScale(0.3, 0.3);
            fromView.alpha = 0;
        }
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}


@end
