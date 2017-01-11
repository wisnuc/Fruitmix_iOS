//
//  FMCalculateHelper.m
//  FruitMix
//
//  Created by 杨勇 on 16/11/7.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMCalculateHelper.h"

@implementation FMCalculateHelper

+ (instancetype)sharedInstance
{
    static FMCalculateHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[FMCalculateHelper alloc] init];
    });
    return _sharedInstance;
}

@end
