//
//  FLDrivesModel.h
//  FruitMix
//
//  Created by 杨勇 on 16/9/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLDrivesModel : NSObject

@property (nonatomic) NSString * label;

@property (nonatomic) BOOL fixedOwner;

@property (nonatomic) NSString * URI;

@property (nonatomic) NSString * uuid;

@property (nonatomic) NSArray * owner;

@property (nonatomic) NSArray * writelist;

@property (nonatomic) NSArray * readlist;

@property (nonatomic) BOOL * cache;

@property (nonatomic) NSString * rootpath;

@property (nonatomic) NSString * cacheState;

@property (nonatomic) NSInteger uuidMapSize;

@property (nonatomic) NSInteger hashMapSize;

@property (nonatomic) NSInteger hashlessSize;

@property (nonatomic) NSInteger sharedSize;

@end
