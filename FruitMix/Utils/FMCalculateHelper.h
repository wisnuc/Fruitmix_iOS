//
//  FMCalculateHelper.h
//  FruitMix
//
//  Created by 杨勇 on 16/11/7.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMCalculateHelper : NSObject

@property (copy, nonatomic) void (^singleSuccessBlock)(BOOL success,NSString * digest);

+ (instancetype)sharedInstance;

@end
