//
//  FLFilesModel.h
//  FruitMix
//
//  Created by 杨勇 on 16/9/2.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLFilesModel : NSObject

@property (nonatomic) NSString * name; // 名字

@property (nonatomic) long long mtime; //修改时间

@property (nonatomic) NSString * type; //文件格式

@property (nonatomic) NSArray * owner; //所有者

@property (nonatomic) NSString * uuid;

@property (nonatomic) NSInteger * size; //文件大小

//@property (readonly,nonatomic) BOOL isFile;
@property (nonatomic) NSString * parent;
@property (nonatomic) NSString * parUUID;

@end

