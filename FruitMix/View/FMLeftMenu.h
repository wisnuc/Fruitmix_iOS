//
//  FMLeftMenu.h
//  MenuDemo
//
//  Created by 杨勇 on 16/7/1.
//  Copyright © 2016年 Lying. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DIDSELECT_NOTIFY @"didselectnotify"

@protocol FMLeftMenuDelegate <NSObject>

-(void)LeftMenuViewClick:(NSInteger)tag andTitle:(NSString *)title;

@end

@interface FMLeftMenu : UIView

@property (nonatomic) id<FMLeftMenuDelegate> delegate;

@property (retain, nonatomic) NSMutableArray *menus;
@property (retain, nonatomic) NSMutableArray *imageNames;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userHeaderIV;
@property (weak, nonatomic) IBOutlet UITableView *settingTabelView;

@end
