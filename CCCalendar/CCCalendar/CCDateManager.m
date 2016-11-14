//
//  CCDateManager.m
//  CCCalendar
//
//  Created by wsk on 2016/11/14.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCDateManager.h"

@implementation CCDateManager

+(NSInteger )numberDaysOfMonth:(NSDate *)date{
    NSCalendar *calender = [NSCalendar currentCalendar];
    return [calender rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
}

+(NSInteger )numberWeeksOfMonth:(NSDate *)date{
    NSCalendar *calender = [NSCalendar currentCalendar];
    return [calender rangeOfUnit:NSCalendarUnitWeekOfMonth inUnit:NSCalendarUnitMonth forDate:date].length;
}

+(BOOL)isToday:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar isDateInToday:date];
}

@end
