//
//  UploadSessionBackgound.m
//  icoffer
//
//  Created by jackyang on 16-07-20.
//  Copyright (c) 2016年 jackyang. All rights reserved.
//

#import "UploadSessionBackgound.h"

@implementation UploadSessionBackgound
@synthesize urlSession,sesssionDataTask,sessioinDelegate,startTime;

-(NSURLSession *)urlSession
{
    static NSURLSession *session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *backgroundConfigObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.jackyang.uploader"];
        session = [NSURLSession sessionWithConfiguration:backgroundConfigObject delegate:self delegateQueue:nil];
    });
    return session;
}

-(void)startBackground:(NSMutableURLRequest *)request
{
    self.sesssionDataTask = [self.urlSession uploadTaskWithStreamedRequest:request];
    [self.sesssionDataTask resume];
    self.startTime = [[NSDate date] timeIntervalSince1970];
}


-(void)stopUploadBackground
{
    [self.sesssionDataTask cancel];
}

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data;
{
    if(data==nil)
    {
        [self.sessioinDelegate requestUploadFinishDictionary:nil];
        return;
    }
    NSString * str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSInteger  i = ((NSHTTPURLResponse *)dataTask.response).statusCode;
    NSLog(@"statusCode: %ld   %@",(long)i,str);
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@"dict:%@",dict);
    [self.sessioinDelegate requestUploadFinishDictionary:dict];
    double endTime = [[NSDate date] timeIntervalSince1970];
    endTime  = fabs(endTime-self.startTime);
    double length = [data length];
    NSString *sudu = [self getFormatSudu:endTime lenght:length];
    NSLog(@"上传速度为:%@",sudu);
}



- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"无效");
    [self.sessioinDelegate requestUploadFinishDictionary:nil];
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
//    NSInteger  i = ((NSHTTPURLResponse *)task.response).statusCode;
    NSLog(@"成功");
}

-(NSString *)getFormatSudu:(double)endTime lenght:(double)lenght
{
    NSString *sudu;
    if(endTime<0.0001)
    {
        endTime = 0.0001;
    }
    endTime = lenght/endTime;
    if(endTime/1024.0<1024)
    {
        endTime = endTime/1024.0;
        sudu = [NSString stringWithFormat:@"%fKb/s",endTime];
    }
    else if(endTime/(1024.0*1024.0)<1024)
    {
        endTime = endTime/(1024.0*1024.0);
        sudu = [NSString stringWithFormat:@"%fMb/s",endTime];
    }
    else if(endTime/(1024.0*1024.0*1024.0)<1024)
    {
        endTime = endTime/(1024.0*1024.0*1024.0);
        sudu = [NSString stringWithFormat:@"%fGb/s",endTime];
    }
    else if(endTime/(1024.0*1024.0*1024.0*1024.0)<1024)
    {
        endTime = endTime/(1024.0*1024.0*1024.0*1024.0);
        sudu = [NSString stringWithFormat:@"%ftb/s",endTime];
    }
    return sudu;
}

@end
