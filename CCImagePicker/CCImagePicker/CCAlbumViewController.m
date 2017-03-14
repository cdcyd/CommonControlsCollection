//
//  CCAlbumViewController.m
//  CCImagePicker
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCAlbumViewController.h"
#import "CCAlbumCollectionViewCell.h"
#import "CCPageViewController.h"
#import "CCAssetManager.h"

@interface CCAlbumViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,CDAlbumCollectionViewCellDelegate>
@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, strong)UIView *bottomView;
@property(nonatomic, strong)UILabel *selectNumLabel;

@property(nonatomic, strong)NSMutableArray *assets;
@property(nonatomic, strong)NSMutableDictionary *selectImages;

@end

@implementation CCAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.assets = [NSMutableArray array];
    self.selectImages = [NSMutableDictionary dictionary];
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottomView];
    [self requestAlbumImages:^{
        [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
}

static NSString *assetsIdentifier = @"assetsCell";
-(UICollectionView *)collectionView{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.itemSize = CGSizeMake(self.view.bounds.size.width/4-10, self.view.bounds.size.width/4-10);
        flowLayout.minimumLineSpacing = 10;
        flowLayout.minimumInteritemSpacing = 5;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 50 - 64) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[CDAlbumCollectionViewCell class] forCellWithReuseIdentifier:assetsIdentifier];
    }
    return _collectionView;
}

-(UIView *)bottomView{
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-50-64, self.view.bounds.size.width, 100)];
        _bottomView.backgroundColor = [UIColor colorWithRed:192/255.f green:217/255.f blue:227/255.f alpha:1];
        
        _selectNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 200, 30)];
        _selectNumLabel.textColor = [UIColor blackColor];
        [_bottomView addSubview:_selectNumLabel];
        
        UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sureBtn.frame = CGRectMake(self.view.bounds.size.width-95, 10, 80, 30);
        sureBtn.layer.masksToBounds = YES;
        sureBtn.layer.cornerRadius = 15;
        sureBtn.backgroundColor = [UIColor whiteColor];
        [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
        [sureBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [sureBtn addTarget:self action:@selector(finishedSelectedImage:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:sureBtn];
    }
    return _bottomView;
}

- (void)requestAlbumImages:(void(^)(void))complete{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                [self.assets addObject:result];
            }
            if (index == self.assetsGroup.numberOfAssets - 1 && complete) {
                complete();
            }
        };
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [self.assetsGroup setAssetsFilter:onlyPhotosFilter];
        [self.assetsGroup enumerateAssetsUsingBlock:assetsEnumerationBlock];
    });
}

-(void)finishedSelectedImage:(UIButton *)btn{
    if ([[self.selectImages allValues] count] <= 0) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(imagePickerViewControllerFinishClick:)]) {
        NSMutableArray *images = [NSMutableArray array];
        for (ALAsset *asset in [self.selectImages allValues]) {
            ALAssetRepresentation *representation = [asset defaultRepresentation];
            UIImage *image = [UIImage imageWithCGImage:[representation fullScreenImage]
                                                 scale:[representation scale]
                                           orientation:UIImageOrientationUp];
            [images addObject:image];
        }
        [_delegate imagePickerViewControllerFinishClick:images];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.assets.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CDAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:assetsIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    ALAsset *asset = self.assets[indexPath.row];
    cell.contentView.layer.contents = (__bridge id _Nullable)([asset thumbnail]);
    self.selectImages[[self getAssetFilename:asset]]?(cell.select = YES) : (cell.select = NO);
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [CCAssetManager sharedInstance].photoAssets = self.assets;
    CCPageViewController *vc = [[CCPageViewController alloc]init];
    vc.startingIndex = indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)selectButtonClick:(CDAlbumCollectionViewCell *)cell{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    ALAsset *asset = self.assets[indexPath.row];
    if (cell.select) {
        [self.selectImages removeObjectForKey:[self getAssetFilename:asset]];
    }
    else{
        [self.selectImages setObject:asset forKey:[self getAssetFilename:asset]];
    }
    [cell setSelect:!cell.select];
    
    if ([[self.selectImages allKeys] count]>0) {
        self.selectNumLabel.text = [NSString stringWithFormat:@"共选择:%lu张图片",(unsigned long)[[self.selectImages allKeys] count]];
    }
    else{
        self.selectNumLabel.text = @"";
    }
}

-(NSString *)getAssetFilename:(ALAsset *)asset{
    ALAssetRepresentation* representation = [asset defaultRepresentation];
    return [representation filename];
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
