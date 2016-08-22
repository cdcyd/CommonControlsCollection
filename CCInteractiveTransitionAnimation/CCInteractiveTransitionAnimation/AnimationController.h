//
//  AnimationController.h
//  CCInteractiveTransitionAnimation
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimationMacro.h"

@interface AnimationController : UIPercentDrivenInteractiveTransition

@property (nonatomic, assign, readonly) BOOL interactioning;

@property (nonatomic, strong) UIViewController *interactiveVC;
@property (nonatomic, assign) InteractiveTransitionType interactiveType;
@property (nonatomic, assign) InteractiveCoverDirection interactiveDirection;

@end
