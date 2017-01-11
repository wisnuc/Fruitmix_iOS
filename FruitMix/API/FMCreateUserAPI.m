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
    return @"users";
}

-(id)requestArgument{
    NSLog(@"%@",_param);
    return self.param;
}


-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}


@end
