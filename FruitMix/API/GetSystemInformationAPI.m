//
//  GetSystemInformationAPI.m
//  FruitMix
//
//  Created by wisnuc-imac on 2017/10/23.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "GetSystemInformationAPI.h"

@implementation GetSystemInformationAPI
+ (instancetype)apiWithServicePath:(NSString *)servicePath{
    GetSystemInformationAPI * api = [GetSystemInformationAPI new];
    api.servicePath = servicePath;
    return api;
}

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}

- (NSString *)baseUrl{
    return _servicePath;
}
/// 请求的URL
- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"%@control/system",_servicePath];
}
@end
