//
//  CCMonthDataClient.h
//  CCCalendar
//
//  Created by wsk on 2016/11/14.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCMonthDataClient : NSObject

/** 
 * 请求某月之前的月份
 * date: 表示当前的月份
 * count: 需要请求的数量
 *
 * 例如:date:2016.11.14 count:3
 * return @['2016.10.14','2016.9.14','2016.8.14'];
 *
 */
+(NSArray<NSDateComponents *> *)requestMonthBeforeDate:(NSDate *)date count:(NSInteger)count;

/** 
 * 请求某月之后的月份
 * date: 表示当前的月份
 * count: 需要请求的数量
 *
 * 例如:date:2016.11.14 count:3
 * return @['2016.12.14','2017.1.14','2017.2.14'];
 *
 */
+(NSArray<NSDateComponents *> *)requestMonthAfterDate:(NSDate *)date count:(NSInteger)count;

@end
