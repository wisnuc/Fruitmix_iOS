//
//  FMUserLoginInfo.h
//  FruitMix
//
//  Created by JackYang on 2017/2/15.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMDTObject.h"

@interface FMUserLoginInfo : FMDTObject

@property (nonatomic) NSString * userName; // 昵称

@property (nonatomic) NSString * uuid; // user uuid

@property (nonatomic) NSString * deviceId; //同步照片 位置

@property (nonatomic) NSString * jwt_token; //用户登录令牌

@property (nonatomic) NSString * sn_address; // nas id

@property (nonatomic) NSString * bonjour_name;//mdns name

@end
