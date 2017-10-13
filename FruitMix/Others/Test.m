//
//  Test.m
//  FruitMix
//
//  Created by wisnuc-imac on 2017/10/13.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "Test.h"


@implementation Test
+(instancetype)shareManager{
    static Test * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}
- (instancetype)init{
    if (self = [super init]) {
        _arr = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}
@end
