//
//  FMFileUploadInfo.h
//  FruitMix
//
//  Created by 杨勇 on 16/12/27.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^TaskComlpeteBlock)(NSError * error,NSURLSession * session,NSString * filePath,NSString * tempFilePath);

@interface FMFileUploadInfo : NSObject<NSURLSessionDelegate>

@property (nonatomic) NSString * filePath;

@property (nonatomic) NSString * digest;

@property (nonatomic) NSString * tempFilePath;

@property (nonatomic) NSURLSessionTask * task;

@property (nonatomic) NSURLSession * session;

@property (nonatomic ,copy) TaskComlpeteBlock completeBlock;

-(NSMutableURLRequest *)getRequest;

@end
