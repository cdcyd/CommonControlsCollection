//
//  FlowLayout.m
//  CCCollectionView
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "FlowLayout.h"

@implementation FlowLayout

- (CGSize)collectionViewContentSize{
    // 返回CollertionView的滚动的总大小
    //    CGFloat contentWidth = self.collectionView.bounds.size.width;
    //    CGFloat contentHeight = self.collectionView.bounds.size.height * 10;
    //    CGSize contentSize = CGSizeMake(contentWidth, contentHeight);
    return [self collectionView].frame.size;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // 给出开始的一套布局
    NSMutableArray *layoutAttributes = [NSMutableArray arrayWithCapacity:3];
    NSInteger count = [[self collectionView] numberOfItemsInSection:0];
    for (int i = 0 ; i < count; i ++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [layoutAttributes addObject:attributes];
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    // 返回每个cell的布局
    UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // 圆形布局
    CGSize size = [self collectionView].frame.size;
    NSInteger count = [[self collectionView] numberOfItemsInSection:0];
    CGPoint center = CGPointMake(size.width/2, size.height/2);
    CGFloat radius = MIN(size.width, size.height) / 2.5;
    
    attribute.size = CGSizeMake(50, 50);
    attribute.zIndex = -10 * indexPath.item;
    attribute.center = CGPointMake(center.x + radius * cosf(2 * indexPath.item * M_PI / count), center.y + radius * sinf(2 * indexPath.item * M_PI/count));
    attribute.transform3D = CATransform3DMakeRotation(90 * M_PI / 180 , 1, 1, 1);
    return attribute;
}

//- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
//{
//    // 返回每个补充视图的布局
//    UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];
//    CGFloat totalWidth = [self collectionViewContentSize].width;
//    if ([elementKind isEqualToString:@""]) {
//        CGFloat dayWidth = totalWidth/7;
//        attribute.frame = CGRectMake(dayWidth * indexPath.item, 0, dayWidth, 40);
//        attribute.zIndex = -10;
//    }
//    return attribute;
//}


@end
