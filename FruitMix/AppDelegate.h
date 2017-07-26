//
//  AppDelegate.h
//  FruitMix
//
//  Created by JackYang on 16/3/15.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMLeftMenu.h"
#import "FMLoginVC.h"
#import "MenuView.h"
#import "CWStatusBarNotification.h"
#import "RDVTabBarController.h"
#import "FMPhotoDataSource.h"
#import "FMMediaShareDataSource.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,NSURLSessionTaskDelegate>

@property (strong, nonatomic) UIWindow *window;

//left menu
@property (nonatomic)  FMLeftMenu * leftMenu;
@property (retain, nonatomic) UIViewController *Info;
@property (retain, nonatomic) UIViewController *OwnCloud;
@property (retain, nonatomic) UIViewController *UserSetting;
@property (retain, nonatomic) UIViewController *Setting;
@property (retain, nonatomic) UIViewController *Help;
@property (retain, nonatomic) UIViewController *downAndUpLoadManager;
@property (retain, nonatomic) FMLoginVC * zhuxiao;
@property (nonatomic) MenuView * menu;

@property (assign, nonatomic) BOOL isBackground; //判读是否是后台运行

@property (strong, nonatomic) dispatch_block_t backgroundSessionCompletionHandler;
@property (strong, nonatomic) dispatch_block_t didEnterBackgroundHandler;

@property (nonatomic) NSMutableDictionary * completionHandlerDictionary;

@property (nonatomic) CWStatusBarNotification *notification;//nav notify
@property (nonatomic) CWStatusBarNotification *statusBarNotification; //statusbar notify

@property (nonatomic) FMPhotoDataSource * photoDatasource;
@property (nonatomic) FMMediaShareDataSource * mediaDataSource;

@property (nonatomic) RDVTabBarController * sharesTabBar;
@property (nonatomic) RDVTabBarController * filesTabBar;


-(void)initWithTabBar:(RDVTabBarController *)tabbar;

-(void)resetDatasource;

-(UIView *)notifyViewWithMessage:(NSString *)message;

-(void)skipToLogin;

-(void)reloadLeftUsers;
@end

