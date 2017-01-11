//
//  FMHandLoginVC.h
//  FruitMix
//
//  Created by 杨勇 on 16/7/7.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMSerachService.h"

typedef void(^HandlecompleteBlock)(FMSerachService * service);

@interface FMHandLoginVC : FABaseVC
@property (nonatomic) HandlecompleteBlock block;
@end
