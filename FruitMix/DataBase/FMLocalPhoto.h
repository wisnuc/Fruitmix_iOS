//
//  FMLocalPhoto.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/21.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMDTObject.h"
@interface FMLocalPhoto : FMDTObject

@property (nonatomic) NSString * localIdentifier; //本地识别符

@property (nonatomic) NSString * degist;//sha256

@property (nonatomic) NSDate * uploadTime; //上传时间

@property (nonatomic) NSDate * createDate; //创建时间

@property (nonatomic) NSString * city; //市级

@property (nonatomic) NSString * country; //国级

@property (nonatomic) NSString * subLocality;//区级 如：浦东新区

@property (nonatomic) double longitude; //经度

@property (nonatomic) double latitude; //纬度

@end
