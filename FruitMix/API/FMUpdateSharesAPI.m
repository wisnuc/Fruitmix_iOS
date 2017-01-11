//
//  FMUpdateSharesAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/26.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMUpdateSharesAPI.h"

@implementation FMUpdateSharesAPI

+(instancetype)apiWithShareId:(NSString *)shareId andParam:(NSArray *)param{

    FMUpdateSharesAPI * api = [FMUpdateSharesAPI new];
    api.shareId = shareId;
    api.param = param;
    return api;
    
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodPost;
}
/// 请求的URL
- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"mediashare/%@/update",self.shareId];
}
-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}

-(id)requestArgument{
    NSLog(@"%@",self.param);
    return self.param;
}

@end
