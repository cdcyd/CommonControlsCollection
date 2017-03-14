//
//  CCImageDetailViewController.m
//  CCImagePicker
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCImageDetailViewController.h"
#import "CCAssetManager.h"

@interface CCImageDetailViewController ()

@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, strong)UIImageView  *imgeView;

@end

@implementation CCImageDetailViewController

- (instancetype)initWithPageIndex:(NSInteger)pageIndex{
    self = [super init];
    if (self != nil){
        _pageIndex = pageIndex;
    }
    return self;
}

+ (CCImageDetailViewController *)previewControllerForPageIndex:(NSUInteger)pageIndex{
    if (pageIndex < [[CCAssetManager sharedInstance] photoCount]) {
        return [[self alloc] initWithPageIndex:pageIndex];
    }
    return nil;
}

-(void)loadView{
    self.view = self.scrollView;
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    _imgeView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    _imgeView.contentMode = UIViewContentModeScaleAspectFit;
    _imgeView.image = [[CCAssetManager sharedInstance] photoAtIndex:_pageIndex];
    [self.view addSubview:_imgeView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.parentViewController.parentViewController.title = [NSString stringWithFormat:@"%@ / %@", [@(self.pageIndex+1) stringValue], [@([[CCAssetManager sharedInstance] photoCount]) stringValue]];
}

-(UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bouncesZoom = YES;
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        _scrollView.backgroundColor = [UIColor blackColor];
    }
    return _scrollView;
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
