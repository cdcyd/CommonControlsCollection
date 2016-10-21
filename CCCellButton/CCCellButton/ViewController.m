//
//  ViewController.m
//  CCCellButton
//
//  Created by wsk on 2016/10/21.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "ViewController.h"
#import "UIButton+ClickEffect.h"

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
    self.title = @"Button点击效果测试";
    
    self.tableView.delaysContentTouches = NO;
//    for (id view in self.tableView.subviews)
//    {
//        if ([NSStringFromClass([view class]) isEqualToString:@"UITableViewWrapperView"])
//        {
//            if([view isKindOfClass:[UIScrollView class]])
//            {
//                UIScrollView *scroll = (UIScrollView *) view;
//                scroll.delaysContentTouches = NO;
//            }
//            break;
//        }
//    }
//    
//    for (id view in self.tableView.subviews)
//    {
//        if ([NSStringFromClass([view class]) isEqualToString:@"UITableViewCellScrollView"])
//        {
//            if([view isKindOfClass:[UIScrollView class]])
//            {
//                UIScrollView *scroll = (UIScrollView *) view;
//                scroll.delaysContentTouches = NO;
//            }
//            break;
//        }
//    }
    
    for (id obj in self.tableView.subviews) {
        if ([obj respondsToSelector:@selector(setDelaysContentTouches:)]) {
            [obj setDelaysContentTouches:NO];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 60, 30);
        [button setBackgroundImage:createImageWithColor([UIColor blueColor]) forState:UIControlStateNormal];
        [button setBackgroundImage:createImageWithColor([UIColor greenColor]) forState:UIControlStateHighlighted];
        cell.accessoryView = button;
    }
    cell.textLabel.text = @"测试";
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
