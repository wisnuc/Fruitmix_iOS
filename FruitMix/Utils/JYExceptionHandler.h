//
//  JYExceptionHandler.h
//  FruitMix
//
//  Created by 杨勇 on 16/7/7.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const UncaughtExceptionHandlerSignalKey;
extern NSString *const SingalExceptionHandlerAddressesKey;
extern NSString *const ExceptionHandlerAddressesKey;

@interface JYExceptionHandler : NSObject

+ (void)installExceptionHandler;
+ (NSArray *)backtrace;

@end
