//
// NetworkClient.m
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

#import "NetworkClient.h"

@implementation NetworkClient

#pragma mark - Singleton instance

+(instancetype)sharedClient
{
    static NetworkClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
    });
    return _sharedClient;
}

#pragma mark - Init method

- (instancetype)init {
    if (self = [super init]) {
        [[RSNetworkManager sharedManager] initWithBaseURL:@""];
    }
    return self;
}

#pragma mark - Web Service request

-(void)requestWithURL:(NSString *)urlString requestType:(RequestType)type withHeader:(NSDictionary *)headers andParams:(NSDictionary *)params successBlock:(void (^)(id response))successBlock andFailure:(void (^)(NSString *error))failureBlock {
    
    [[RSNetworkManager sharedManager] requestWithURL:urlString requestType:type withHeaders:headers andParams:params successBlock:^(NSURLResponse *response, id responseObject) {
        
        successBlock (responseObject);
        
    } andFailure:^(NSError *error) {
        
        NSString *errorDescription = [self errorDescriptionForCode:error.code] ? [self errorDescriptionForCode:error.code] : error.localizedDescription;
        failureBlock (errorDescription);
    }];
}

#pragma mark- Private methods

-(NSString *)errorDescriptionForCode:(NSUInteger)code {
    NSString *errorDescription = nil;
    
    if(code == kErrorCodeBadURL){
        errorDescription = kErrorMalformedURL;
    }
    else if(code == kErrorCodeConnectionTimeout){
        errorDescription = kErrorConnectionTimedout;
    }
    else if (code == kErrorCodeNoInternet){
        errorDescription = kErrorNoInternetConnection;
    }
    else if (code == kErrorCodeNetworkConnectionLost){
        errorDescription = kErrorNetworkConnectionLost;
    }
    else if (code == kErrorCodeFileNotExists){
        errorDescription = kErrorFileNotExists;
    }
    
    return errorDescription;
}

@end
