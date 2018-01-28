//
//  NSDate+hrExt.m
//  HRCocoaTools
//
//  Created by ZhangHeng on 2018/1/28.
//

#import "NSDate+hrExt.h"

@implementation NSDate (hrExt)

//获取本周第一天
-(NSDate *)getFirstDayOFcurrentWeek{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents =
    [gregorian components:(NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:today];
    NSInteger weekday = [weekdayComponents weekday];
    
    NSDate *firstDate = [today dateByAddingTimeInterval:60*60*24 * (-weekday+1)];
    
    return firstDate;
}

//获取本周最后一天
-(NSDate *)getLastDayOfCurrentWeek{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents =
    [gregorian components:(NSCalendarUnitDay | NSCalendarUnitWeekday) fromDate:today];
    NSInteger weekday = [weekdayComponents weekday];
    
    NSDate *firstDate = [today dateByAddingTimeInterval:60*60*24 * (7-weekday)];
    
    return firstDate;
}

+ (NSUInteger)daysBetweenDate:(NSTimeInterval )fromDateTimeInterval andDate:(NSTimeInterval )toDateTimeInterval{
    //防止日期起始点,截止时间比初始时间小返回负数的问题
    if(toDateTimeInterval < fromDateTimeInterval){
        int temp = fromDateTimeInterval;
        fromDateTimeInterval = toDateTimeInterval;
        toDateTimeInterval = temp;
    }
    
    NSDate  *fromDateTime = [NSDate dateWithTimeIntervalSince1970:fromDateTimeInterval];
    NSDate  *toDateTime = [NSDate dateWithTimeIntervalSince1970:toDateTimeInterval];
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

@end
