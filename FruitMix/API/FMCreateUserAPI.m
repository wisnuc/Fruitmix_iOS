//
//  FMCreateUserAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/10/8.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMCreateUserAPI.h"

@implementation FMCreateUserAPI

- (JYRequestMethod)requestMethod{
    return JYRequestMethodPost;
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
        [dic setObject:@"POST" forKey:@"method"];
        [dic setObject:resource forKey:@"resource"];
        NSString *userName = _param[@"username"];
        NSString *password = _param[@"password"];
        [dic setObject:userName forKey:@"username"];
        [dic setObject:password forKey:@"password"];
        return dic;
    }else{
        NSLog(@"%@",_param);
        return self.param;
    }
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}


@end
