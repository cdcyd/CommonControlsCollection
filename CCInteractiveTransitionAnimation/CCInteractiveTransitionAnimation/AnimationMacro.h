//
//  AnimationMacro.h
//  CCInteractiveTransitionAnimation
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#ifndef AnimationMacro_h
#define AnimationMacro_h

typedef NS_ENUM(NSInteger,InteractiveTransitionType){
    InteractiveTransitionTypeCover, //defualt
    InteractiveTransitionTypeScale
};

typedef NS_ENUM(NSInteger,InteractiveCoverDirection) {
    InteractiveCoverDirectionRightToLeft, //defualt
    InteractiveCoverDirectionLeftToRight,
    InteractiveCoverDirectionTopToBottom,
    InteractiveCoverDirectionBottomToTop
};

#endif /* AnimationMacro_h */
