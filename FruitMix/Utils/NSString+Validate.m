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
    NSString *re = @"^[A-Za-z0-9]+|[_\?`~@#\".\\-!'\\[\\]()]{1,30}$";
    NSPredicate *passwordMacth = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", re];
    
    return [passwordMacth evaluateWithObject:password];
}

+ (BOOL)isUserName:(NSString *)usernName
{
    NSString *re = @"[a-zA-Z0-9_\?`~@#\".\\-!'\\[\\]()\u4e00-\u9fa5]+$";
    NSString *re2 = @"^[-.]";
    NSPredicate *usernNameMacth = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", re];
    NSPredicate *usernNameMacth2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", re2];
    return [usernNameMacth evaluateWithObject:usernName] && [usernNameMacth2 evaluateWithObject:usernName];
}

@end
