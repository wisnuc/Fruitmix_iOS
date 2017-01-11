// RSUploadManager.m
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

#import "RSUploadManager.h"

@interface RSUploadManager ()

@end

@implementation RSUploadManager

#pragma mark - Singleton instance
+(instancetype)sharedManager
{
    static RSUploadManager *_uploadManager = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        if (!_uploadManager) {
            _uploadManager = [[self alloc] init];
        }
    });
    return _uploadManager;
}

#pragma mark - Init with Session Configuration

-(void)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    self.manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
}

#pragma mark- Start Upload file in background with URL Request

-(NSURLSessionUploadTask *)startUploadInBackgroundWithURL:(NSString *)urlString filePath:(NSString *)fileURLSting uploadProgress:(void (^)(NSNumber *))progressBlock success:(void (^)(NSURLResponse *, id))completionBlock andFailure:(void (^)(NSError *))failureBlock {
    
    /* initialise session manager with background configuration */
    
    if(!self.manager){
        [self initWithSessionConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:bgUploadSessionIdentifier]];
    }

    [self configureBackgroundSessionCompletion];
    
    return [self uploadWithURL:urlString filePath:fileURLSting uploadProgress:progressBlock success:completionBlock andFailure:failureBlock];
}

#pragma mark- Handle background session completion

- (void)configureBackgroundSessionCompletion {
    __weak typeof(self) weakSelf = self;
    
    [self.manager setDidFinishEventsForBackgroundURLSessionBlock:^(NSURLSession *session) {
        
        /* calling background upload completion handler */
        
        if(weakSelf.backgroundUploadCompletionHandler){
            weakSelf.backgroundUploadCompletionHandler();
        }
        
        /* calling background session completion handler */
        
        if (weakSelf.backgroundSessionCompletionHandler) {
            weakSelf.backgroundSessionCompletionHandler();
            weakSelf.backgroundSessionCompletionHandler = nil;
        }
    }];
}

#pragma mark- Upload file with URL Request method

-(NSURLSessionUploadTask *)uploadWithURL:(NSString *)urlString filePath:(NSString *)fileURLSting uploadProgress:(void (^)(NSNumber *))progressBlock success:(void (^)(NSURLResponse *, id))completionBlock andFailure:(void (^)(NSError *))failureBlock {
    
    /* Check if URL or fileURL is nil */
    if(!urlString || !fileURLSting) {
        return nil;
    }
    
    /* initialise manager if not */
    if(!self.manager){
        self.manager = [AFHTTPSessionManager manager];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    request.HTTPMethod = @"POST";
    NSURL *filePath = [NSURL fileURLWithPath:fileURLSting];
    [request setValue:[NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
     NSURLSessionUploadTask *uploadTask = [self.manager uploadTaskWithRequest:request fromFile:filePath progress:^(NSProgress * _Nonnull uploadProgress) {
         
         if(progressBlock) {
            progressBlock ([NSNumber numberWithDouble:uploadProgress.fractionCompleted]);
         }
         
     } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {

         if(error) {
             if(failureBlock) {
                 failureBlock (error);
             }
         }
         else {
             if(completionBlock) {
                 completionBlock (response, responseObject);
             }
         }
     }];
    
    [uploadTask resume];
    
    return uploadTask;

}

#pragma mark - Start multipart form upload request in background

-(NSURLSessionUploadTask *)startMultipartFormUploadInBackground:(NSString *)urlString params:(NSDictionary *)params filePath:(NSString *)fileURLSting fileType:(FileType)type uploadProgress:(void (^)(NSNumber *))progressBlock success:(void (^)(NSURLResponse *, id))completionBlock andFailure:(void (^)(NSError *))failureBlock {
    
    /* initialise session manager with background configuration */
    
    if(!self.manager){
        [self initWithSessionConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:bgUploadSessionIdentifier]];
    }
    
    [self configureBackgroundSessionCompletion];
    
    return [self uploadWithMultipartFormRequest:urlString params:params filePath:fileURLSting fileType:type uploadProgress:progressBlock success:completionBlock andFailure:failureBlock];
}

#pragma mark - Upload with multipart form request method

-(NSURLSessionUploadTask *)uploadWithMultipartFormRequest:(NSString *)urlString params:(NSDictionary *)params filePath:(NSString *)fileURLSting fileType:(FileType)type uploadProgress:(void (^)(NSNumber *))progressBlock success:(void (^)(NSURLResponse *, id))completionBlock andFailure:(void (^)(NSError *))failureBlock
{
    
    /* Check if URL or fileURL is nil */
    if(!urlString || !fileURLSting) {
        return nil;
    }
    
    /* create MIME type */
    
    NSString *mimeType = [self getMimeTypeForFile:type];
    NSString *fileName = (type == FileTypeImage) ? @"image.png" : @"video.mp4";
    
    /* create request */
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:fileURLSting] name:@"file" fileName:fileName mimeType:mimeType error:nil];
        
    } error:nil];
    
    [request setValue:[NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
    
    /* create upload task */
    
    NSURLSessionUploadTask *uploadTask = [self.manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if(progressBlock) {
            progressBlock ([NSNumber numberWithDouble:uploadProgress.fractionCompleted]);
        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if(error) {
            if(failureBlock) {
                failureBlock (error);
            }
        }
        else {
            if(completionBlock) {
                completionBlock (response, responseObject);
            }
        }
        
    }];
    
    [uploadTask resume];
    
    return uploadTask;
}

#pragma mark- Cancel Upload Task Method

-(void)cancelUploadForTask:(NSURLSessionUploadTask *)task {
    
    for (NSURLSessionUploadTask *uploadtask in [self.manager dataTasks]) {
        
        if(task.taskIdentifier == uploadtask.taskIdentifier){
            [task cancel];
            task = nil;
            break;
        }
    }
}

#pragma mark- Private methods

-(NSString *)getMimeTypeForFile:(FileType)type {

    NSString *mimeString;
    
    switch (type) {
            
        case FileTypeImage:
            mimeString = @"image/png";
            break;
        
        case FileTypeVideo:
            mimeString = @"video/mp4";
            break;
            
        default:
            mimeString = @"image/png";
            break;
    }
    
    return mimeString;
}

@end
