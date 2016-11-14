//
//  CCDateManager.h
//  CCCalendar
//
//  Created by wsk on 2016/11/14.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCDateManager : NSObject

/// 一个月有几天
+(NSInteger )numberDaysOfMonth:(NSDate *)date;

/// 一个月有几个周
+(NSInteger )numberWeeksOfMonth:(NSDate *)date;

/// 是否是今天
+(BOOL )isToday:(NSDate *)date;

@end
