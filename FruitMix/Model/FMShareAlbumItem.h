//
//  FMShareAlbumItem.h
//  FruitMix
//
//  Created by 杨勇 on 16/5/18.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  使用在share的Album的items
 */

@interface FMShareAlbumItem : IDMPhoto

//hash
@property (nonatomic) NSString * digest;//digest

@property (nonatomic) BOOL isLocal;
//@property (nonatomic) NSString * type; //判断是否为本地图片 {NetPhoto  LocalPhoto}

@property (nonatomic) NSDate * createtime;//用来排序

@property (nonatomic) UIImage * thumbImage;

@property (nonatomic) NSString * shareid;

@property (nonatomic) NSString * ctime;

@property (nonatomic) NSString * creator;

@property (nonatomic) BOOL shouldRequestThumbnail;

@end
