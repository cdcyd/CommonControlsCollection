//
//  CoverAnimation.m
//  CCInteractiveTransitionAnimation
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CoverAnimation.h"

@implementation CoverAnimation

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
        switch (_direction) {
            case InteractiveCoverDirectionLeftToRight:
                toView.transform = CGAffineTransformMakeTranslation(-toView.bounds.size.width, 0);
                break;
            case InteractiveCoverDirectionRightToLeft:
                toView.transform = CGAffineTransformMakeTranslation(toView.bounds.size.width, 0);
                break;
            case InteractiveCoverDirectionBottomToTop:
                toView.transform = CGAffineTransformMakeTranslation(0, toView.bounds.size.height);
                break;
            case InteractiveCoverDirectionTopToBottom:
                toView.transform = CGAffineTransformMakeTranslation(0, -toView.bounds.size.height);
                break;
            default:
                break;
        }
    }
    else{
        [[transitionContext containerView] bringSubviewToFront:fromView];
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        if (isPush) {
            toView.transform = CGAffineTransformIdentity;
        }
        else{
            switch (_direction) {
                case InteractiveCoverDirectionLeftToRight:
                    fromView.transform = CGAffineTransformMakeTranslation(fromView.bounds.size.width, 0);
                    break;
                case InteractiveCoverDirectionRightToLeft:
                    fromView.transform = CGAffineTransformMakeTranslation(-fromView.bounds.size.width, 0);
                    break;
                case InteractiveCoverDirectionTopToBottom:
                    fromView.transform = CGAffineTransformMakeTranslation(0, fromView.bounds.size.height);
                    break;
                case InteractiveCoverDirectionBottomToTop:
                    fromView.transform = CGAffineTransformMakeTranslation(0, -fromView.bounds.size.height);
                    break;
                default:
                    break;
            }
        }
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}


@end
