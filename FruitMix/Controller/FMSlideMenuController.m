//
//  FMSlideMenuController.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMSlideMenuController.h"
#import "FMInfo.h"
#import "FMHelp.h"
#import "FMSetting.h"
#import "FMOwnCloud.h"
#import "FMUserSetting.h"
#import "BaseTableViewCell.h"


@interface FMSlideMenuController ()

@end

@implementation FMSlideMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
}

-(void)initData{
    _menus = @[@"个人信息", @"我的私有云", @"用户管理", @"设置", @"帮助",@"注销登录"];
    _imageNames = @[@"personal",@"cloud",@"user",@"set",@"help",@"cancel"];
    _Info = [[FMInfo alloc]init];
    NavViewController * nav1 = [[NavViewController alloc]initWithRootViewController:_Info];
    _Info = nav1;
    _OwnCloud = [[FMOwnCloud alloc]init];
    NavViewController * nav2 = [[NavViewController alloc]initWithRootViewController:_OwnCloud];
    _OwnCloud = nav2;
    _UserSetting = [[FMUserSetting alloc]init];
    NavViewController * nav3 = [[NavViewController alloc]initWithRootViewController:_UserSetting];
    _UserSetting = nav3;
    
    _Setting = [[FMSetting alloc]init];
    NavViewController * nav4 = [[NavViewController alloc]initWithRootViewController:_Setting];
    _Setting = nav4;
    
    _Help = [[FMHelp alloc]init];
    NavViewController * nav5 = [[NavViewController alloc]initWithRootViewController:_Help];
    _Help = nav5;
    
    _zhuxiao = [[FMLoginVC alloc]init];
    
    [self.tableView registerClass:[BaseTableViewCell class] forCellReuseIdentifier:@"BaseCell"];
    self.imageHeaderView = (ImageHeaderView *)[[[NSBundle mainBundle] loadNibNamed:@"ImageHeaderView" owner:nil options:nil] firstObject];
    self.imageHeaderView.frame = CGRectMake(0, 0, self.view.jy_Width, 178);
    [self.view  addSubview:self.imageHeaderView];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.imageHeaderView.frame = CGRectMake(0, 0, self.view.frame.size.width, 178);
    [self.view layoutIfNeeded];
}

-(void)changeViewController:(LeftMenu) menu {
//    switch (menu) {
//        case LeftMenuInfo:
//            [self.slideMenuController changeMainViewController:self.Info close:YES];
//            break;
//        case LeftMenuSetting:
//            [self.slideMenuController changeMainViewController:self.Setting close:YES];
//            break;
//        case LeftMenuUserSetting:
//            [self.slideMenuController changeMainViewController:self.UserSetting close:YES];
//            break;
//        case LeftMenuHelp:
//            [self.slideMenuController changeMainViewController:self.Help close:YES];
//            break;
//        case LeftMenuOwnCloud:
//            [self.slideMenuController changeMainViewController:self.OwnCloud close:YES];
//            break;
//        case LeftMenuOutLogin:{
//            [SXLoadingView showProgressHUD:@"正在注销"];
//            NSUserDefaults * defa = [NSUserDefaults  standardUserDefaults];
//            [defa setObject:@"" forKey:UserToken_STR];
//            [defa synchronize];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [SXLoadingView hideProgressHUD];
//                FMLoginVC * vc = [[FMLoginVC alloc]init];
//                vc.title = @"搜索附近设备";
//                NavViewController *nav = [[NavViewController alloc] initWithRootViewController:vc];
//                [UIApplication sharedApplication].keyWindow.rootViewController = nav;
//            });
//        }
//            break;
//    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menus.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BaseTableViewCell *cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[BaseTableViewCell identifier]];
    [cell setData:_menus[indexPath.row] andImageName:_imageNames[indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self changeViewController:indexPath.row];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  [BaseTableViewCell height];
}


@end
