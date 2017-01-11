//
//  FLGetFilesAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FLGetFilesAPI.h"

@implementation FLGetFilesAPI


+(instancetype)apiWithFileUUID:(NSString *)fileUUID{
    FLGetFilesAPI * api = [FLGetFilesAPI new];
    api.fileUUID = fileUUID;
    return api;
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"files/%@",self.fileUUID];
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}

- (id)responseSerialization{
    return [AFJSONResponseSerializer serializer];
}
@end
