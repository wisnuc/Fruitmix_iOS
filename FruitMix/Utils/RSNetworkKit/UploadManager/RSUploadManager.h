// RSUploadManager.h
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

#import <Foundation/Foundation.h>

static NSString *bgUploadSessionIdentifier = @"com.RSNetworkKit.bgUploadSessionIdentifier";

@interface RSUploadManager : NSObject

/* Session Manager */

@property (nonatomic, strong) AFHTTPSessionManager *manager;

/* background upload completion handler */

@property (nonatomic, copy) void (^backgroundUploadCompletionHandler)(void);

/* background session completion handler */

@property (nonatomic, copy) void (^backgroundSessionCompletionHandler)(void);

/* Singleton shared instance */

+(instancetype)sharedManager;

/* Upload with URL */

-(NSURLSessionUploadTask *)uploadWithURL:(NSString *)urlString filePath:(NSString *)fileURLSting uploadProgress:(void (^)(NSNumber *progress))progressBlock success:(void (^)(NSURLResponse *response, id responseObject))completionBlock andFailure:(void (^)(NSError *error))failureBlock;

/* Start upload in background with URL */

-(NSURLSessionUploadTask *)startUploadInBackgroundWithURL:(NSString *)urlString filePath:(NSString *)fileURLSting uploadProgress:(void (^)(NSNumber *progress))progressBlock success:(void (^)(NSURLResponse *response, id responseObject))completionBlock andFailure:(void (^)(NSError *error))failureBlock;


/* Upload with multipart form request */

-(NSURLSessionUploadTask *)uploadWithMultipartFormRequest:(NSString *)urlString params:(NSDictionary *)params filePath:(NSString *)fileURLSting fileType:(FileType)type uploadProgress:(void (^)(NSNumber *progress))progressBlock success:(void (^)(NSURLResponse *response, id success))completionBlock andFailure:(void (^)(NSError *error))failureBlock;


/* Start multipart form upload in background with URL */

-(NSURLSessionUploadTask *)startMultipartFormUploadInBackground:(NSString *)urlString params:(NSDictionary *)params filePath:(NSString *)fileURLSting fileType:(FileType)type uploadProgress:(void (^)(NSNumber *progress))progressBlock success:(void (^)(NSURLResponse *response, id success))completionBlock andFailure:(void (^)(NSError *error))failureBlock;


/* cancel upload */

-(void)cancelUploadForTask:(NSURLSessionUploadTask *)task;

@end
