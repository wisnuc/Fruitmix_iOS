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
    if (KISCLOUD) {
        return [NSString stringWithFormat:@"stations/%@/json",KSTATIONID];
    }else{
        return [NSString stringWithFormat:@"drives/%@/dirs/%@",DRIVE_UUID,_uuid];
    }
}

-(id)requestArgument{
    if (KISCLOUD) {
        NSString *requestUrl = [NSString stringWithFormat:@"/drives/%@/dirs/%@",DRIVE_UUID,_uuid];
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

- (id)responseSerialization{
    return [AFJSONResponseSerializer serializer];
}

//-(NSTimeInterval)requestTimeoutInterval{
//    return 20;
//}
@end
