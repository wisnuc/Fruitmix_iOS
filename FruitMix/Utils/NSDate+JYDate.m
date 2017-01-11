//
//  NSDate+JYDate.m
//  FruitMix
//
//  Created by 杨勇 on 16/5/9.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "NSDate+JYDate.h"

@implementation NSDate (JYDate)
+(NSDate *)getFormatDateWithDate:(NSDate *)date{
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    [formatter1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString * dateString = [formatter1 stringFromDate:date];
    NSDate * dateB = [formatter1 dateFromString:dateString];
    return dateB;
}


+(NSString *)getDateStringWithPhoto:(NSDate *)date{
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy-MM-dd";
    NSString * dateString = [formatter1 stringFromDate:date];
    if (IsEquallString(dateString, @"1970-01-01")) {
        dateString = @"未知时间";
    }
    return dateString;
}

@end
