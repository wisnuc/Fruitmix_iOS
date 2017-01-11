//
//  UploadSessionBackgound.h
//  icoffer
//
//  Created by jackyang on 14-10-20.
//  Copyright (c) 2014年 jackyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UploadSessionBackgoundDelegate <NSObject>

-(void)requestUploadFinishDictionary:(NSDictionary *)dictionary;

@end

typedef void(^UploadSessionCompleteBlock)(BOOL success);

@interface UploadSessionBackgound : NSObject<NSURLSessionDataDelegate>

@property(nonatomic, strong) NSURLSession *urlSession;
@property(nonatomic, strong) NSURLSessionUploadTask *sesssionDataTask;
@property(nonatomic, weak) id<UploadSessionBackgoundDelegate> sessioinDelegate;
@property(nonatomic, assign) double startTime;

@property(nonatomic, copy) UploadSessionCompleteBlock completeBlock;

-(void)startBackground:(NSMutableURLRequest *)request;
-(void)stopUploadBackground;

@end
