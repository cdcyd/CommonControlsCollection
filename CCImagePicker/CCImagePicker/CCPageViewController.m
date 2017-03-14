//
//  CCPageViewController.m
//  CCImagePicker
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCPageViewController.h"
#import "CCImageDetailViewController.h"

@interface CCPageViewController ()<UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController *pageController;

@end

@implementation CCPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSDictionary *options = @{UIPageViewControllerOptionSpineLocationKey:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]};
    self.pageController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                         navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                       options:options];
    self.pageController.dataSource = self;
    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    
    CCImageDetailViewController *startPage = [CCImageDetailViewController previewControllerForPageIndex:self.startingIndex];
    if (startPage) {
        [self.pageController setViewControllers:@[startPage] 
                                      direction:UIPageViewControllerNavigationDirectionForward 
                                       animated:NO 
                                     completion:NULL];
    }
}

#pragma mark - UIPageViewController DataSource
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = ((CCImageDetailViewController *)viewController).pageIndex;
    return [CCImageDetailViewController previewControllerForPageIndex:index - 1];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = ((CCImageDetailViewController *)viewController).pageIndex;
    return [CCImageDetailViewController previewControllerForPageIndex:index + 1];
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
