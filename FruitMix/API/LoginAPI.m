//
//  LoginAPI.m
//  FruitMix
//
//  Created by wisnuc-imac on 2017/9/26.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "LoginAPI.h"

@implementation LoginAPI
+ (instancetype)apiWithServicePath:(NSString *)servicePath AuthorizationBasic:(NSString *)basic{
    LoginAPI * api = [LoginAPI new];
    api.servicePath = servicePath;
    api.basic = basic;
    return api;
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL

- (NSString *)baseUrl{
    return _servicePath;
}

- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"%@token",_servicePath];
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"Basic %@",_basic] forKey:@"Authorization"];;
    return dic;
}

- (id)responseSerialization{
    return [AFJSONResponseSerializer serializer];
}

-(NSTimeInterval)requestTimeoutInterval{
    return 20;
}

@end
