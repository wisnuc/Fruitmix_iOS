//
//  UserInfo.h
//  FruitMix
//
//  Created by JackYang on 16/3/17.
//  Copyright © 2016年 WinSun. All rights reserved.
//
/**
 *  继承自UserModel ,功能 ： 详细用户信息
 */
#import "UserModel.h"

@interface UserInfo : UserModel

@property (nonatomic) BOOL isAdmin;

@property (nonatomic) BOOL isFirstUser;

@property (nonatomic) NSString * type;

@property (nonatomic) NSString * email;

@end
