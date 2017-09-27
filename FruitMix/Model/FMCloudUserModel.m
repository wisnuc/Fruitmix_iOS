//
//  FMCloudUserModel.m
//  FruitMix
//
//  Created by wisnuc-imac on 2017/9/27.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMCloudUserModel.h"

@implementation FMCloudUserModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"guid" : @"id"};
}
@end
