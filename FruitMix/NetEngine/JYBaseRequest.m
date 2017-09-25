//
//  JYBaseRequest.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/1.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"
#import "JYNetEngine.h"

@interface JYBaseRequest ()

@end

@implementation JYBaseRequest{
    BOOL * _isRuning;
}
/// append self to request queue
- (void)start{
    [[JYNetEngine sharedInstance] addRequest:self];
}

/// remove self from request queue
- (void)stop{
    [[JYNetEngine sharedInstance] cancleRequest:self];
}
/**
 *  检测当前request 是否在运行
 *
 *  @return YES 是指还没有结束  NO 是指 已经结束
 */
- (BOOL)isRuning{
    if (_dataTask.state == NSURLSessionTaskStateRunning) {
        return YES;
    }
    return  NO;
}



/// block回调
- (void)startWithCompletionBlockWithSuccess:(JYRequestCompletionBlock)success
                                    failure:(JYRequestCompletionBlock)failure{
    _successCompleteBlcok = [success copy];
    _failureCompleteBlcok = [failure copy];
    [self start];
}
- (void)startWithFormDattCompletionBlockWithSuccess:(JYRequestCompletionBlock)success
                                    failure:(JYRequestCompletionBlock)failure{
    _successCompleteBlcok = [success copy];
    _failureCompleteBlcok = [failure copy];
    [self start];
}
//- ()
//uploadTaskWithRequest

//- (void)setCompletionBlockWithSuccess:(JYRequestCompletionBlock)success
//                              failure:(JYRequestCompletionBlock)failure{
//    _successCompleteBlcok = [success copy];
//    _failureCompleteBlcok = [failure copy];
//}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompleteBlcok = nil;
    self.failureCompleteBlcok = nil;
}



/********************************************************************************/
/************************* JYRequestDelegate 的 Method **************************/
/********************************* 需要重写 **************************************/
/********************************************************************************/


- (JYRequestMethod)requestMethod{
    return JYRequestMethodGet;
}

/// 请求成功的回调
- (void)requestCompleteFilter{

}

/// 请求失败的回调
- (void)requestFailedFilter{

}
//是否使用CDN 主机
- (BOOL)useCDN{
    return NO;
}
/// 请求的URL
- (NSString *)requestUrl{
    return @" ";
}

/// 请求的CdnURL
- (NSString *)cdnUrl{
    return @" ";
}

/// 请求的BaseURL
- (NSString *)baseUrl{
    return @"";
}

/// 请求的连接超时时间，默认为60秒
- (NSTimeInterval)requestTimeoutInterval{
    return 20.0f;
}

/// 请求的参数列表
- (id)requestArgument{
    return nil;
}

/// 用于在cache结果，计算cache文件名时，忽略掉一些指定的参数
- (id)cacheFileNameFilterForRequestArgument:(id)argument{
    return nil;
}

/// 在HTTP报头添加的自定义参数
- (NSDictionary *)requestHeaderFieldValueDictionary{
    return @{};
}

//private method
-(void)setResponseJsonObject:(id)responseJsonObject{
    
    if ([responseJsonObject isKindOfClass:[NSData class]]) {
        _responseJsonObject = [NSJSONSerialization JSONObjectWithData:responseJsonObject options:0 error:nil];
    }else
        _responseJsonObject = responseJsonObject;
}

//默认
- (id)responseSerialization{
    return [AFJSONResponseSerializer serializer];
}
@end
