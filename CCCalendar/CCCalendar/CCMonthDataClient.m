//
//  CCMonthDataClient.m
//  CCCalendar
//
//  Created by wsk on 2016/11/14.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCMonthDataClient.h"

@implementation CCMonthDataClient

+(NSArray<NSDateComponents *> *)requestMonthBeforeDate:(NSDate *)date count:(NSInteger)count{
    NSMutableArray *temp = [NSMutableArray array];
    NSCalendar *calender = [NSCalendar currentCalendar];
    for (int i = (int)count; i > 0; --i) {
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setMonth:-i];
        NSDate *resultDate = [calender dateByAddingComponents:components toDate:date options:0];
        NSCalendarUnit unit = NSCalendarUnitYear    | 
                              NSCalendarUnitDay     | 
                              NSCalendarUnitMonth   | 
                              NSCalendarUnitWeekday | 
                              NSCalendarUnitCalendar;
        NSDateComponents *dateComponent = [calender components:unit fromDate:resultDate];
        [temp addObject:dateComponent];
    }
    return temp;
}

+(NSArray<NSDateComponents *> *)requestMonthAfterDate:(NSDate *)date count:(NSInteger)count{
    NSMutableArray *temp = [NSMutableArray array];
    NSCalendar *calender = [NSCalendar currentCalendar];
    for (int i = 0; i < count; i++) {
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setMonth:i+1];
        NSDate *resultDate = [calender dateByAddingComponents:components toDate:date options:0];
        NSCalendarUnit unit = NSCalendarUnitYear    | 
                              NSCalendarUnitDay     | 
                              NSCalendarUnitMonth   | 
                              NSCalendarUnitWeekday | 
                              NSCalendarUnitCalendar;
        NSDateComponents *dateComponent = [calender components:unit fromDate:resultDate];
        [temp addObject:dateComponent];
    }
    return temp;
}

@end
