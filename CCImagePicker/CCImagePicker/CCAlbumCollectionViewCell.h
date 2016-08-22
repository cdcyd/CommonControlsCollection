//
//  CCAlbumCollectionViewCell.h
//  CCImagePicker
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CDAlbumCollectionViewCell;

@protocol CDAlbumCollectionViewCellDelegate <NSObject>

-(void)selectButtonClick:(CDAlbumCollectionViewCell *)cell;

@end

@interface CDAlbumCollectionViewCell : UICollectionViewCell

@property(nonatomic,weak)id<CDAlbumCollectionViewCellDelegate> delegate;

@property(nonatomic,assign)BOOL select;

@end