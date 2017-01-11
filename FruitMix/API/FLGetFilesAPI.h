//
//  FLGetFilesAPI.h
//  FruitMix
//
//  Created by 杨勇 on 16/9/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"

@interface FLGetFilesAPI : JYBaseRequest

@property (nonatomic) NSString * fileUUID;

+(instancetype)apiWithFileUUID:(NSString *)fileUUID;

@end
