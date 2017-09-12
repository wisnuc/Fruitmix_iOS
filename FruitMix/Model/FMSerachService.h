//
//  FMSerachService.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/7.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMSerachService : NSObject

@property (nonatomic) NSString * path;
@property (nonatomic) NSString * name;
@property (nonatomic) NSString * type;
@property (nonatomic) NSMutableArray * users;
@property (nonatomic) NSString * displayPath;
@property (nonatomic) NSString * hostName;
@property (nonatomic) NSString * ws215i;
@property (nonatomic) BOOL isReadly;
@property (nonatomic) NSURLSessionDataTask *task;
@end
