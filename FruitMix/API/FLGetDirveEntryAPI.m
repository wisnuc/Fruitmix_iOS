//
//  FLGetDirveEntryAPI.m
//  FruitMix
//
//  Created by wisnuc-imac on 2017/9/25.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FLGetDirveEntryAPI.h"

@implementation FLGetDirveEntryAPI
+(instancetype)apiWithUUID:(NSString *)UUID{
    FLGetDirveEntryAPI * api = [FLGetDirveEntryAPI new];
    api.uuid = UUID;
    return api;
}

- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}
/// 请求的URL
- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"drives/%@/dirs/%@",DRIVE_UUID,_uuid];
}
-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}

- (id)responseSerialization{
    return [AFJSONResponseSerializer serializer];
}

//-(NSTimeInterval)requestTimeoutInterval{
//    return 20;
//}
@end
