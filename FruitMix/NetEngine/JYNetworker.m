//
//  JYNetworker.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/1.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYNetworker.h"
//#import 
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

+(NSMutableURLRequest *)workerCreateFormDataRequestWithMethod:(NSString *)method andHTTPHeaderField:(NSDictionary *)headerFields withUrlString:(NSString *)url andParameters:(NSDictionary *)parameters{
    NSMutableURLRequest * request = [[AFJSONRequestSerializer serializer]requestWithMethod:method URLString:url parameters:parameters error:nil];
    if (headerFields) {
        NSArray * dicKeys = [headerFields allKeys];
        for (NSString * key in dicKeys) {
            [request setValue:headerFields[key] forHTTPHeaderField:key];
        }
    }
    
//     AFStreamingMultipartFormData *formData = [[AFStreamingMultipartFormData alloc] initWithURLRequest:mutableRequest stringEncoding:NSUTF8StringEncoding];
//    if (parameters) {
//        for (AFQueryStringPair *pair in AFQueryStringPairsFromDictionary(parameters)) {
//            NSData *data = nil;
//            if ([pair.value isKindOfClass:[NSData class]]) {
//                data = pair.value;
//            } else if ([pair.value isEqual:[NSNull null]]) {
//                data = [NSData data];
//            } else {
//                data = [[pair.value description] dataUsingEncoding:self.stringEncoding];
//            }
//
//            if (data) {
//                [formData appendPartWithFormData:data name:[pair.field description]];
//            }
//        }
//    }
    
//    if (block) {
//        block(formData);
//    }
    
//    return [formData requestByFinalizingMultipartFormData];
    return reuest;
}

+(NSURLSessionDataTask *)workerDataTaskWithRequest:(NSURLRequest *)request andManager:(AFURLSessionManager *)manager completionHandler:(CompletionHandler)completionHandler{
//    AFJSONResponseSerializer * response = [AFJSONResponseSerializer serializer];
//    response.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", nil];
//    manager.responseSerializer = response;
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:completionHandler];
    return dataTask;
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
    NSString * url =  [[JYNetEngine sharedInstance] bulidRequestURL:request];
    return [self workerCreateRequestWithMethod:fullMethod andHTTPHeaderField:httpHeader withUrlString:url andParameters:param];
}
@end
