//
//  FMUpdateSharesAPI.h
//  FruitMix
//
//  Created by 杨勇 on 16/9/26.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"

@interface FMUpdateSharesAPI : JYBaseRequest

@property (nonatomic) NSString * shareId;

@property (nonatomic) NSArray * param;

+(instancetype)apiWithShareId:(NSString *)shareId andParam:(NSArray *)param;

@end
