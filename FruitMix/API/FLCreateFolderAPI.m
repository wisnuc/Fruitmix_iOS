//
//  FLCreateFolderAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/10/25.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FLCreateFolderAPI.h"

@implementation FLCreateFolderAPI

+(instancetype)apiWithParentUUID:(NSString *)folderUUID finderName:(NSString *)finderName{
    FLCreateFolderAPI * api = [FLCreateFolderAPI new];
    api.parentId = folderUUID;
    if (finderName!=nil ||finderName.length !=0) {
        api.finderName = finderName;
    }
    return api;
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodPost;
}
/// 请求的URL
- (NSString *)requestUrl{
    if (KISCLOUD) {
        return [NSString stringWithFormat:@"stations/%@/json",KSTATIONID];
    }else{
        return  [NSString stringWithFormat:@"drives/%@/dirs/%@/entries",DRIVE_UUID,_parentId];
    }
    
}

-(id)requestArgument{
    if (KISCLOUD) {
        NSString *requestUrl = [NSString stringWithFormat:@"/drives/%@/dirs/%@/entries",DRIVE_UUID,_parentId];
        NSString *resource =[requestUrl base64EncodedString] ;
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
        [dic setObject:@"POST" forKey:@"method"];
        [dic setObject:resource forKey:@"resource"];
        [dic setObject:@"mkdir" forKey:@"op"];
        [dic setObject:_finderName forKey:@"toName"];
        return dic;
    }else{
        return nil;
    }
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}

/// 请求的参数列表
//- (id)requestArgument{
//    return [NSDictionary dictionaryWithObject:_folderName forKey:@"name"];
//}

- (id)responseSerialization{
    return [AFJSONResponseSerializer serializer];
}

@end
