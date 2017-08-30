//
//  FLFilesModel.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/2.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FLFilesModel.h"

@implementation FLFilesModel

-(BOOL)isFile{
    if (IsEquallString(_type, @"file")) {
        return YES;
    }
    return NO;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"filesHash": @"hash"
             };
}

@end
