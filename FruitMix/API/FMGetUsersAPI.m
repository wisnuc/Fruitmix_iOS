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
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    return @"users";
}

//-(NSDictionary *)requestHeaderFieldValueDictionary{
//    
//}
@end
