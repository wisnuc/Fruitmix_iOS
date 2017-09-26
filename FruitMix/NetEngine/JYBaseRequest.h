//
//  JYBaseRequest.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/1.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger , JYRequestMethod) {
    JYRequestMethodGet = 0,
    JYRequestMethodPost,
    JYRequestMethodHead,
    JYRequestMethodPut,
    JYRequestMethodDelete,
    JYRequestMethodPatch
};
@class JYBaseRequest;

@protocol JYRequestDelegate <NSObject>

@required
/// Http请求的方法
- (JYRequestMethod)requestMethod;

/// 请求成功的回调
- (void)requestCompleteFilter;

/// 请求失败的回调
- (void)requestFailedFilter;

@optional

/// 是否使用CDN的host地址
- (BOOL)useCDN;

/// 请求的URL
- (NSString *)requestUrl;

/// 请求的CdnURL
- (NSString *)cdnUrl;

/// 请求的BaseURL
- (NSString *)baseUrl;

/// 请求的连接超时时间，默认为60秒
- (NSTimeInterval)requestTimeoutInterval;

/// 请求的参数列表
- (id)requestArgument;

/// 用于在cache结果，计算cache文件名时，忽略掉一些指定的参数
- (id)cacheFileNameFilterForRequestArgument:(id)argument;

/// 在HTTP报头添加的自定义参数
- (NSDictionary *)requestHeaderFieldValueDictionary;
//解释策略 返回AFHTTPResponseSerialization or  AFJSONResponseSerialization
- (id)responseSerialization;

@end

typedef void(^JYRequestCompletionBlock)(__kindof JYBaseRequest *request);
typedef void(^JYRequestFormDataBlock)(id <AFMultipartFormData> formData);
typedef void(^JYUploadProgressBlock)(NSProgress *progress);

@interface JYBaseRequest : NSObject<JYRequestDelegate>
//NSURLSessionDataTask 对象用来 管理request 的运行
@property (nonatomic) NSURLSessionDataTask * dataTask;

@property (nonatomic) NSInteger tag;

@property (nonatomic) NSDictionary * userInfo;

//@property (nonatomic,readonly) NSDictionary * responseHeaders;
//
//@property (nonatomic,readonly) NSData * responseData;

@property (nonatomic,readonly) id responseJsonObject;

@property (nonatomic) NSInteger responseStatusCode;

@property (nonatomic) BOOL shouldCache; //default is NO;

@property (nonatomic) JYRequestCompletionBlock successCompleteBlcok;

@property (nonatomic) JYRequestCompletionBlock failureCompleteBlcok;

@property (nonatomic) JYRequestFormDataBlock formDataBlock;

@property (nonatomic) JYUploadProgressBlock uploadProgress;

@property (nonatomic) NSError * error;

/// append self to request queue
- (void)start;

/// remove self from request queue
- (void)stop;
/**
 *  检测当前request 是否在运行
 *
 *  @return YES 是指还没有结束  NO 是指 已经结束
 */
- (BOOL)isRuning;

/// block回调
- (void)startWithFromDataBlock:(JYRequestFormDataBlock)block
           uploadProgressBlock:(JYUploadProgressBlock)uploadProgress
    CompletionBlockWithSuccess:(JYRequestCompletionBlock)success
                       failure:(JYRequestCompletionBlock)failure;

- (void)startWithCompletionBlockWithSuccess:(JYRequestCompletionBlock)success
                                    failure:(JYRequestCompletionBlock)failure;

- (void)setCompletionBlockWithSuccess:(JYRequestCompletionBlock)success
                              failure:(JYRequestCompletionBlock)failure;

//消除block循环
- (void)clearCompletionBlock ;
@end
