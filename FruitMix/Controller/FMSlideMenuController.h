//
//  FMSlideMenuController.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageHeaderView.h"
#import "FMLoginVC.h"

typedef enum : NSInteger{
    LeftMenuInfo = 0,
    LeftMenuOwnCloud,
    LeftMenuUserSetting,
    LeftMenuSetting,
    LeftMenuHelp,
    LeftMenuOutLogin
} LeftMenu;

@protocol SlideMenuDelegate <NSObject>

@required
-(void)changeViewController:(LeftMenu) menu;

@end

@interface FMSlideMenuController : UIViewController<SlideMenuDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) NSArray *menus;
@property (retain, nonatomic) NSArray *imageNames;
@property (retain, nonatomic) UIViewController *Info;
@property (retain, nonatomic) UIViewController *OwnCloud;
@property (retain, nonatomic) UIViewController *UserSetting;
@property (retain, nonatomic) UIViewController *Setting;
@property (retain, nonatomic) UIViewController *Help;

@property (retain, nonatomic) FMLoginVC * zhuxiao;

@property (retain, nonatomic) ImageHeaderView *imageHeaderView;

@end
