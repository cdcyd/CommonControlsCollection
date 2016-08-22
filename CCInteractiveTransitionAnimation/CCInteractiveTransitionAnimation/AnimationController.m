//
//  AnimationController.m
//  CCInteractiveTransitionAnimation
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "AnimationController.h"
#import <objc/runtime.h>

const NSString *kpanGestureKey = @"kpanGestureKey";
const NSString *kpinchGestureKey = @"kpinchGestureKey";

@interface AnimationController()

@property (nonatomic, assign, readwrite) BOOL interactioning;
@property (nonatomic, assign) CGFloat  startScale;
@property (nonatomic, assign) BOOL shouldComplete;

@end

@implementation AnimationController

- (CGFloat)completionSpeed
{
    return 1 - self.percentComplete;
}

-(void)setInteractiveVC:(UIViewController *)interactiveVC
{
    _interactiveVC = interactiveVC;
}

-(void)setInteractiveType:(InteractiveTransitionType)interactiveType
{
    _interactiveType = interactiveType;
    [self addGestureToViewController];
}

-(void)setInteractiveDirection:(InteractiveCoverDirection)interactiveDirection
{
    _interactiveDirection = interactiveDirection;
}

// 添加手势
- (void)addGestureToViewController{
    switch (self.interactiveType) {
        case InteractiveTransitionTypeCover:
        {
            UIPanGestureRecognizer *gesture = objc_getAssociatedObject(self.interactiveVC.view, (__bridge const void *)(kpanGestureKey));
            if (gesture) {
                [self.interactiveVC.view removeGestureRecognizer:gesture];
            }
            gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
            [self.interactiveVC.view addGestureRecognizer:gesture];
            objc_setAssociatedObject(self.interactiveVC.view, (__bridge const void *)(kpanGestureKey), gesture,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
            break;
        case InteractiveTransitionTypeScale:
        {
            UIPinchGestureRecognizer *gesture = objc_getAssociatedObject(self.interactiveVC.view, (__bridge const void *)(kpinchGestureKey));
            if (gesture) {
                [self.interactiveVC.view removeGestureRecognizer:gesture];
            }
            gesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
            [self.interactiveVC.view addGestureRecognizer:gesture];
            objc_setAssociatedObject(self.interactiveVC.view, (__bridge const void *)(kpinchGestureKey), gesture,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
            break;
        default:
            break;
    }
}

// pan手势
-(void)handlePanGesture:(UIPanGestureRecognizer *)pan{
    CGPoint translation = [pan translationInView:pan.view.superview];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.interactioning = YES;
            [self.interactiveVC.navigationController popViewControllerAnimated:YES];
            break;
        case UIGestureRecognizerStateChanged:
            [self panGestureStateChanged:translation];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            self.interactioning = NO;
            if (!self.shouldComplete || pan.state == UIGestureRecognizerStateCancelled) { 
                [self cancelInteractiveTransition]; 
            } else { 
                [self finishInteractiveTransition]; 
            }
            break;
        default:
            break;
    }
}

-(void)panGestureStateChanged:(CGPoint)point{
    switch (self.interactiveDirection) {
        case InteractiveCoverDirectionBottomToTop:
        {
            if (point.y > 0) {
                return;
            }
            CGFloat fraction = fabs(point.y) / [[UIScreen mainScreen] bounds].size.height; 
            fraction = fminf(fmaxf(fraction, 0.0), 1.0); 
            self.shouldComplete = (fraction > 0.5); 
            [self updateInteractiveTransition:fraction];
        }
            break;
        case InteractiveCoverDirectionLeftToRight:
        {
            CGFloat fraction = point.x / [[UIScreen mainScreen] bounds].size.width; 
            fraction = fminf(fmaxf(fraction, 0.0), 1.0); 
            self.shouldComplete = (fraction > 0.5); 
            [self updateInteractiveTransition:fraction];
        }
            break;
        case InteractiveCoverDirectionRightToLeft:
        {
            if (point.x > 0) {
                return;
            }
            CGFloat fraction = fabs(point.x) / [[UIScreen mainScreen] bounds].size.width; 
            fraction = fminf(fmaxf(fraction, 0.0), 1.0); 
            self.shouldComplete = (fraction > 0.5); 
            [self updateInteractiveTransition:fraction];
        }
            break;
        case InteractiveCoverDirectionTopToBottom:
        {
            CGFloat fraction = point.y / [[UIScreen mainScreen] bounds].size.height; 
            fraction = fminf(fmaxf(fraction, 0.0), 1.0); 
            self.shouldComplete = (fraction > 0.5); 
            [self updateInteractiveTransition:fraction];
        }
            break;
        default:
            break;
    }
}

// pinch手势
-(void)handlePinchGesture:(UIPinchGestureRecognizer *)pinch{
    switch (pinch.state) {
        case UIGestureRecognizerStateBegan:
            self.interactioning = YES;
            self.startScale = pinch.scale;
            [self.interactiveVC.navigationController popViewControllerAnimated:YES];
            break;
        case UIGestureRecognizerStateChanged:
            [self pinchGestureStateChanged:pinch.scale];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            self.interactioning = NO;
            if (!self.shouldComplete || pinch.state == UIGestureRecognizerStateCancelled) { 
                [self cancelInteractiveTransition]; 
            } else { 
                [self finishInteractiveTransition]; 
            }
            break;
        default:
            break;
    }
}

-(void)pinchGestureStateChanged:(CGFloat)scale{
    CGFloat fraction = 1.0 - scale / self.startScale;
    self.shouldComplete = (fraction > 0.5);
    [self updateInteractiveTransition:fraction];
}

@end
