//
//  FLShareModel.m
//  FruitMix
//
//  Created by 杨勇 on 16/10/9.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FLShareModel.h"

@implementation FLShareModel

-(BOOL)isFile{
    if (IsEquallString(_type, @"file")) {
        return YES;
    }
    return NO;
}

@end
