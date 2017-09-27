//
//  GetStationAPI.h
//  FruitMix
//
//  Created by wisnuc-imac on 2017/9/26.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"

@interface GetStationAPI : JYBaseRequest
@property (nonatomic)NSString *GUID;
+ (instancetype)apiWithGUID:(NSString *)GUID;
@end
