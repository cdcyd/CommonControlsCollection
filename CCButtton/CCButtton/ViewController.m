//
//  ViewController.m
//  CCButtton
//
//  Created by wsk on 16/9/18.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "ViewController.h"
#import "CCButton.h"

static UIImage* createImageWithColor(UIColor* color)
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CCButton *button = [CCButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 200, 65);
    [button setTitle:@"wwww" forState:UIControlStateNormal];
    [button setBackgroundImage:createImageWithColor([UIColor redColor]) forState:UIControlStateNormal];
    [button setImage:createImageWithColor([UIColor cyanColor]) forState:UIControlStateNormal];
    [self.view addSubview:button];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
