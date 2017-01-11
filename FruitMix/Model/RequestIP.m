//
//  RequestIP.m
//  FruitMix
//
//  Created by JackYang on 16/3/15.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "RequestIP.h"

static RequestIP *shardRequestIP=nil;

@implementation RequestIP
+(RequestIP*)shardRequestIP{
    if (!shardRequestIP) {
        shardRequestIP=[[RequestIP alloc]init];
    }
    return shardRequestIP;
}

@end
