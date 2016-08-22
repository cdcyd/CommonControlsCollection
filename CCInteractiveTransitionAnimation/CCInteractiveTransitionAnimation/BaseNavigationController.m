//
//  BaseNavigationController.m
//  CCInteractiveTransitionAnimation
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "BaseNavigationController.h"
#import "CoverAnimation.h"
#import "ScaleAnimation.h"

@interface BaseNavigationController ()<UINavigationControllerDelegate>
{
    AnimationController *_navigationTransition;
    CoverAnimation *_coverAnimation;
    ScaleAnimation *_scaleAnimation;
}
@property (nonatomic, assign) BOOL reverse;

@property(nonatomic,assign)InteractiveCoverDirection popDirection;
@property(nonatomic,assign)InteractiveTransitionType interactiveType;
@property(nonatomic,assign)InteractiveCoverDirection pushDirection;

@end

@implementation BaseNavigationController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.delegate = self;
    _navigationTransition = [[AnimationController alloc]init];
    _coverAnimation = [[CoverAnimation alloc]init];
    _scaleAnimation = [[ScaleAnimation alloc]init];
    
    // 设置跳转方式
    self.interactiveType = InteractiveTransitionTypeCover;
    
    // 设置跳转方向 当跳转方式为InteractiveTransitionTypeScale时，该属性无效
    self.pushDirection = InteractiveCoverDirectionTopToBottom;
}

-(void)setPushDirection:(InteractiveCoverDirection)pushDirection
{
    _pushDirection = pushDirection;
    switch (_pushDirection) {
        case InteractiveCoverDirectionBottomToTop:
            _popDirection = InteractiveCoverDirectionTopToBottom;
            break;
        case InteractiveCoverDirectionLeftToRight:
            _popDirection = InteractiveCoverDirectionRightToLeft;
            break;
        case InteractiveCoverDirectionRightToLeft:
            _popDirection = InteractiveCoverDirectionLeftToRight;
            break;
        case InteractiveCoverDirectionTopToBottom:
            _popDirection = InteractiveCoverDirectionBottomToTop;
            break;
        default:
            break;
    }
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    _navigationTransition.interactiveVC = viewController;
    _navigationTransition.interactiveDirection = _popDirection;
    _navigationTransition.interactiveType = _interactiveType;
}

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPop){
        if (_interactiveType == InteractiveTransitionTypeCover) {
            _coverAnimation.direction = _popDirection;
            return _coverAnimation;
        }
        if (_interactiveType == InteractiveTransitionTypeScale) {
            return _scaleAnimation;
        }
    }
    else{
        if (_interactiveType == InteractiveTransitionTypeCover) {
            _coverAnimation.direction = _pushDirection;
            return _coverAnimation;
        }
        if (_interactiveType == InteractiveTransitionTypeScale) {
            return _scaleAnimation;
        }
    }
    return nil;
}

-(id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return _navigationTransition && _navigationTransition.interactioning ? _navigationTransition : nil;
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
