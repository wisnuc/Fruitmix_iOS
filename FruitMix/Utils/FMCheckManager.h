//
//  FMCheckManager.h
//  FruitMix
//
//  Created by 杨勇 on 16/8/4.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMCheckManager : NSObject

+(instancetype)shareCheckManager;

- (void) beginSearchingWithBlock:(void (^)(NSArray * discoveredServers))block;

// 从Service 翻译出ip
+(NSString *)serverIPFormService:(NSNetService *)service;

//测试服务器上 当前用户是否状态正常
+(BOOL)testServerWithIP:(NSString *)ip andToken:(NSString *)token;
@end
