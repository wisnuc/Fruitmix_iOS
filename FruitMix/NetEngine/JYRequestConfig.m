//
//  JYRequestConfig.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/1.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYRequestConfig.h"

@implementation JYRequestConfig

+ (instancetype)sharedConfig{
    static JYRequestConfig  * config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[self alloc]init];
    });
    return config;
}

-(instancetype)init{
    if (self = [super init]) {
        self.baseURL = BASE_URL;
    }
    return self;
}


-(void)setBaseURL:(NSString *)baseURL{
    _baseURL = baseURL;
    [[NSUserDefaults standardUserDefaults] setObject:baseURL forKey:BASE_URL_STR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
