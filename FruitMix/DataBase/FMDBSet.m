//
//  FMDBSet.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/21.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMDBSet.h"
//#import <Photos/Photos.h>
#import "FMMediaShareTask.h"

@implementation FMDBSet

- (FMDTContext *)photo {
    /**
     *  缓存FMDTContext对象,第一次创建时会自动生成表结构
     *  默认存储在默认会存储在沙盒下的Library/Caches/{Bundle Identifier}.db,
     *  如果想要对每一个用户生成一个库,可以自定义Path,
     *  使用[self cacheWithClass: dbPath:]方法
     */
    return [self cacheWithClass:[FMLocalPhoto class]];
}

-(FMDTContext *)nasPhoto{
      return [self cacheWithClass:[FMNASPhoto class]];
}

- (FMDTContext *)mediashare{
    return [self cacheWithClass:[FMMediaShare class]];
}

- (FMDTContext *)users{
    return [self cacheWithClass:[FMUsers class]];
}

- (FMDTContext *)ownerset{
    return [self cacheWithClass:[FMOwnerSet class]];
}

-(FMDTContext *)needQuickUploadPhoto{
    return [self cacheWithClass:[FMNeedQuickUploadPhoto class]];
}

-(FMDTContext *)needUploadMediaShare{
    return [self cacheWithClass:[FMNeedUploadMediaShare class]];
}

-(FMDTContext *)needUploadComments{
    return [self cacheWithClass:[FMNeedUploadComments class]];
}

-(FMDTContext *)needUploadPatch{
    return [self cacheWithClass:[FMNeedUploadPatch class]];
}

-(FMDTContext *)download{
    return [self cacheWithClass:[FLDownload class]];
}

-(FMDTContext *)userInfo{
    return [self cacheWithClass:[FMUserInfo class]];
}

-(FMDTContext *)syncLogs{
    return [self cacheWithClass:[FMSyncLogs class]];
}

-(FMDTContext *)userLoginInfo{
    return [self cacheWithClass:[FMUserLoginInfo class]];
}

@end
