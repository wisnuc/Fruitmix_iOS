
//
//  FMGetUserInfo.m
//  FruitMix
//
//  Created by wisnuc on 2017/7/27.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMGetUserInfo.h"

@implementation FMGetUserInfo

+ (NSMutableArray *)getUsersInfo{
    NSMutableArray * arr = [NSMutableArray arrayWithArray:[FMDBControl getAllUserLoginInfo]];
    
    for (FMUserLoginInfo * info in arr) {
        if (IsEquallString(info.uuid, DEF_UUID)) {
            [arr removeObject:info];
            break;
        }
    }
    return arr;
}
@end
