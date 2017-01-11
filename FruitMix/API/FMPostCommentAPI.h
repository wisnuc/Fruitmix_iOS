//
//  FMPostCommentAPI.h
//  FruitMix
//
//  Created by 杨勇 on 16/5/18.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"
@interface FMPostCommentAPI : JYBaseRequest

@property (nonatomic) NSDictionary * param;


-(instancetype)initWithComment:(NSString *)comment andPhotoDigest:(NSString *)digest andShareId:(NSString *)shareid;

+(void)postNewCommentWithComment:(NSString *)comment andPhotoDigest:(NSString *)digest andShareId:(NSString *)shareid andCompleteBlock:(void(^)(BOOL success,id response))block;
@end
