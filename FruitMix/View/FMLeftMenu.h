//
//  FMLeftMenu.h
//  MenuDemo
//
//  Created by 杨勇 on 16/7/1.
//  Copyright © 2016年 Lying. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DIDSELECT_NOTIFY @"didselectnotify"

@class FMUserLoginInfo;

@protocol FMLeftMenuDelegate <NSObject>

-(void)LeftMenuViewClickSettingTable:(NSInteger)tag andTitle:(NSString *)title;

-(void)LeftMenuViewClickUserTable:(FMUserLoginInfo *)info;

@end

@interface FMLeftMenu : UIView

@property (nonatomic) id<FMLeftMenuDelegate> delegate;

@property (nonatomic) BOOL isUserTableViewShow;

@property (retain, nonatomic) NSMutableArray *menus;
@property (retain, nonatomic) NSMutableArray *imageNames;
@property (weak, nonatomic) IBOutlet UIButton *dropDownBtn;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userHeaderIV;
@property (weak, nonatomic) IBOutlet UITableView *settingTabelView;
@property (weak, nonatomic) IBOutlet UITableView *usersTableView;

@property (nonatomic) NSMutableArray * usersDatasource;
@end
