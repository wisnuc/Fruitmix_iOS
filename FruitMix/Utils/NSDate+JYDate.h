//
//  NSDate+JYDate.h
//  FruitMix
//
//  Created by 杨勇 on 16/5/9.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (JYDate)

+(NSDate *)getFormatDateWithDate:(NSDate *)date;


+(NSString *)getDateStringWithPhoto:(NSDate *)date;

@end
