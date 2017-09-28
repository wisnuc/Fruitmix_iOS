//
//  FMAccountUsersAPI.m
//  FruitMix
//
//  Created by wisnuc on 2017/7/25.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMAccountUsersAPI.h"
#import "FMGetUserInfo.h"

@implementation FMAccountUsersAPI
/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
- (NSString *)requestUrl{
    if (KISCLOUD) {
        return [NSString stringWithFormat:@"stations/%@/json",KSTATIONID];
    }else{
        return [NSString stringWithFormat:@"users/%@",DEF_UUID];
    }
}
/// 请求的URL

-(id)requestArgument{
    if (KISCLOUD) {
        NSString *requestUrl = [NSString stringWithFormat:@"/users/%@",DEF_UUID];;
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
