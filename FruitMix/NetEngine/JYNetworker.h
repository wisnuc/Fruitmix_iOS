//
//  JYNetworker.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/1.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JYBaseRequest.h"

typedef void(^CompletionHandler)(NSURLResponse *response, id responseObject, NSError *error);

@interface JYNetworker : NSObject
/**
 *  Create an NSMutableURLRequest
 *
 *  @param method       The HTTP method for the request, such as `GET`, `POST`, `PUT`, or `DELETE`. This parameter must not be `nil`.
 *  @param headerFields The HTTP header for the request, such as `Content-Type`,`Authorization`,`Range`,This parameter can be `nil`.
 *  @param url          The URL string for the request, This parameter must not be `nil`.
 *  @param parameters   The parameters to be either set as a query string for `GET` requests, or the request HTTP body.
 *
 *  @return an NsmutableURLRequest object
 *
 *  @author JackYang
 */
+(NSMutableURLRequest *)workerCreateRequestWithMethod:(NSString *)method andHTTPHeaderField:(NSDictionary *)headerFields withUrlString:(NSString *)url andParameters:(NSDictionary *)parameters;
/**
 *  Create an Connect
 *
 *  @param request           an NSURLRequest object.
 *  @param completionHandler About something with this connect ,such as `response`.
 *
 *  @author JackYang
 */
+(NSURLSessionDataTask *)workerDataTaskWithRequest:(NSURLRequest *)request andManager:(AFURLSessionManager *)manager completionHandler:(CompletionHandler)completionHandler;


+(NSMutableURLRequest *)workerCreateRequestWithRequest:(id<JYRequestDelegate>)request;

@end
