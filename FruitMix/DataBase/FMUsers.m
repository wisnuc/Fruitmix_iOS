//
//  FMUsers.m
//  FruitMix
//
//  Created by 杨勇 on 16/5/31.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMUsers.h"

@implementation Users
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"users" : [Users class]};
}
@end

@implementation FMUsers
+ (NSString *)primaryKeyFieldName {
    return @"uuid";
}


@end
