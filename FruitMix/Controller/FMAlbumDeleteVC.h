//
//  FMAlbumDeleteVC.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/6.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMBaseViewController.h"

typedef void(^delCompleteBlock)(NSMutableArray * arr);

@interface FMAlbumDeleteVC : FMBaseViewController

@property (nonatomic) id<FMMediaShareProtocol> album;

@property (nonatomic) delCompleteBlock block;

@end
