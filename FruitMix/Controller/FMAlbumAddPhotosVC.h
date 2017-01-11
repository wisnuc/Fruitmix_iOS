//
//  FMAlbumAddPhotosVC.h
//  FruitMix
//
//  Created by 杨勇 on 16/5/23.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMBaseViewController.h"

typedef void(^AddPhotosSuccessBlock)(NSArray * addArr);

@interface FMAlbumAddPhotosVC : FMBaseViewController

//之前选择的照片的数据 degist or localIDs
@property (nonatomic) NSMutableArray * historyPhotosArr;

@property (nonatomic) AddPhotosSuccessBlock addSuccessblock;

@property (nonatomic) FMMediaShare * share;

@end
