//
//  FLGetDirveEntryAPI.h
//  FruitMix
//
//  Created by wisnuc-imac on 2017/9/25.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"

@interface FLGetDirveEntryAPI : JYBaseRequest
@property (nonatomic) NSString * uuid;
+(instancetype)apiWithUUID:(NSString *)UUID;
@end
