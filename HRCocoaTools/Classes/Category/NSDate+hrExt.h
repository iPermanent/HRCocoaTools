//
//  NSDate+hrExt.h
//  HRCocoaTools
//
//  Created by ZhangHeng on 2018/1/28.
//

#import <Foundation/Foundation.h>

@interface NSDate (hrExt)

//周均按周日第一天开始算，如果有需要自行添加一天到周一至周日
//获取本周第一天
-(NSDate *)getFirstDayOFcurrentWeek;

//获取本周最后一天
-(NSDate *)getLastDayOfCurrentWeek;

//计算两个时间戳的天数之差
+ (NSUInteger)daysBetweenDate:(NSTimeInterval )fromDateTimeInterval andDate:(NSTimeInterval )toDateTimeInterval;

@end
