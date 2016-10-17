//
//  ViewController.m
//  CCNavigation
//
//  Created by wsk on 2016/10/17.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "ViewController.h"
#import "CCAViewController.h"
#import "CCBViewController.h"
#import "CCCViewController.h"

@interface ViewController ()

@end

static ViewController *shareInstance = nil;

@implementation ViewController

+(ViewController *)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (shareInstance == nil) {
            shareInstance = [[ViewController alloc]init];
        }
    });
    return shareInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CCAViewController *AVC = [[CCAViewController alloc] init];
    [self setupChildViewController:AVC 
                             image:nil 
                          selImage:nil 
                             title:@"消息"];
    
    CCBViewController *BVC = [[CCBViewController alloc] init];
    [self setupChildViewController:BVC 
                             image:nil 
                          selImage:nil 
                             title:@"联系人"];
    
    CCCViewController *CVC = [[CCCViewController alloc] init];
    [self setupChildViewController:CVC 
                             image:nil
                          selImage:nil 
                             title:@"设置"];
}

- (void)setupChildViewController:(UIViewController *)vc image:(UIImage *)image selImage:(UIImage *)selectImage title:(NSString *)title{
    
    vc.tabBarItem.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc.tabBarItem.selectedImage = [selectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];;
    vc.tabBarItem.title = title;
    
    [vc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor]} 
                                 forState:UIControlStateNormal];
    [vc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} 
                                 forState:UIControlStateSelected];
    
    [self addChildViewController:vc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
