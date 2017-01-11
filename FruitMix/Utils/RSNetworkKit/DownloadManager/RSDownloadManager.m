//
// RSDownloadManager.m
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

#import "RSDownloadManager.h"

@interface RSDownloadManager ()

@end

@implementation RSDownloadManager

#pragma mark - Singleton instance
+(instancetype)sharedManager
{
    static RSDownloadManager *_downloadManager = nil;
    static dispatch_once_t token;
    
    dispatch_once(&token, ^{
        
        if (!_downloadManager) {
            _downloadManager = [[self alloc] init];
        }
    });
    return _downloadManager;
}

#pragma mark - Init with Session Configuration

-(void)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    self.manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
}

#pragma mark- download in background request Method

-(NSURLSessionDownloadTask *)downloadInBackgroundWithURL:(NSString *)urlString downloadProgress:(void (^)(NSNumber *))progressBlock success:(void (^)(NSURLResponse *, NSURL *))completionBlock andFailure:(void (^)(NSError *))failureBlock {
    
    /* initialise session manager with background configuration */
    
    if(!self.manager){
        [self initWithSessionConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:bgDownloadSessionIdentifier]];
    }
    
    [self configureBackgroundSessionCompletion];
    
    return [self downloadWithURL:urlString downloadProgress:progressBlock success:completionBlock andFailure:failureBlock];
}

#pragma mark- Handle background session completion

- (void)configureBackgroundSessionCompletion {
    __weak typeof(self) weakSelf = self;
    
    [self.manager setDidFinishEventsForBackgroundURLSessionBlock:^(NSURLSession *session) {
        
        /* calling background download completion handler */
        
        if(weakSelf.backgroundDownloadCompletionHandler){
            weakSelf.backgroundDownloadCompletionHandler();
        }
        
        /* calling background session completion handler */
        
        if (weakSelf.backgroundSessionCompletionHandler) {
            weakSelf.backgroundSessionCompletionHandler();
            weakSelf.backgroundSessionCompletionHandler = nil;
        }
    }];
}

#pragma mark- Download Request Method

-(NSURLSessionDownloadTask *)downloadWithURL:(NSString *)urlString downloadProgress:(void (^)(NSNumber *))progressBlock success:(void (^)(NSURLResponse *, NSURL *))completionBlock andFailure:(void (^)(NSError *))failureBlock {
    
    /* Check if URL is nil */
    if(!urlString) {
        return nil;
    }
    
    /* initialise manager if not */
    if(!self.manager){
        self.manager = [AFHTTPSessionManager manager];
    }
    
    /* Create a request from the url */
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSURLSessionDownloadTask *downloadTask = [self.manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        if(progressBlock) {
            progressBlock ([NSNumber numberWithDouble:downloadProgress.fractionCompleted]);
        }
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if(error) {
            if(failureBlock) {
                failureBlock (error);
            }
        }
        else {
            if(completionBlock) {
                completionBlock (response, filePath);
            }
        }
        
    }];
    
    [downloadTask resume];
    
    return downloadTask;
}

#pragma mark- Cancel Download Task Method

-(void)cancelDownloadForTask:(NSURLSessionDownloadTask *)task {
    
    for (NSURLSessionDownloadTask *downloadtask in [self.manager dataTasks]) {
        
        if(task.taskIdentifier == downloadtask.taskIdentifier){
            [task cancel];
            task = nil;
            break;
        }
    }
}

@end