//
//  CCChineseCalendar.h
//  CCCalendar
//
//  Created by wsk on 2016/11/14.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCChineseCalendarModel : NSObject

@property(nonatomic, copy)NSString *year;
@property(nonatomic, copy)NSString *month;
@property(nonatomic, copy)NSString *day;

@end

@interface CCChineseCalendar : NSObject

+(CCChineseCalendarModel *)getChineseCalenderWithDate:(NSDate *)date;

@end

