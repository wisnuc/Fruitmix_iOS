//
//  FMGetJWTAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/20.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMGetJWTAPI.h"

@implementation FMGetJWTAPI

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    return @"token";
}
-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSString * UUID = [NSString stringWithFormat:@"%@:%@",_model.uuid,_passWord];
    NSString * Basic = [UUID base64EncodedString];
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"Basic %@",Basic] forKey:@"Authorization"];
    return dic;
}
@end
