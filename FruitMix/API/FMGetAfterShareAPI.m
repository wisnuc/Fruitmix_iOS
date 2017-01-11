//
//  FMGetAfterShareAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMGetAfterShareAPI.h"

@implementation FMGetAfterShareAPI
/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"mediashare?after=%lld",_afterCTime];
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}
@end
