//
//  CCAssetManager.m
//  CCImagePicker
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCAssetManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation CCAssetManager

+(CCAssetManager *)sharedInstance{
    static dispatch_once_t onceToken;
    static CCAssetManager *shared;
    dispatch_once(&onceToken, ^{
        shared = [[CCAssetManager alloc] init];
    });
    return shared;
}

-(NSUInteger)photoCount{
    return self.photoAssets.count;
}

-(UIImage *)photoAtIndex:(NSUInteger)index{
    ALAsset *photoAsset = self.photoAssets[index];
    ALAssetRepresentation *assetRepresentation = [photoAsset defaultRepresentation];
    UIImage *fullScreenImage = [UIImage imageWithCGImage:[assetRepresentation fullScreenImage]
                                                   scale:[assetRepresentation scale]
                                             orientation:UIImageOrientationUp];
    return fullScreenImage;
}


@end
