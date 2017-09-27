//
//  JYNetworker.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/1.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYNetworker.h"
#import <AFNetworking/AFURLRequestSerialization.h>
#import "JYNetEngine.h"


@implementation JYNetworker

+(NSMutableURLRequest *)workerCreateRequestWithMethod:(NSString *)method andHTTPHeaderField:(NSDictionary *)headerFields withUrlString:(NSString *)url andParameters:(NSDictionary *)parameters{
    NSMutableURLRequest * request = [[AFJSONRequestSerializer serializer]requestWithMethod:method URLString:url parameters:parameters error:nil];
    if (headerFields) {
        NSArray * dicKeys = [headerFields allKeys];
        for (NSString * key in dicKeys) {
            [request setValue:headerFields[key] forHTTPHeaderField:key];
        }
    }
    return request;
}

+(NSMutableURLRequest *)workerCreateFormDataRequestWithMethod:(NSString *)method andHTTPHeaderField:(NSDictionary *)headerFields withUrlString:(NSString *)url andParameters:(NSDictionary *)parameters andFormDataBlock:(JYRequestFormDataBlock)formDataBlock{
//
    NSMutableURLRequest * request = [[AFJSONRequestSerializer serializer]multipartFormRequestWithMethod:method URLString:url parameters:parameters constructingBodyWithBlock:formDataBlock error:nil];
//    NSString *jsonStr =  parameters ;
//    NSData *postData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
//    [request setHTTPBody:postData];
    if (headerFields) {
        NSArray * dicKeys = [headerFields allKeys];
        for (NSString * key in dicKeys) {
            [request setValue:headerFields[key] forHTTPHeaderField:key];
        }
    }
   
     return request;
   
}

+(NSURLSessionDataTask *)workerDataTaskWithRequest:(NSURLRequest *)request andManager:(AFURLSessionManager *)manager completionHandler:(CompletionHandler)completionHandler{
//    AFJSONResponseSerializer * response = [AFJSONResponseSerializer serializer];
//    response.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", nil];
//    manager.responseSerializer = response;
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:completionHandler];
    return dataTask;
}

+(NSURLSessionDataTask *)workerDataTaskFormDataWithRequest:(NSURLRequest *)request andManager:(AFURLSessionManager *)manager uploadProgressBlock:(JYUploadProgressBlock)progressBlock completionHandler:(CompletionHandler)completionHandler{
     manager.securityPolicy.allowInvalidCertificates = YES;
    AFJSONResponseSerializer * response = [AFJSONResponseSerializer serializer];
    response.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    manager.responseSerializer = response;
    
    NSURLSessionDataTask *dataTask = [manager uploadTaskWithStreamedRequest:request progress:progressBlock completionHandler:completionHandler];
    return dataTask;
}

+(NSMutableURLRequest *)workerCreateFormDataRequestWithRequest:(id<JYRequestDelegate>)request formDataBlock:(JYRequestFormDataBlock)formDataBlock{
    JYRequestMethod method = [request requestMethod];
    NSString * fullMethod;
    switch (method) {
        case JYRequestMethodGet:
            fullMethod = @"GET";
            break;
        case JYRequestMethodPost:
            fullMethod = @"POST";
            break;
        case JYRequestMethodPut:
            fullMethod = @"PUT";
            break;
        case JYRequestMethodHead:
            fullMethod = @"HEAD";
            break;
        case JYRequestMethodPatch:
            fullMethod = @"PATCH";
            break;
        case JYRequestMethodDelete:
            fullMethod = @"DELETE";
            break;
        default:
            NSLog(@"Request Method  ERROR!");
            break;
    }
    
    id param = [request requestArgument];
    NSDictionary * httpHeader = [request requestHeaderFieldValueDictionary];
    if (httpHeader != nil && KISCLOUD) {
        httpHeader = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",DEF_Token] forKey:@"Authorization"];
    }
    NSString * url =  [[JYNetEngine sharedInstance] bulidRequestURL:request];
    return [self workerCreateFormDataRequestWithMethod:fullMethod andHTTPHeaderField:httpHeader withUrlString:url andParameters:param andFormDataBlock:formDataBlock];
}

+(NSMutableURLRequest *)workerCreateRequestWithRequest:(id<JYRequestDelegate>)request{
    JYRequestMethod method = [request requestMethod];
    NSString * fullMethod;
    switch (method) {
        case JYRequestMethodGet:
            fullMethod = @"GET";
            break;
        case JYRequestMethodPost:
            fullMethod = @"POST";
            break;
        case JYRequestMethodPut:
            fullMethod = @"PUT";
            break;
        case JYRequestMethodHead:
            fullMethod = @"HEAD";
            break;
        case JYRequestMethodPatch:
            fullMethod = @"PATCH";
            break;
        case JYRequestMethodDelete:
            fullMethod = @"DELETE";
            break;
        default:
            NSLog(@"Request Method  ERROR!");
            break;
    }
    
    id param = [request requestArgument];
    NSDictionary * httpHeader = [request requestHeaderFieldValueDictionary];
    if (httpHeader != nil && KISCLOUD) {
      httpHeader = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",DEF_Token] forKey:@"Authorization"];
    }
    NSString * url =  [[JYNetEngine sharedInstance] bulidRequestURL:request];
    return [self workerCreateRequestWithMethod:fullMethod andHTTPHeaderField:httpHeader withUrlString:url andParameters:param];
}
@end
