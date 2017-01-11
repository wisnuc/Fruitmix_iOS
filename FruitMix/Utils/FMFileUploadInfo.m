//
//  FMFileUploadInfo.m
//  FruitMix
//
//  Created by 杨勇 on 16/12/27.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMFileUploadInfo.h"

#define FormStart @"--"
#define FormBoundary @"----------V2ymHFg03ehbqgZCaKO6jy"
#define FormEnd @"\r\n"

@implementation FMFileUploadInfo{
    NSString * _url;
}

-(instancetype)init{
    if (self = [super init]) {
        _url = [NSString stringWithFormat:@"%@libraries/%@",[JYRequestConfig sharedConfig].baseURL,[PhotoManager getUUID]];
    }
    return self;
}

- (NSMutableURLRequest *)BgUploadSetHeader{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:_url]];
    [request setHTTPMethod:@"POST"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", FormBoundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    return request ;
}

-(NSMutableURLRequest *)getRequest{
    if (_filePath) {
        NSString * str = [FileHash sha256HashOfFileAtPath:_filePath];
        self.digest = str;
        NSDictionary * dic = [NSDictionary dictionaryWithObject:str forKey:@"sha256"];
        NSMutableData *postData = [[NSMutableData alloc]init];//请求体数据
        for (NSString *key in dic) { //预留给多个参数
            
            NSString *pair = [NSString stringWithFormat:@"%@%@%@Content-Disposition: form-data; name=\"%@\"%@%@",FormStart,FormBoundary,FormEnd,key,FormEnd,FormEnd];
            [postData appendData:[pair dataUsingEncoding:NSUTF8StringEncoding]];
            id value = [dic objectForKey:key];
            if ([value isKindOfClass:[NSString class]]) {
                [postData appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
            }else if ([value isKindOfClass:[NSData class]]){
                [postData appendData:value];
            }
            [postData appendData:[FormEnd dataUsingEncoding:NSUTF8StringEncoding]];
        }
        self.tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"temp_file%@",[NSUUID UUID].UUIDString]];
        [[NSFileManager defaultManager] removeItemAtPath:self.tempFilePath error:nil];
        //添加formdata 起始分隔符
        NSString *fileDesc = [NSString stringWithFormat:@"%@%@%@Content-Disposition:form-data;name=\"%@\"; filename=\"%@\"%@Content-Type:%@%@%@",FormStart,FormBoundary,FormEnd,@"file",@"file",FormEnd,@"image/jpeg",FormEnd,FormEnd];
        [postData appendData:[fileDesc dataUsingEncoding:NSUTF8StringEncoding]];
        [postData writeToFile:self.tempFilePath atomically:YES];
        [self createTempFile];
        //添加结束分隔符
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:_tempFilePath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[[NSString stringWithFormat:@"%@%@%@%@%@",FormEnd,FormStart,FormBoundary,FormStart,FormEnd] dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
        
        //创建请求
        NSMutableURLRequest * request = [self BgUploadSetHeader];
        [request setValue:[NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[[NSURL fileURLWithPath:_tempFilePath] path] error:nil];
        [request setValue:[NSString stringWithFormat:@"%lu",[fileAttributes[NSFileSize] unsignedLongValue]] forHTTPHeaderField:@"Content-Length"];
//        request.HTTPBodyStream = [NSInputStream inputStreamWithFileAtPath:_tempFilePath];
        return request;
    }
    return nil;
}

-(void)createTempFile{
//    NSFileManager * fm = [NSFileManager defaultManager];
//    [fm removeItemAtPath:_filePath error:nil];
//    NSString * tre = @"测试测试";
//    [tre writeToFile:_filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath: _filePath];
    [inputStream open];
    NSInteger maxLength = 128;
    uint8_t readBuffer [maxLength];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:_tempFilePath];
    //是否已经到结尾标识
    BOOL endOfStreamReached = NO;
    while (! endOfStreamReached)
    {
        NSInteger bytesRead = [inputStream read: readBuffer maxLength:maxLength];
        if (bytesRead == 0)
        {//文件读取到最后
            endOfStreamReached = YES;
        }
        else if (bytesRead == -1)
        {//文件读取错误
            NSLog(@"文件读取错误");
            endOfStreamReached = YES;
        }
        else
        {
            NSData * tempData =[NSData dataWithBytes:readBuffer length:bytesRead];
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:tempData];
        }
    }
    
    [fileHandle closeFile];
    [inputStream close];
    //删除源文件
    [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
}


#pragma mark - URLSessionDelegate
// 上传进度中
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    NSLog(@"\n%f / %f", (double)totalBytesSent,
          (double)totalBytesExpectedToSend);
}

// 上传完成
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    // 这里继续做下一个任务
    @weakify(self);
    self.completeBlock(error,session,weak_self.filePath,weak_self.tempFilePath);
//    [self BgUploadBeginNextTask];
}


// 后台传输完成，处理URLSession完成事件
-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    @weakify(self);
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([uploadTasks count] == 0) {
            if (MyAppDelegate.backgroundSessionCompletionHandler != nil) {
                // Copy locally the completion handler.
                void(^completionHandler)() = MyAppDelegate.backgroundSessionCompletionHandler;
                // Make nil the backgroundTransferCompletionHandler.
                MyAppDelegate.backgroundSessionCompletionHandler = nil;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionHandler();
                    // 这里继续做下一个任务
                    weak_self.completeBlock(nil,weak_self.session,weak_self.filePath,weak_self.tempFilePath);
                }];
            }
        }
        //
        
    }];
}
@end
