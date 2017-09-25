//
//  NSString+Validate.m
//  FruitMix
//
//  Created by wisnuc-imac on 2017/9/25.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "NSString+Validate.h"

@implementation NSString (Validate)
+ (BOOL)isPassword:(NSString *)password
{
    NSString *re = @"[a-zA-Z\u4e00-\u9fa5][a-zA-Z0-9\u4e00-\u9fa5]+";
    NSPredicate *passwordMacth = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", re];
    
    return [passwordMacth evaluateWithObject:password];
}

+ (BOOL)isUserName:(NSString *)usernName
{
    NSString *re = @"[a-zA-Z0-9_]";
    NSPredicate *usernNameMacth = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", re];
    
    return [usernNameMacth evaluateWithObject:usernName];
}

@end
