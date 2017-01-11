//
//  FMGetShareKeyAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/8.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMGetShareKeyAPI.h"

@implementation FMGetShareKeyAPI
/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    return @"mediashare?format=key";
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}
@end
