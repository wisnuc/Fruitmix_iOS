//
//  FMDeleteShareAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/27.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMDeleteShareAPI.h"

@implementation FMDeleteShareAPI

+(instancetype)apiWithDeleteShareId:(NSString *)shareId{
    FMDeleteShareAPI * api = [FMDeleteShareAPI new];
    api.shareId = shareId;;
    return api;
}

-(NSTimeInterval)requestTimeoutInterval{
    return 10.0f;
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodDelete;
}
/// 请求的URL
- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"mediashare/%@",self.shareId];
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}

@end
