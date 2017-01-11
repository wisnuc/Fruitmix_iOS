//
//  FLGetSharedWithMeAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/10/9.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FLGetSharedWithMeAPI.h"

@implementation FLGetSharedWithMeAPI

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    return @"share/sharedWithMe";
}
-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}

@end
