//
//  CCAlbumCollectionViewCell.m
//  CCImagePicker
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCAlbumCollectionViewCell.h"

@interface CDAlbumCollectionViewCell()
{
    UIButton *_selectButton;
}
@end

@implementation CDAlbumCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectButton.frame = CGRectMake(frame.size.width-20, frame.size.height-20, 20, 20);
        [_selectButton setImage:[UIImage imageNamed:@"ico_未选中"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"ico_选中"] forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_selectButton];
    }
    return self;
}

-(void)setSelect:(BOOL)select{
    _selectButton.selected = select;
    _select = select;
}

-(void)selectAction:(UIButton *)btn{
    if (_delegate && [_delegate respondsToSelector:@selector(selectButtonClick:)]) {
        [_delegate selectButtonClick:self];
    }
}

@end
