//
//  FMAccountUsersAPI.m
//  FruitMix
//
//  Created by wisnuc on 2017/7/25.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMAccountUsersAPI.h"
#import "FMGetUserInfo.h"

@implementation FMAccountUsersAPI
/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}

/// 请求的URL
- (NSString *)requestUrl{
    return  [NSString stringWithFormat:@"users/%@",DEF_UUID];
//    return  @"account";
}


-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}
@end
