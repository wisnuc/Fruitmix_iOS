//
//  FLUploadFilesAPI.m
//  FruitMix
//
//  Created by wisnuc-imac on 2017/9/26.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FLUploadFilesAPI.h"

@implementation FLUploadFilesAPI
+(instancetype)apiWithPhotoUUID:(NSString *)photoUUID PhotoName:(NSString *)photoName Hash:(NSString *)sha256 Size:(NSInteger)size{
    FLUploadFilesAPI * api = [FLUploadFilesAPI new];
    api.photouuid = photoUUID;
    if (photoName !=nil ||photoName.length>0) {
      api.photoName = photoName;
    }
    if (sha256 !=nil ||sha256.length>0) {
       api.sha256 = sha256;
    }
    if (size>0) {
       api.size = size;
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
        return [NSString stringWithFormat:@"stations/%@/pipe",KSTATIONID];
    }else{
        return [NSString stringWithFormat:@"drives/%@/dirs/%@/entries/",DRIVE_UUID,_photouuid];
    }
}

-(id)requestArgument{
    if (KISCLOUD) {
        NSString *requestUrl = [NSString stringWithFormat:@"/drives/%@/dirs/%@/entries",DRIVE_UUID,_photouuid];
        NSString *resource =[requestUrl base64EncodedString] ;
        NSMutableDictionary * mutableDic = [NSMutableDictionary dictionaryWithCapacity:0];
//        [mutableDic setObject:@"POST" forKey:@"method"];
//        [mutableDic setObject:resource forKey:@"resource"];
      
        
        NSMutableDictionary *manifestDic  = [NSMutableDictionary dictionaryWithCapacity:0];
        [manifestDic setObject:@"newfile" forKey:@"op"];
        [manifestDic setObject:@"POST" forKey:@"method"];
        [manifestDic setObject:_photoName forKey:@"toName"];
        [manifestDic setObject:resource forKey:@"resource"];
        [manifestDic setObject:_sha256 forKey:@"sha256"];
        [manifestDic setObject:@(_size) forKey:@"size"];

        NSData *josnData = [NSJSONSerialization dataWithJSONObject:manifestDic options:NSJSONWritingPrettyPrinted error:nil];
        NSString *result = [[NSString alloc] initWithData:josnData  encoding:NSUTF8StringEncoding];
        [mutableDic setObject:result forKey:@"manifest"];
        return mutableDic;
    }else{
        return nil;
    }
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}

- (id)responseSerialization{
    AFJSONResponseSerializer *responseSerializer =  [AFJSONResponseSerializer serializer];
//    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    return responseSerializer;
}

-(NSTimeInterval)requestTimeoutInterval{
    return 20;
}
@end
