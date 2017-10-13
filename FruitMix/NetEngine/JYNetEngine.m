//
//  JYNetEngine.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/1.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYNetEngine.h"
#import "JYRequestConfig.h"
#import "JYNetworker.h"

//Private Method
@interface JYBaseRequest ()
-(void)setResponseJsonObject:(id)responseJsonObject;
@end

@implementation JYNetEngine{
    JYRequestConfig * _config;
    NSMutableDictionary * _requestsRecord;
    AFURLSessionManager * _manager;
}

+(JYNetEngine *)sharedInstance{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _config = [JYRequestConfig sharedConfig];
        _requestsRecord = [NSMutableDictionary dictionary];
        _manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _manager.operationQueue.maxConcurrentOperationCount = 4;
        _manager.securityPolicy = _config.securityPolocy;
    }
    return self;
}

-(void)addRequest:(id<JYRequestDelegate>)request{
    JYBaseRequest * fullRequest = request;
    NSMutableURLRequest * urlRequest = [JYNetworker workerCreateRequestWithRequest:request];
    if ([request respondsToSelector:@selector(responseSerialization)]) {
        _manager.responseSerializer = [request responseSerialization];
    }
    
    if ([request respondsToSelector:@selector(requestTimeoutInterval)]) {
        urlRequest.timeoutInterval = [request requestTimeoutInterval];
    }else
        urlRequest.timeoutInterval = 15;
    
    fullRequest.dataTask = [JYNetworker workerDataTaskWithRequest:urlRequest andManager:_manager completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        [self handleRequestResult:fullRequest andResponse:response andResponseObject:responseObject andError:error];
    }];
    //开始
    [fullRequest.dataTask resume];
    //把dataTask存到record
    [self addRecord:fullRequest];
}

-(void)addFormDataRequest:(id<JYRequestDelegate>)request formDataBlock:(JYRequestFormDataBlock)formDataBlock uploadProgressBlock:(JYUploadProgressBlock)uploadProgress{
     JYBaseRequest * fullRequest = request;
    @autoreleasepool {
    NSMutableURLRequest * urlRequest = [JYNetworker workerCreateFormDataRequestWithRequest:request formDataBlock:formDataBlock];
    if ([request respondsToSelector:@selector(responseSerialization)]) {
        _manager.responseSerializer = [request responseSerialization];
    }
    
    if ([request respondsToSelector:@selector(requestTimeoutInterval)]) {
        urlRequest.timeoutInterval = [request requestTimeoutInterval];
    }else
        urlRequest.timeoutInterval = 15;
    fullRequest.dataTask = [JYNetworker workerDataTaskFormDataWithRequest:urlRequest andManager:_manager uploadProgressBlock:uploadProgress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
         [self handleRequestResult:fullRequest andResponse:response andResponseObject:responseObject andError:error];
    }];
    
   [fullRequest.dataTask resume];
   [self addRecord:fullRequest];
   };
}

-(void)cancleRequest:(id<JYRequestDelegate>)request{
    JYBaseRequest * fullRequest = request;
    [fullRequest.dataTask cancel];
    [self removeRecord:fullRequest.dataTask];
}
-(void)cancleAllRequest{
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        JYBaseRequest *request = copyRecord[key];
        [request stop];
    }
    //删除所有请求
    [_requestsRecord removeAllObjects];
}
// 合成 全的网址
-(NSString *)bulidRequestURL:(id<JYRequestDelegate>)request{
    NSString * detailURL = [request requestUrl];
    if([detailURL hasPrefix:@"http"]){
        return detailURL;
    }
    NSString *baseURL;
    if ([request useCDN]) {
        if ([request cdnUrl].length > 0) {
            baseURL = [request cdnUrl];
        } else {
            baseURL = [_config cdnURL];
        }
    }else{
        if ([request baseUrl].length > 0) {
            baseURL = [request baseUrl];
        } else {
            baseURL = [_config baseURL];
        }
    }
    return [NSString stringWithFormat:@"%@%@", baseURL, detailURL];
}

//成功失败回调
-(void)handleRequestResult:(JYBaseRequest *)request
               andResponse:(NSURLResponse *)response
         andResponseObject:(id)responseObject
                  andError:(NSError *)error{
//    NSLog(@"FINISHED Request: %@",NSStringFromClass([request class]));
    if([response isKindOfClass:[NSHTTPURLResponse class]])
        request.responseStatusCode = [(NSHTTPURLResponse *)response statusCode];
    [request setResponseJsonObject:responseObject];
    [request setError:error];
    if(!error){
        if(request.successCompleteBlcok){
            request.successCompleteBlcok(request);
        }
        [request requestCompleteFilter];
        
    }else{
        if (request.failureCompleteBlcok ) {
            request.failureCompleteBlcok(request);
        }
        [request requestFailedFilter];
    }
    
    [request clearCompletionBlock];
}


//增加一条记录
- (void)addRecord:(JYBaseRequest *)request {
    if (request.dataTask != nil) {
        NSString *key = [self requestHashKey:request.dataTask];
        @synchronized(self) {
            _requestsRecord[key] = request;
        }
    }
}

//删除 一条 传输 记录
- (void)removeRecord:(NSURLSessionDataTask *)dataTask {
    NSString *key = [self requestHashKey:dataTask];
    @synchronized(self) {
        [_requestsRecord removeObjectForKey:key];
    }
}

//生成 dataTask 对应的 key
- (NSString *)requestHashKey:(NSURLSessionDataTask *)dataTask {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[dataTask hash]];
    return key;
}

@end
