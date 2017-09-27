//
//  FMConfiguation.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/21.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FMConfigInstance [FMConfiguation shareConfiguation]

#define shouldUplod(block)\
if ([FMConfiguation shareConfiguation].shouldUpload) {\
block();\
} \

@interface FMConfiguation : NSObject

@property (nonatomic) BOOL isDebug;
@property (nonatomic) BOOL shouldUpload;
@property (nonatomic) NSString * userHome;
@property (nonatomic) NSString * userToken;
@property (nonatomic) NSString * deviceUUID;
@property (nonatomic) NSString * userUUID;
@property (nonatomic) NSString * nickName;
@property (nonatomic) BOOL isCloud;

@property (nonatomic) NSMutableDictionary * usersDic;//存储所有用户的map

+(instancetype)shareConfiguation;

-(NSString *)getUserNameWithUUID:(NSString *)uuid;
-(void)cleanTheUserAllLocalCache;


@end
