//
//  FMUploadHelper.m
//  FruitMix
//
//  Created by 杨勇 on 16/5/18.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMUploadHelper.h"

@implementation FMUploadHelper

+ (instancetype)sharedInstance
{
    static FMUploadHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[FMUploadHelper alloc] init];
    });
    return _sharedInstance;
}


@end
