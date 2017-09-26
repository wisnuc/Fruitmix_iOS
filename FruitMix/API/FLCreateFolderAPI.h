//
//  FLCreateFolderAPI.h
//  FruitMix
//
//  Created by 杨勇 on 16/10/25.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"

@interface FLCreateFolderAPI : JYBaseRequest

@property (nonatomic) NSString * parentId;

+(instancetype)apiWithParentUUID:(NSString *)folderUUID;
@end
