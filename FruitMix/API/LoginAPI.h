//
//  LoginAPI.h
//  FruitMix
//
//  Created by wisnuc-imac on 2017/9/26.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"

@interface LoginAPI : JYBaseRequest
@property (nonatomic) NSString *basic;
@property (nonatomic) NSString *servicePath;
+(instancetype)apiWithServicePath:(NSString *)servicePath AuthorizationBasic:(NSString *)basic;
@end
