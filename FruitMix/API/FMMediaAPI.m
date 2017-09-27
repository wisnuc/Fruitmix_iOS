//
//  FMMediaAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/20.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMMediaAPI.h"

@implementation FMMediaAPI
/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    if (KISCLOUD) {
        return [NSString stringWithFormat:@"stations/%@/json",KSTATIONID];
    }else{
       return @"media";
    }
}

-(id)requestArgument{
    if (KISCLOUD) {
    NSString *requestUrl = @"/media";
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

-(NSTimeInterval)requestTimeoutInterval{
    return 200;
}
@end
