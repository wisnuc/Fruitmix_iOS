// RSNetworkManager.m
// Copyright (c) 2016 Rushi Sangani
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RSNetworkManager.h"

@interface RSNetworkManager ()

@end

@implementation RSNetworkManager

#pragma mark - Singleton instance

+(RSNetworkManager *)sharedManager {
    
    static RSNetworkManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

#pragma mark - Init with Base URL

-(void)initWithBaseURL:(NSString *)urlString {
    self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:urlString]];
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
}

#pragma mark- Request Method

-(NSURLSessionDataTask *)requestWithURL:(NSString *)urlString requestType:(RequestType)type withHeaders:(NSDictionary *)headers andParams:(NSDictionary *)params successBlock:(void (^)(NSURLResponse * , id))successBlock andFailure:(void (^)(NSError *))failureBlock{
    
    /* Check if URL is nil */
    if(!urlString) {
        return nil;
    }
    
    /* initialise manager if not */
    if(!self.manager){
        self.manager = [AFHTTPSessionManager manager];
    }
    
    /* Add Headers to request if any. */
    
    for (NSString *key in [headers allKeys]) {
        [self.manager.requestSerializer setValue:[headers valueForKey:key] forHTTPHeaderField:key];
    }
    
    /* Serialize request by type */
    NSString *requestTypeMethod = [self getStringForRequestType:type];
    
    NSMutableURLRequest *request = [self.manager.requestSerializer requestWithMethod:requestTypeMethod URLString:[[NSURL URLWithString:urlString relativeToURL:_manager.baseURL] absoluteString] parameters:params error:nil];
    
    NSURLSessionDataTask *dataTask = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        if(error) {
            if(failureBlock) {
                failureBlock (error);
            }
        }
        else {
            if(successBlock) {
                successBlock (response, responseObject);
            }
        }
    }];

    [dataTask resume];
    
    return dataTask;
}

#pragma mark - GET Request type as string
-(NSString *)getStringForRequestType:(RequestType)type {
    
    NSString *requestTypeString;
    
    switch (type) {
        case GET:
            requestTypeString = @"GET";
            break;
            
        case POST:
            requestTypeString = @"POST";
            break;
            
        case PUT:
            requestTypeString = @"PUT";
            break;
            
        case DELETE:
            requestTypeString = @"DELETE";
            break;
            
        default:
            requestTypeString = @"GET";
            break;
    }
    
    return requestTypeString;
}

-(NSArray *)dataTasks {
    return [self.manager dataTasks];
}

#pragma mark- Cancel Task Method

-(void)cancelTask:(NSURLSessionDataTask *)task {
    
    for (NSURLSessionDataTask *datatask in [self.manager dataTasks]) {
        
        if(task.taskIdentifier == datatask.taskIdentifier){
            [task cancel];
            task = nil;
            break;
        }
    }
}

@end
