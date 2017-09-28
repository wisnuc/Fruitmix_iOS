//
//  FMGetUsersAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/20.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMGetUsersAPI.h"

@implementation FMGetUsersAPI
/// Http请求的方法
+ (instancetype)apiWithStationId:(NSString *)stationId{
    FMGetUsersAPI *api = [FMGetUsersAPI new];
    api.stationId = stationId;
    return api;
}

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    if (KISCLOUD) {
        NSString *url;
        if (KSTATIONID == nil) {
          url = [NSString stringWithFormat:@"stations/%@/json",_stationId];
        }else{
          url = [NSString stringWithFormat:@"stations/%@/json",KSTATIONID];
        }
        return url;
    }else{
        return @"users";
    }
}

-(id)requestArgument{
    if (KISCLOUD) {
        NSString *requestUrl = [NSString stringWithFormat:@"/users"];
        NSString *resource =[requestUrl base64EncodedString] ;
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
        [dic setObject:@"GET" forKey:@"method"];
        [dic setObject:resource forKey:@"resource"];
        return dic;
    }else{
        return nil;
    }
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}
@end
