//
//  FMGetCommentsAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/5/26.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMGetCommentsAPI.h"

@implementation FMGetCommentsAPI

+(FMGetCommentsAPI *)apiWithPhotoHash:(NSString *)hash{
    FMGetCommentsAPI * api = [FMGetCommentsAPI new];
    api.hashid = hash;
    return api;
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"media/%@?type=comments",_hashid];
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}
@end
