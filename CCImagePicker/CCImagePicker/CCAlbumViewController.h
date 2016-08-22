//
//  CCAlbumViewController.h
//  CCImagePicker
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol CCAlbumViewControllerDelegate <NSObject>

-(void)imagePickerViewControllerFinishClick:(NSArray<UIImage *> *)imageArray;

@end


@interface CCAlbumViewController : UIViewController

@property (nonatomic, weak)id <CCAlbumViewControllerDelegate> delegate;

@property (nonatomic, strong)ALAssetsGroup *assetsGroup;

@end
