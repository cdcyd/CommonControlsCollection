//
//  CCCollectionViewCell.m
//  CCCalendar
//
//  Created by wsk on 2016/11/14.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCCollectionViewCell.h"
#import "CCChineseCalendar.h"

@interface CCCollectionViewCell()

@property (nonatomic,strong) UIView* topLineView;

@end

@implementation CCCollectionViewCell

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        
        _backView = [[UIView alloc]initWithFrame:CGRectMake(2, 2, CGRectGetWidth(frame)-4, CGRectGetWidth(frame)-4)];
        _backView.layer.masksToBounds = YES;
        _backView.layer.cornerRadius = _backView.bounds.size.width/2;
        [self.contentView addSubview:_backView];
        
        _topLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 0.6)];
        _topLineView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_topLineView];
        
        _gregorianLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, CGRectGetWidth(frame)-5*2, 25)];
        _gregorianLabel.backgroundColor = [UIColor clearColor];
        _gregorianLabel.textAlignment = NSTextAlignmentCenter;
        _gregorianLabel.font = [UIFont systemFontOfSize:18];
        [self.contentView addSubview:_gregorianLabel];
        
        _lunarLabel = [[UILabel alloc]initWithFrame:CGRectMake(_gregorianLabel.frame.origin.x, CGRectGetMaxY(_gregorianLabel.frame), _gregorianLabel.bounds.size.width, 20)];
        _lunarLabel.backgroundColor = [UIColor clearColor];
        _lunarLabel.font = [UIFont systemFontOfSize:12];
        _lunarLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_lunarLabel];
    }
    return self;
}

-(void)setContent:(NSDateComponents *)dateComponents{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateFromComponents:dateComponents];
    self.lunarLabel.text = [CCChineseCalendar getChineseCalenderWithDate:date].day;
    self.gregorianLabel.text = [NSString stringWithFormat:@"%ld",dateComponents.day];
    
    BOOL isWeekend = [calendar isDateInWeekend:date]; 
    BOOL isToday = [calendar isDateInToday:date];
    
    if (isToday) {
        self.backView.backgroundColor = [UIColor redColor];
        self.lunarLabel.textColor = [UIColor whiteColor];
        self.gregorianLabel.textColor = [UIColor whiteColor];
    }
    else{
        if (isWeekend) {
            self.lunarLabel.textColor = [UIColor lightGrayColor];
            self.gregorianLabel.textColor = [UIColor lightGrayColor];
        }
        else{
            self.lunarLabel.textColor = [UIColor blackColor];
            self.gregorianLabel.textColor = [UIColor blackColor];
        }
    }
}

-(void)setSelected:(BOOL)selected dateComponents:(NSDateComponents *)dateComponents{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateFromComponents:dateComponents];
    BOOL isWeekend = [calendar isDateInWeekend:date];
    BOOL isToday = [calendar isDateInToday:date];
    
    if (selected) {
        self.lunarLabel.textColor = [UIColor whiteColor];
        self.gregorianLabel.textColor = [UIColor whiteColor];
        self.backView.backgroundColor = [UIColor blackColor];
    }
    else{
        if (isToday) {
            self.backView.backgroundColor = [UIColor redColor];
            self.lunarLabel.textColor = [UIColor whiteColor];
            self.gregorianLabel.textColor = [UIColor whiteColor];
            return ;
        }
        
        if (isWeekend) {
            self.lunarLabel.textColor = [UIColor lightGrayColor];
            self.gregorianLabel.textColor = [UIColor lightGrayColor];
            self.backView.backgroundColor = [UIColor clearColor];
        }
        else{
            self.lunarLabel.textColor = [UIColor blackColor];
            self.gregorianLabel.textColor = [UIColor blackColor];
            self.backView.backgroundColor = [UIColor clearColor];
        }
    }
}

@end
