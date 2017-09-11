//
//  FLFilesVC.h
//  FruitMix
//
//  Created by 杨勇 on 16/8/31.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLBaseVC.h"

@interface FLFilesVC : FLBaseVC

@property (nonatomic) NSString * parentUUID;
- (void)shareFiles;
@end
