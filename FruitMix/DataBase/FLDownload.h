//
//  FLDownload.h
//  FruitMix
//
//  Created by 杨勇 on 16/10/10.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMDTObject.h"

@interface FLDownload : FMDTObject

@property (nonatomic) NSString * name;

@property (nonatomic) NSString * downloadtime;

@property (nonatomic) NSString * uuid;

@property (nonatomic) NSString * size;//文件大小

@property (nonatomic) NSString * userId;//用户id

@end
