//
//  CCCollectionHeaderView.m
//  CCCalendar
//
//  Created by wsk on 2016/11/14.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCCollectionHeaderView.h"

@implementation CCCollectionHeaderView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        _titleLabel = [[UILabel alloc]initWithFrame:self.bounds];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_titleLabel];
    }
    return self;
}

@end
