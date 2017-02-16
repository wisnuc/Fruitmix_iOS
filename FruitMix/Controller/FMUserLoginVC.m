//
//  FMUserLoginVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/17.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMUserLoginVC.h"

#import "NavViewController.h"
#import "FMShareViewController.h"
#import "FMAlbumsViewController.h"
#import "FMPhotosViewController.h"
#import "FMSlideMenuControllerViewController.h"
#import "FMSlideMenuController.h"
#import "TabBarViewController.h"

#import "RDVTabBarItem.h"
#import "FMGetJWTAPI.h"
#import "FMPhotoDataSource.h"

@interface FMUserLoginVC ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userNameLb;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLb;
@property (weak, nonatomic) IBOutlet UITextField *passWordTF;

@property (weak, nonatomic) IBOutlet UIView *line2View;

@end

@implementation FMUserLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"登录";
    self.view.backgroundColor = UICOLOR_RGB(0xe2e2e2);
    if (self.user) {
        self.userNameLb.text = _user.username;
        self.userImageView.image = [UIImage imageForName:_user.username size:self.userImageView.bounds.size];
    }
    if (self.service) {
        self.deviceNameLb.text = _service.name;
    }
    self.line2View.backgroundColor = UICOLOR_RGB(0xf57e00);
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.passWordTF becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.passWordTF resignFirstResponder];
}


- (IBAction)loginBtnClick:(UIButton *)sender {
    
//    if (IsNilString(_passWordTF.text)) {
//        [SXLoadingView showAlertHUD:@"请输入密码" duration:1];
//        return;
//    }
    sender.userInteractionEnabled = NO;
    [SXLoadingView showProgressHUD:@"正在登陆"];
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    NSString * UUID = [NSString stringWithFormat:@"%@:%@",_user.uuid,IsNilString(_passWordTF.text)?@"":_passWordTF.text];
    NSString * Basic = [UUID base64EncodedString];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@",Basic] forHTTPHeaderField:@"Authorization"];
    [manager GET:[NSString stringWithFormat:@"%@token",_service.path] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SXLoadingView hideProgressHUD];
        [self loginToDoWithResponse:responseObject];
        sender.userInteractionEnabled = YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SXLoadingView hideProgressHUD];
        NSHTTPURLResponse * res = (NSHTTPURLResponse *)task.response;
        [SXLoadingView showAlertHUD:[NSString stringWithFormat:@"登录失败:%ld",res.statusCode] duration:1];
        sender.userInteractionEnabled = YES;
    }];
}

//登录完成 做的事
-(void)loginToDoWithResponse:(id)response{
    NSString * token = response[@"token"];
    //判断是否为同一用户退出后登录
    
    if (!IsNilString(DEF_UUID) && !IsEquallString(DEF_UUID, _user.uuid) ) {
        [FMDBControl reloadTables];
        [FMDBControl asyncLoadPhotoToDB];
        //清除deviceID
        FMConfigInstance.deviceUUID = @"";//清除deviceUUID
    }
    FMConfigInstance.userToken = token;
    FMConfigInstance.userUUID = _user.uuid;
    //更新图库
    JYRequestConfig * config = [JYRequestConfig sharedConfig];
    config.baseURL = self.service.path;
    
    //重启photoSyncer
    [PhotoManager shareManager].canUpload = YES;
    
    //重置数据
    [MyAppDelegate resetDatasource];
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //保存用户信息
        FMUserLoginInfo * info = [FMUserLoginInfo new];
        info.userName = _user.username;
        info.uuid = _user.uuid;
        info.deviceId = [PhotoManager getUUID];
        info.jwt_token = token;
        info.bonjour_name = _service.hostName;
        [FMDBControl addUserLoginInfo:info];
    });
    
    //组装UI
    MyAppDelegate.sharesTabBar = [[RDVTabBarController alloc]init];
    [MyAppDelegate initWithTabBar:MyAppDelegate.sharesTabBar];
    [MyAppDelegate.sharesTabBar setSelectedIndex:0];
    MyAppDelegate.filesTabBar = nil;
    [UIApplication sharedApplication].keyWindow.rootViewController = MyAppDelegate.sharesTabBar;
   
}


- (IBAction)handleTapGesture:(id)sender {
    [self.passWordTF resignFirstResponder];
}
@end
