//
//  CoverAnimation.h
//  CCInteractiveTransitionAnimation
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "AnimationMacro.h"

@interface CoverAnimation : NSObject<UIViewControllerAnimatedTransitioning>

@property(nonatomic, assign) InteractiveCoverDirection direction;

@end
