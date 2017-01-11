//
//  JYRequestConfig.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/1.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JYRequestConfig : NSObject

+ (instancetype)sharedConfig;

//服务器地址
@property (nonatomic) NSString * baseURL;

//文件服务器地址
@property (nonatomic) NSString * cdnURL;

//加密策略
@property (nonatomic) AFSecurityPolicy * securityPolocy;



@end
