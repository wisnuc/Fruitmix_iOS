//
//  GetStaionInfoAPI.m
//  FruitMix
//
//  Created by wisnuc-imac on 2017/10/23.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "GetStaionInfoAPI.h"

@implementation GetStaionInfoAPI
+ (instancetype)apiWithServicePath:(NSString *)servicePath{
    GetStaionInfoAPI * api = [GetStaionInfoAPI new];
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
    return [NSString stringWithFormat:@"%@station/info",_servicePath];
}


@end
