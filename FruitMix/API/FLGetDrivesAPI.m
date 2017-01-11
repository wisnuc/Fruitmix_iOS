//
//  FLGetDrivesAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FLGetDrivesAPI.h"

@implementation FLGetDrivesAPI

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    return @"drives";
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}

- (id)responseSerialization{
    return [AFJSONResponseSerializer serializer];
}

@end
