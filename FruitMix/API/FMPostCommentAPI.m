//
//  FMPostCommentAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/5/18.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMPostCommentAPI.h"

@implementation FMPostCommentAPI{
    NSString * _shareid;
    NSString * _photoDigest;
}

-(instancetype)initWithComment:(NSString *)comment andPhotoDigest:(NSString *)digest andShareId:(NSString *)shareid{
    if (self = [super init]) {
        _shareid = shareid;
        _photoDigest = digest;
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
        [dic setValue:comment forKey:@"text"];
        [dic setValue:shareid forKey:@"shareid"];
        self.param = dic;
    }
    return self;
}


/************************************************************************************************************************/

-(id)requestArgument{
    NSLog(@"%@",self.param);
    return self.param;
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodPost;
}
/// 请求的URL
- (NSString *)requestUrl{
    return [NSString stringWithFormat:@"media/%@?type=comments",_photoDigest];
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}

+(void)postNewCommentWithComment:(NSString *)comment andPhotoDigest:(NSString *)digest andShareId:(NSString *)shareid andCompleteBlock:(void(^)(BOOL success,id response))block{
    FMPostCommentAPI * api = [[FMPostCommentAPI alloc] initWithComment:comment andPhotoDigest:digest andShareId:shareid];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        if (block) {
            block(YES,request.responseJsonObject);
        }
    } failure:^(__kindof JYBaseRequest *request) {
        if (block) {
            block(NO,request.error);
        }
    }];
}

@end
