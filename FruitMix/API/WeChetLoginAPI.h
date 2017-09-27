//
//  WeChetLoginAPI.h
//  FruitMix
//
//  Created by wisnuc-imac on 2017/9/26.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"

@interface WeChetLoginAPI : JYBaseRequest
@property (nonatomic)NSString *code;
+ (instancetype)apiWithCode:(NSString *)code;
@end
