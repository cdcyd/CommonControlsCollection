//
//  CCCalendarView.h
//  CCCalendar
//
//  Created by wsk on 2016/11/14.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCChineseCalendar.h"

@protocol CCCalendarViewDelegate <NSObject>

// 当前界面显示的第一个Cell所属的年份
-(void)calendarDidScrollToYear:(NSUInteger )year lunarYear:(NSString *)lunarYear;

@end

@interface CCCalendarView : UIView

@property(nonatomic, readonly)NSArray<NSDate *> *selectedDates;
@property(nonatomic, readonly)NSArray<CCChineseCalendarModel *> *selectedLunarDates;

@property(nonatomic, weak)id<CCCalendarViewDelegate> delegate;
@property(nonatomic, assign)BOOL allowsMultipleSelection;// 是否允许多选

+(instancetype)new  NS_UNAVAILABLE;

-(instancetype)init NS_UNAVAILABLE;

-(instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

@end
