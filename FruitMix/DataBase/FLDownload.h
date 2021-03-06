//
//  FLDownload.h
//  FruitMix
//
//  Created by 杨勇 on 16/10/10.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMDTObject.h"
#import "TYDownloadModel.h"

@interface FLDownload : FMDTObject

@property (nonatomic) NSString * name;

@property (nonatomic) NSString * downloadtime;

@property (nonatomic) NSString * uuid;

@property (nonatomic) unsigned long long size;//文件大小

@property (nonatomic) NSString * userId;//用户id
    
@property (nonatomic,strong) NSString * filePath;

@property (nonatomic,strong) TYDownloadModel *model;

@end
