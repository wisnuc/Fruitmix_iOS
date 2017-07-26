//
//  FMUsers.h
//  FruitMix
//
//  Created by 杨勇 on 16/5/31.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMDTObject.h"
@interface Users : FMDTObject
//用户名
@property (nonatomic) NSString * username;
//uuid
@property (nonatomic) NSString * uuid;
//用户头像url
@property (nonatomic) NSString * avatar;

@property (nonatomic) int unixUID;

@end
@interface FMUsers : FMDTObject
@property (nonatomic) NSMutableArray *users;

//用户名
@property (nonatomic) NSString * username;
//uuid
@property (nonatomic) NSString * uuid;
//用户头像url
@property (nonatomic) NSString * avatar;

@property (nonatomic) int unixUID;

@end
