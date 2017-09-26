//
//  JYNetEngine.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/1.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JYBaseRequest.h"
#import "AFNetworking.h"

@interface JYNetEngine : NSObject

+(JYNetEngine *)sharedInstance;

-(void)addRequest:(id<JYRequestDelegate>)request;
-(void)cancleRequest:(id<JYRequestDelegate>)request;
-(void)cancleAllRequest;
-(void)addFormDataRequest:(id<JYRequestDelegate>)request formDataBlock:(JYRequestFormDataBlock)formDataBlock;

// 合成 全的网址 
-(NSString *)bulidRequestURL:(id<JYRequestDelegate>)request;
@end
