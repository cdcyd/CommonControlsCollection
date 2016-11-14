//
//  CCCollectionViewCell.h
//  CCCalendar
//
//  Created by wsk on 2016/11/14.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) UILabel* lunarLabel;

@property (nonatomic,strong) UILabel* gregorianLabel;

@property (nonatomic,strong) UIView * backView;

-(void)setContent:(NSDateComponents *)dateComponents;

-(void)setSelected:(BOOL)selected dateComponents:(NSDateComponents *)dateComponents;

@end
