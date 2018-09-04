//
//  TransitionAnimation.m
//  CCSildeTabBarController
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "TransitionAnimation.h"

@implementation TransitionAnimation

- (instancetype)initWithTargetEdge:(UIRectEdge)targetEdge{
    self = [self init];
    if (self) {
        _targetEdge = targetEdge;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.35;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    CGRect fromFrame = [transitionContext initialFrameForViewController:fromViewController];
    CGRect toFrame = [transitionContext finalFrameForViewController:toViewController];
    
    CGVector offset;
    if (self.targetEdge == UIRectEdgeLeft){
        offset = CGVectorMake(-1.f, 0.f);
    }
    else if (self.targetEdge == UIRectEdgeRight){
        offset = CGVectorMake(1.f, 0.f);
    }
    else{
        NSAssert(NO, @"targetEdge must be one of UIRectEdgeLeft, or UIRectEdgeRight.");
    }
    
    fromView.frame = fromFrame;
    toView.frame = CGRectOffset(toFrame, 
                                toFrame.size.width * offset.dx * -1,
                                toFrame.size.height * offset.dy * -1);
    
    [transitionContext.containerView addSubview:toView];
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:transitionDuration animations:^{
        fromView.frame = CGRectOffset(fromFrame, 
                                      fromFrame.size.width * offset.dx,
                                      fromFrame.size.height * offset.dy);
        toView.frame = toFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
