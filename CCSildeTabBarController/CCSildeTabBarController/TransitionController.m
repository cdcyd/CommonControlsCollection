//
//  TransitionController.m
//  CCSildeTabBarController
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "TransitionController.h"

@interface TransitionController()

@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *gestureRecognizer;

@property (nonatomic, readwrite) CGPoint initialTranslationInContainerView;

@end

@implementation TransitionController

- (instancetype)initWithGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer{
    self = [super init];
    if (self){
        _gestureRecognizer = gestureRecognizer;
        [_gestureRecognizer addTarget:self action:@selector(gestureRecognizeDidUpdate:)];
    }
    return self;
}

- (instancetype)init{
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Use -initWithGestureRecognizer:" userInfo:nil];
}

- (void)dealloc{
    [self.gestureRecognizer removeTarget:self action:@selector(gestureRecognizeDidUpdate:)];
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    self.transitionContext = transitionContext;
    self.initialTranslationInContainerView = [self.gestureRecognizer translationInView:transitionContext.containerView];
    [super startInteractiveTransition:transitionContext];
}

- (CGFloat)percentForGesture:(UIPanGestureRecognizer *)gesture{
    UIView *transitionContainerView = self.transitionContext.containerView;
    CGPoint translation = [gesture translationInView:gesture.view.superview];
    if ((translation.x > 0.f && self.initialTranslationInContainerView.x < 0.f) ||
        (translation.x < 0.f && self.initialTranslationInContainerView.x > 0.f)){
        return -1.f;
    }
    return fabs(translation.x)/CGRectGetWidth(transitionContainerView.bounds);
}

- (void)gestureRecognizeDidUpdate:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
            if ([self percentForGesture:gestureRecognizer] < 0.f) {
                [self cancelInteractiveTransition];
                [self.gestureRecognizer removeTarget:self action:@selector(gestureRecognizeDidUpdate:)];
            } 
            else {
                [self updateInteractiveTransition:[self percentForGesture:gestureRecognizer]];
            }
            break;
        case UIGestureRecognizerStateEnded:
            if ([self percentForGesture:gestureRecognizer] >= 0.4f){
                [self finishInteractiveTransition];
            }
            else{
                [self cancelInteractiveTransition];
            }
            break;
        default:
            [self cancelInteractiveTransition];
            break;
    }
}

@end
