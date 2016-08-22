//
//  CCImagePickerViewController.m
//  CCImagePicker
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCImagePickerViewController.h"
#import "CCAlbumViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface CCImagePickerViewController ()<UITableViewDelegate,UITableViewDataSource,CCAlbumViewControllerDelegate>

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groups;

@property(nonatomic, strong)UITableView *tableView;

@end

@implementation CCImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"CDImagePicker";
    
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    self.groups = [NSMutableArray array];
    
    [self.view addSubview:self.tableView];
    [self requestAssetsGroups:^{
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
}

- (void)requestAssetsGroups:(void(^)(void))complete{
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = [NSString stringWithFormat:@"无法访问相册.请在'设置->%@->照片'设置为打开",appName];
                break;
            default:
                errorMessage = @"未知原因，打开相册失败";
                break;
        }
        NSLog(@"%@",errorMessage);
    };
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0){
            [self.groups addObject:group];
        }
        else{
            if (complete) {
                complete();
            }
        }
    };
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:listGroupBlock failureBlock:failureBlock];
}

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor clearColor];
        [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor colorWithRed:0xeb/255.f green:0xf5/255.f blue:0xff/255.f alpha:1]];
    }
    return _tableView;
}

-(void)imagePickerViewControllerFinishClick:(NSArray<UIImage *> *)imageArray{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.groups.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *groupsIdentifier = @"groupsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:groupsIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:groupsIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor colorWithRed:0xeb/255.f green:0xf5/255.f blue:0xff/255.f alpha:1];
        cell.selectedBackgroundView = view;
    }
    ALAssetsGroup *assetsGroup = self.groups[indexPath.section];
    cell.imageView.image = [self coverImageWithAssetGroup:assetsGroup];
    cell.textLabel.text = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"共%ld张",(long)assetsGroup.numberOfAssets]; 
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CCAlbumViewController *vc = [[CCAlbumViewController alloc]init];
    vc.assetsGroup = self.groups[indexPath.section];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(UIImage *)coverImageWithAssetGroup:(ALAssetsGroup *)group{
    CGImageRef coverImageRef = [group posterImage];
    return [UIImage imageWithCGImage:coverImageRef];
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
