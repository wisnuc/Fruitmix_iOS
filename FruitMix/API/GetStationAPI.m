
//
//  GetStationAPI.m
//  FruitMix
//
//  Created by wisnuc-imac on 2017/9/26.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "GetStationAPI.h"

@implementation GetStationAPI
+ (instancetype)apiWithGUID:(NSString *)GUID{
    GetStationAPI *api = [GetStationAPI new];
    api.GUID = GUID;
    return api;
}

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"users/%@/stations",_GUID];
}

- (NSDictionary *)requestHeaderFieldValueDictionary{
     NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",DEF_Token] forKey:@"Authorization"];
    return dic;
}
@end
