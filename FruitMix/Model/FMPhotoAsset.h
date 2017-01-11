//
//  FMPhotoAsset.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/20.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IDMPhoto.h"

@interface FMPhotoAsset : IDMPhoto

@property (nonatomic) NSString * degist;

@property (nonatomic) NSString * localId;

@property (nonatomic) UIImage * thumbImage;

@property (nonatomic) UIImage * fullImage;

@property (nonatomic) NSDate * createtime;

@property (nonatomic) NSString * createTimeString;

@property (nonatomic) BOOL shouldRequestThumbnail;

-(NSString *)getPhotoHashSync;




@end
