//
//  FMDeleteShareAPI.h
//  FruitMix
//
//  Created by 杨勇 on 16/9/27.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"

@interface FMDeleteShareAPI : JYBaseRequest

@property (nonatomic) NSString * shareId;


+(instancetype)apiWithDeleteShareId:(NSString *)shareId;

@end
