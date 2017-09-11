//
//  FLSecondFilesVC.h
//  FruitMix
//
//  Created by 杨勇 on 16/9/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLFilesCell.h"
#import "FLDataSource.h"
#import "FABaseVC.h"

@interface FLSecondFilesVC : FABaseVC

@property (nonatomic) NSString * parentUUID;

@property (nonatomic) FLFliesCellStatus cellStatus;

@property (nonatomic, strong) NSString *name;

- (void)shareFiles;
@end
