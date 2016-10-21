//
//  UIButton+ClickEffect.m
//  CCCellButton
//
//  Created by wsk on 2016/10/21.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "UIButton+ClickEffect.h"

@implementation UIButton (ClickEffect)

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [NSOperationQueue.mainQueue addOperationWithBlock:^{ self.highlighted = YES;}];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    [self performSelector:@selector(setDefault) withObject:nil afterDelay:0.1];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [self performSelector:@selector(setDefault) withObject:nil afterDelay:0.1];
}

- (void)setDefault
{
    [NSOperationQueue.mainQueue addOperationWithBlock:^{ self.highlighted = NO; }];
}

@end
