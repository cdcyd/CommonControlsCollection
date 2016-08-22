//
//  CCAssetManager.h
//  CCImagePicker
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CCAssetManager : NSObject

@property (nonatomic, strong) NSArray *photoAssets;

+ (CCAssetManager *)sharedInstance;

- (NSUInteger)photoCount;

- (UIImage *)photoAtIndex:(NSUInteger)index;

@end
