//
//  RequestIP.h
//  FruitMix
//
//  Created by JackYang on 16/3/15.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestIP : NSObject

@property (nonatomic) NSString * ip;

+(RequestIP*)shardRequestIP;
@end
