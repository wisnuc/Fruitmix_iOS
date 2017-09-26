//
//  FLUploadFilesAPI.m
//  FruitMix
//
//  Created by wisnuc-imac on 2017/9/26.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FLUploadFilesAPI.h"

@implementation FLUploadFilesAPI
+(instancetype)apiWithPhotoUUID:(NSString *)photoUUID{
    FLUploadFilesAPI * api = [FLUploadFilesAPI new];
    api.photouuid = photoUUID;
    return api;
}
/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodPost;
}
/// 请求的URL
- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"drives/%@/dirs/%@/entries/",DRIVE_UUID,_photouuid];
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}

- (id)responseSerialization{
    AFJSONResponseSerializer *responseSerializer =  [AFJSONResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    return responseSerializer;
}

-(NSTimeInterval)requestTimeoutInterval{
    return 20;
}
@end
