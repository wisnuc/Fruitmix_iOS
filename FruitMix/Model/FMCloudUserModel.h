//
//  FMCloudUserModel.h
//  FruitMix
//
//  Created by wisnuc-imac on 2017/9/27.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMBaseModel.h"

@interface FMCloudUserModel : FMBaseModel
//用户名
@property (nonatomic) NSString * nickName;
//uuid
@property (nonatomic) NSString * guid;
//用户头像url
@property (nonatomic) NSString * avatarUrl;

@end
