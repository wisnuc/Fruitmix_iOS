//
//  WeChetLoginAPI.m
//  FruitMix
//
//  Created by wisnuc-imac on 2017/9/26.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "WeChetLoginAPI.h"

@implementation WeChetLoginAPI
+ (instancetype)apiWithCode:(NSString *)code{
    WeChetLoginAPI * api = [WeChetLoginAPI new];
    api.code = code;
//    api.basic = basic;
    return api;
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL

- (NSString *)baseUrl{
    return WX_BASE_URL;
}

- (NSString *)requestUrl{
   return [NSString stringWithFormat:@"token"];
}


- (id)responseSerialization{
    return [AFJSONResponseSerializer serializer];
}

- (id)requestArgument{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:_code forKey:@"code"];
    [dic setObject:@"mobile" forKey:@"platform"];
    return dic;
}

-(NSTimeInterval)requestTimeoutInterval{
    return 20;
}
@end
