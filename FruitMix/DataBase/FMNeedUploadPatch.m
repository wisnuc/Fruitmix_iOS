//
//  FMNeedUploadPatch.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/27.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMNeedUploadPatch.h"

@implementation FMNeedUploadPatch

-(instancetype)init{
    self = [super init];
    if (self) {
        self.localid = FMDT_UUID();
    }
    return self;
}

+ (NSString *)primaryKeyFieldName {
    return @"localid";
}

@end
