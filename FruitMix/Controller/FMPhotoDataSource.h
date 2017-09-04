//
//  FMPhotoDataSource.h
//  FruitMix
//
//  Created by 杨勇 on 16/8/24.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FMPhotoDatasourceLoadFinishNotify  @"FMPhotoDatasourceLoadFinishNotify"

@protocol FMPhotoDataSourceDelegate <NSObject>

-(void)dataSourceFinishToLoadPhotos;

@end

@interface FMPhotoDataSource : NSObject

@property (nonatomic) BOOL isFinishLoading;

@property (nonatomic) id<FMPhotoDataSourceDelegate> delegate;
@property (nonatomic) NSMutableArray  * dataSource;
@property (nonatomic) NSMutableArray * imageArr;
@property (nonatomic) NSMutableArray * timeArr;
@property (nonatomic) NSMutableArray * netphotoArr;

+(instancetype)shareInstance;

-(void)initPhotosIsRefrash;
- (void)getNetPhotos;
@end
