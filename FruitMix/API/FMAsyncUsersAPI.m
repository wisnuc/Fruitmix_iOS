//
//  FMAsyncUsersAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/7/7.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMAsyncUsersAPI.h"

@implementation FMAsyncUsersAPI

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    if (KISCLOUD) {
        return [NSString stringWithFormat:@"stations/%@/json",KSTATIONID];
    }else{
        return [NSString stringWithFormat:@"users"];
    }
}
/// 请求的URL

-(id)requestArgument{
    if (KISCLOUD) {
        NSString *requestUrl = [NSString stringWithFormat:@"/users"];;
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
