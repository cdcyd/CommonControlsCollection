//
//  CCChineseCalendar.m
//  CCCalendar
//
//  Created by wsk on 2016/11/14.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCChineseCalendar.h"

@implementation CCChineseCalendarModel

-(NSString *)description{
    return [NSString stringWithFormat:@"year:%@, month:%@, day: %@",self.year,self.month,self.day];
}

@end

@implementation CCChineseCalendar

static NSArray *chineseYears;
static NSArray *chineseMonths;
static NSArray *chineseDays;

+(CCChineseCalendarModel *)getChineseCalenderWithDate:(NSDate *)date{
    chineseYears =@[@"甲子", @"乙丑", @"丙寅", @"丁卯", @"戊辰", @"己巳", @"庚午", @"辛未", @"壬申", @"癸酉",
                    @"甲戌", @"乙亥", @"丙子", @"丁丑", @"戊寅", @"己卯", @"庚辰", @"辛己", @"壬午", @"癸未",
                    @"甲申", @"乙酉", @"丙戌", @"丁亥", @"戊子", @"己丑", @"庚寅", @"辛卯", @"壬辰", @"癸巳",
                    @"甲午", @"乙未", @"丙申", @"丁酉", @"戊戌", @"己亥", @"庚子", @"辛丑", @"壬寅", @"癸丑",
                    @"甲辰", @"乙巳", @"丙午", @"丁未", @"戊申", @"己酉", @"庚戌", @"辛亥", @"壬子", @"癸丑",
                    @"甲寅", @"乙卯", @"丙辰", @"丁巳", @"戊午", @"己未", @"庚申", @"辛酉", @"壬戌", @"癸亥", ];
    
    chineseMonths=@[@"正月", @"二月", @"三月", @"四月", @"五月", @"六月", 
                    @"七月", @"八月", @"九月", @"十月", @"冬月", @"腊月"];
    
    chineseDays = @[@"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
                    @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
                    @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十"];
    
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:date];
    
    CCChineseCalendarModel *model = [[CCChineseCalendarModel alloc]init];
    if (localeComp.year <= chineseYears.count && localeComp.month <= chineseMonths.count && localeComp.day <= chineseDays.count) {
        model.year = [chineseYears objectAtIndex:localeComp.year-1];
        model.month = [chineseMonths objectAtIndex:localeComp.month-1];
        model.day = [[chineseDays objectAtIndex:localeComp.day-1] isEqualToString:@"初一"]?[chineseMonths objectAtIndex:localeComp.month-1]:[chineseDays objectAtIndex:localeComp.day-1];
    }
    
    return model;
}

@end
