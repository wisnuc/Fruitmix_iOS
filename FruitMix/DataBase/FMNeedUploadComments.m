//
//  FMNeedUploadComments.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/26.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMNeedUploadComments.h"

@implementation FMNeedUploadComments

-(long long)datatime{
    return self.createDate;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.commentId = FMDT_UUID();
    }
    return self;
}

+ (NSString *)primaryKeyFieldName {
    return @"commentId";
}

@end
