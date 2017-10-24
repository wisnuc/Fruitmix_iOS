//
//  GetStaionInfoAPI.h
//  FruitMix
//
//  Created by wisnuc-imac on 2017/10/23.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"

@interface GetStaionInfoAPI : JYBaseRequest
@property (nonatomic) NSString *servicePath;
+(instancetype)apiWithServicePath:(NSString *)servicePath;
@end
