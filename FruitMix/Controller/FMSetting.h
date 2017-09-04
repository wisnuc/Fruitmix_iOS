//
//  FMSetting.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BackUpDelegate <NSObject>//协议
- (void)backUpIndex:(NSInteger)index;//协议方法
@end

@interface FMSetting : FABaseVC
@property (weak, nonatomic) IBOutlet UITableView *settingTableView;
@property (nonatomic, assign) id<BackUpDelegate>delegate;
- (instancetype)initPrivate;
@end
