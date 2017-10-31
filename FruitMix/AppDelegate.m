//
//  AppDelegate.m
//  FruitMix
//
//  Created by JackYang on 16/3/15.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "AppDelegate.h"

#import "NavViewController.h"
#import "FMShareViewController.h"
#import "FMAlbumsViewController.h"
#import "FMPhotosViewController.h"
#import "RDVTabBarItem.h"

#import "FMInfo.h"
#import "FMUserEditVC.h"
#import "FMHelp.h"
#import "FMSetting.h"
#import "FMOwnCloud.h"
#import "FMUserSetting.h"
#import "BackgroundRunner.h"
#import "FMUserLoginSettingVC.h"

#import "RRFPSBar.h"
#import "FLFilesVC.h"
#import "FLShareVC.h"
#import "FLLocalFIleVC.h"
#import "FMCheckManager.h"
#import "FMGetThumbImage.h"

#import <CoreTelephony/CTCellularData.h>
#import "UIApplication+JYTopVC.h"
#import "FMBoxViewController.h"

#import <CocoaLumberjack/CocoaLumberjack.h>
#import "JYExceptionHandler.h"

#import "FMUploadFileAPI.h"
#import "WeChetLoginAPI.h"

#import "FileHash.h"
#import "TYDownLoadDataManager.h"


// Log levels: off, error, warn, info, verbose
//static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@interface AppDelegate ()<UIAlertViewDelegate,FMLeftMenuDelegate,WXApiDelegate>

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    [[RRFPSBar sharedInstance]setHidden:YES];
//    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    //配置侧拉
 
    MyNSLog(@"重新启动应用");
    //配置app的模式
    [self configAppMode];
    //检测奔溃
    [self checkExceptions];
    //配置主视图
    [self configRootWindow];
    [self asynAnyThings];

    [self configNotify];
    //配置 行为统计 /检测网络权限
    [self configUmeng];
    
    [self configWeChat];
        return YES;
}

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    //更新图库
    [FMDBControl asyncLoadPhotoToDB];
    return YES;
}


#pragma mark - Background Upload


- (void)applicationDidEnterBackground:(UIApplication *)application {

    self.isBackground = YES;
    [[BackgroundRunner shared] run];
    if (self.didEnterBackgroundHandler) {
        self.didEnterBackgroundHandler();
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[BackgroundRunner shared] stop];
    self.isBackground = NO;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"enterForeground" object:nil];
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    self.backgroundSessionCompletionHandler = completionHandler;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [WXApi handleOpenURL:url delegate:self];
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
//    FMLoginViewController * loginVC = [[FMLoginViewController alloc] init];
    BOOL res = [WXApi handleOpenURL:url delegate:self];
    return res;
}

-(void)onReq:(BaseReq*)req{
    
    //onReq是微信终端向第三方程序发起请求，要求第三方程序响应。第三方程序响应完后必须调用sendRsp返回。在调用sendRsp返回时，会切回到微信终端程序界面。
}
-(void)onResp:(BaseResp*)resp{
    switch (resp.errCode) {
        case WXSuccess://用户同意
        {
            SendAuthResp *aresp = (SendAuthResp *)resp;
                [_zhuxiao weChatCallBackRespCode:aresp.code];
        }
            break;
        case WXErrCodeAuthDeny://用户拒绝授权
            [SXLoadingView showProgressHUDText:@"授权失败" duration:1.5];
            break;
        case WXErrCodeSentFail://用户取消
            [SXLoadingView showProgressHUDText:@"发送失败" duration:1.5];
            break;
        case WXErrCodeUnsupport://用户取消
            [SXLoadingView showProgressHUDText:@"微信不支持" duration:1.5];
            break;
        case WXErrCodeUserCancel://用户取消
            [SXLoadingView showProgressHUDText:@"用户点击取消并返回" duration:1.5];
            break;
        case WXErrCodeCommon://用户取消
            [SXLoadingView showProgressHUDText:@"普通错误类型" duration:1.5];
            break;
        default:
            break;
    }
}

- (BOOL)sendReq:(BaseReq*)req{
    return YES;
}

/***********************************************************/
/********************* Some Config *************************/
/***********************************************************/

-(void)configUMengShare{
    
}

-(void)configRootWindow{
    if (!IsNilString(DEF_Token)) {
        NSLog(@"UserToken : %@",DEF_Token);
        NSLog(@"Last Connect IP : %@",BASE_URL);
         [self initLeftMenu];
        self.sharesTabBar = [[RDVTabBarController alloc]init];
        [self initWithTabBar:self.sharesTabBar];
        self.window.rootViewController = self.sharesTabBar;
        [self.window makeKeyAndVisible];
    }else{
        NSLog(@"上次未登录, 重新登录");
        
        FMLoginViewController * vc = [[FMLoginViewController alloc]init];
        vc.title = @"搜索附近设备";
        NavViewController *nav = [[NavViewController alloc] initWithRootViewController:vc];
        _zhuxiao = vc;
        self.window.rootViewController = nav;
        [self.window makeKeyAndVisible];
        
    }
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
}

// CocoaLumberjack
//-(void)configAppLog{
//    [DDLog addLogger:[DDASLLogger sharedInstance]];
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];
//    DDFileLogger * fileLogger = [[DDFileLogger alloc] init];
//    fileLogger.rollingFrequency = 60 * 60 * 24*7; // 24 hour rolling
//    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
//    [DDLog addLogger:fileLogger];
//}


//配置app的模式
-(void)configAppMode{
//默认配置为YES
    
    FMConfigInstance.isDebug = NO;
    FMConfigInstance.shouldUpload = NO;
    UIDevice *device = [UIDevice currentDevice];
//    NSLog(@"手机名称：%@",device.name);
    if (![[device name] isEqualToString:@"iPhone Simulator"] && ![device.name containsString:@"JackYang"]) {
//         开始保存日志文件
//        [self redirectNSlogToDocumentFolder];
        [FMConfiguation shareConfiguation].shouldUpload = NO;
    }
}

//检查奔溃信息
-(void)checkExceptions{
    if (EXCEPTION_HANDLER) {
    }
}

- (void)configWeChat{
    [WXApi registerApp:KWxAppID];
}

-(void)resetDatasource{
    //重置侧拉数据
    [[NSNotificationCenter defaultCenter]postNotificationName:FM_USER_ISADMIN object:@(0)];
  
    //重置数据源
    self.photoDatasource = nil;
    self.mediaDataSource = nil;
    
    //结束当前所有任务
    [[FMGetThumbImage defaultGetThumbImage].getImageQueue cancelAllOperations];
    
    //清理 内存 垃圾
    [[FMGetThumbImage defaultGetThumbImage].cache.memoryCache  removeAllObjects];
    [[FMGetImage defaultGetImage].cache.memoryCache removeAllObjects];
    [[FMGetImage defaultGetImage].manager.imageCache clearMemory];
    [[SDWebImageManager sharedManager] cancelAll];
    
    [[PhotoManager shareManager].getImageQueue cancelAllOperations];

}

//配置侧拉
-(void)initLeftMenu{
    FMLeftMenu * leftMenu = [[[NSBundle mainBundle]loadNibNamed:@"FMLeftMenu" owner:nil options:nil]lastObject];
    [leftMenu getAllPhoto];
    [PhotoManager checkNetwork];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [FMDBControl asynUsers];
    });
    leftMenu.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width * 0.8, [[UIScreen mainScreen] bounds].size.height);
    _leftMenu = leftMenu;
   
    leftMenu.delegate = self;
    leftMenu.menus = [NSMutableArray arrayWithObjects:@"文件下载",@"设置",@"注销",nil];//@"个人信息", @"我的私有云", @"用户管理", @"设置", @"帮助",
    leftMenu.imageNames = [NSMutableArray arrayWithObjects:@"storage",@"set",@"cancel",nil];//@"personal",@"cloud",@"user",@"set",@"help",
    //配置Users 列表
   
    leftMenu.usersDatasource = [self getUsersInfo];
    
    [leftMenu.settingTabelView reloadData];
    _Info = [[FMUserEditVC alloc]init];
    _OwnCloud = [[FMOwnCloud alloc]init];
    _UserSetting = [[FMUserSetting alloc]init];
    _Setting = [[FMSetting alloc]initPrivate];
    _Help = [[FMHelp alloc]init];
    _zhuxiao = [[FMLoginViewController alloc]init];
    _downAndUpLoadManager = [[FLLocalFIleVC alloc]init];
  
    self.menu = [MenuView MenuViewWithDependencyView:self.window MenuView:leftMenu isShowCoverView:YES];
//    @weakify(self);
    self.menu.showBlock = ^() {
        
        UIViewController * topVC = [UIApplication topViewController];
       
        if([topVC isKindOfClass:[RTContainerController class]])
            topVC = ((RTContainerController *)topVC).contentViewController;
        if ([topVC isKindOfClass:[FLBaseVC class]] || [topVC isKindOfClass:[FMBaseFirstVC class]]) {
//            [weak_self.leftMenu.settingTabelView reloadData];
           
            return YES;
        }
        return NO;
    };
   
   }

-(NSMutableArray *)getUsersInfo{
    NSMutableArray * arr = [NSMutableArray arrayWithArray:[FMDBControl getAllUserLoginInfo]];
    
    for (FMUserLoginInfo * info in arr) {
        if (IsEquallString(info.uuid, DEF_UUID)) {
            [arr removeObject:info];
            break;
        }
    }
    return arr;
}


-(void)reloadLeftUsers{
    _leftMenu.usersDatasource = [self getUsersInfo];
    [_leftMenu checkToStart];
}

-(void)reloadLeftMenuIsAdmin:(BOOL)isAdmin{
    NSMutableArray * menusTitle = nil;
    NSMutableArray * menusImages = nil;
    if (!isAdmin){
        menusTitle =  [NSMutableArray arrayWithObjects:@"文件下载",@"设置",@"注销", nil];//,@"个人信息",@"personal"
        menusImages = [NSMutableArray arrayWithObjects:@"storage",@"set",@"cancel",nil];
    }else{
        menusTitle = [NSMutableArray arrayWithObjects:@"文件下载",@"用户管理",@"设置",@"注销",nil];//,@"个人信息",@"personal"
        menusImages = [NSMutableArray arrayWithObjects:@"storage",@"person_add",@"set",@"cancel",nil];
    }
    _leftMenu.usersDatasource = [self getUsersInfo];
    _leftMenu.menus = menusTitle;
    _leftMenu.imageNames = menusImages;
    [_leftMenu.settingTabelView reloadData];
    [_leftMenu checkToStart];
}

// 将NSlog打印信息保存到Document目录下的文件中
- (void)redirectNSlogToDocumentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"winsun.log"];// 注意不是NSData!
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    // 先删除已经存在的文件
//    NSFileManager *defaultManager = [NSFileManager defaultManager];
//    [defaultManager removeItemAtPath:logFilePath error:nil];
    
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}



-(void)initWithTabBar:(RDVTabBarController *)tabbar{
    
    /* 页面 */
    FMBoxViewController * boxVC = [[FMBoxViewController alloc]init];
    FMPhotosViewController * photosVC = [[FMPhotosViewController alloc]init];
//    FMAlbumsViewController * albumsVC = [[FMAlbumsViewController alloc]init];
        FLFilesVC * filesVC = [[FLFilesVC alloc]init];
    /* 导航 */
//    NavViewController *nav0 = [[NavViewController alloc] initWithRootViewController:boxVC];
    NavViewController *nav1 = [[NavViewController alloc] initWithRootViewController:photosVC];
    NavViewController *nav2 = [[NavViewController alloc] initWithRootViewController:filesVC];
    
//    boxVC.title = @"分享";
    photosVC.title = @"照片";
    filesVC.title = @"文件";
    
    NSMutableArray *viewControllersMutArr = [[NSMutableArray alloc] initWithObjects:nav1,nav2,nil];
    [tabbar setViewControllers:viewControllersMutArr];
   
//    tabbar.tabBar.backgroundView.backgroundColor = UICOLOR_RGB(0x3f51b5);
    NSArray *tabBarItemImages = @[ @"photo", @"storage"];
//    NSArray *tabBarItemTitles = @[@"分享", @"照片", @"文件"];
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabbar tabBar] items]) {
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_select",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",
                                                        [tabBarItemImages objectAtIndex:index]]];
//        item.title = tabBarItemTitles[index];

        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        index++;
    }
    tabbar.selectedIndex = 0;
}


//    NSString * UUID = [NSString stringWithFormat:@"%@:%@",_user.uuid,IsNilString(_loginTextField.text)?@"":_loginTextField.text];
//    NSString * basic = [UUID base64EncodedString];
//    [[LoginAPI apiWithServicePath:_service.path AuthorizationBasic:basic]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//        [SXLoadingView hideProgressHUD];
//        [self loginToDoWithResponse:request.responseJsonObject];
//        sender.userInteractionEnabled = YES;
//    } failure:^(__kindof JYBaseRequest *request) {
//        [SXLoadingView hideProgressHUD];
//        NSHTTPURLResponse * res = (NSHTTPURLResponse *)request.dataTask.response;
//        [SXLoadingView showAlertHUD:[NSString stringWithFormat:@"登录失败:%ld",(long)res.statusCode] duration:1];
//        sender.userInteractionEnabled = YES;
//        NSLog(@"%@",error);
//    }];




//-(RDVTabBarController *)filesTabBar{
//    if (!_filesTabBar) {
//        _filesTabBar = [[RDVTabBarController alloc]init];
//        [self initFilesWithTabBar:_filesTabBar];
//    }
//    return _filesTabBar;
//}

-(void)initFilesWithTabBar:(RDVTabBarController *)tabbar{
    /* 页面 */
    FLFilesVC * filesVC = [[FLFilesVC alloc]init];
    FLShareVC * shareVC = [[FLShareVC alloc]init];
    FLLocalFIleVC * localFilesVC = [[FLLocalFIleVC alloc]init];
    /* 导航 */
    NavViewController *nav0 = [[NavViewController alloc] initWithRootViewController:shareVC];
    
    NavViewController *nav1 = [[NavViewController alloc]initWithRootViewController:filesVC];
    NavViewController *nav2 = [[NavViewController alloc] initWithRootViewController:localFilesVC];
    
    shareVC.title = @"分享";
    filesVC.title = @"文件";
    localFilesVC.title = @"本地";
    NSMutableArray *viewControllersMutArr = [[NSMutableArray alloc] initWithObjects:nav0, nav1,nav2,nil];
    [tabbar setViewControllers:viewControllersMutArr];
    tabbar.tabBar.backgroundView.backgroundColor = UICOLOR_RGB(0x3f51b5);
    NSArray *tabBarItemImages = @[@"share", @"hard", @"local"];
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabbar tabBar] items]) {
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_select",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",
                                                        [tabBarItemImages objectAtIndex:index]]];
        item.title = @"";
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        index++;
    }
    tabbar.selectedIndex = 0;
}

-(void)_hiddenMenu{
    if (self.menu) {
        [self.menu hidenWithAnimation];
    }
}


-(void)applicationDidBecomeActive:(UIApplication *)application{
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

#pragma mark - leftmenu Delegate

//切换 账户 响应
-(void)LeftMenuViewClickUserTable:(FMUserLoginInfo *)info{
    [self _hiddenMenu];
    [SXLoadingView showProgressHUD:@"正在切换"];
//    FMConfigInstance.userToken = @"";
    @weaky(MyAppDelegate);
    [[FMCheckManager shareCheckManager] beginSearchingWithBlock:^(NSArray *discoveredServers) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            BOOL canFindDevice = NO;
                  NSLog(@"😁😁😁😁%@",discoveredServers);
            for (NSNetService * service in discoveredServers) {
//                NSLog(@"😁😁😁😁%@",info.bonjour_name);
                if ([service.hostName isEqualToString:info.bonjour_name]) {
                    canFindDevice = YES;
                    NSString * addressIP = [FMCheckManager serverIPFormService:service];
                    BOOL isAlive = [FMCheckManager testServerWithIP:addressIP andToken:info.jwt_token];
                    if (isAlive) { //如果可以跳转
                        
                        [SXLoadingView hideProgressHUD];
                        
                        //切换操作
                        [FMDBControl reloadTables];
                        [FMDBControl asyncLoadPhotoToDB];
                        
                        //清除deviceID
                        FMConfigInstance.deviceUUID = info.deviceId;//清除deviceUUID
                        FMConfigInstance.userToken = info.jwt_token;
                        FMConfigInstance.userUUID = info.uuid;
                        
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DRIVE_UUID_STR];
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DIR_UUID_STR];
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:ENTRY_UUID_STR];
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PHOTO_ENTRY_UUID_STR];
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uploadImageArr"];
                        
//                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:UUID_STR];
                        
                        JYRequestConfig * config = [JYRequestConfig sharedConfig];
                        config.baseURL = [NSString stringWithFormat:@"%@:3000/",addressIP];
                        //重置数据
                        [weak_MyAppDelegate resetDatasource];

                        if(IsNilString(USER_SHOULD_SYNC_PHOTO) || IsEquallString(USER_SHOULD_SYNC_PHOTO, info.uuid)){
                            //设置   可备份用户为
                            [[NSUserDefaults standardUserDefaults] setObject:info.uuid forKey:USER_SHOULD_SYNC_PHOTO_STR];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            //重启photoSyncer
                            [PhotoManager shareManager].canUpload = YES;
                        }else{
                            [PhotoManager shareManager].canUpload = NO;//停止上传
                        }
                        //组装UI
                     
                        self.window.rootViewController = nil;
                        [self.window resignKeyWindow];
                        [self.window removeFromSuperview];
                        
                        weak_MyAppDelegate.sharesTabBar = [[RDVTabBarController alloc]init];
                        [weak_MyAppDelegate initWithTabBar:MyAppDelegate.sharesTabBar];
                        [weak_MyAppDelegate.sharesTabBar setSelectedIndex:0];
                        weak_MyAppDelegate.filesTabBar = nil;
                        [weak_MyAppDelegate reloadLeftMenuIsAdmin:NO];
                         [weak_MyAppDelegate asynAnyThings];
                        dispatch_async(dispatch_get_main_queue(), ^{
                           
                            self.window.rootViewController = weak_MyAppDelegate.sharesTabBar;
                            [self.window makeKeyAndVisible];
//                            [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
                        });
                    }else{
                        [SXLoadingView showAlertHUD:@"切换失败，设备当前状态未知，请检查" duration:1];
//                        [self skipToLogin];
                    }
                    break;
                }
            }
            [SXLoadingView hideProgressHUD];
            if (!canFindDevice) {
                [SXLoadingView showAlertHUD:@"切换失败，可能设备不在附近" duration:1];
//                [self skipToLogin];
            }
        });
    }];
    
}

-(void)LeftMenuViewClickSettingTable:(NSInteger)tag andTitle:(NSString *)title{
    [self _hiddenMenu];
    UIViewController * vc = nil;
    RDVTabBarController * tVC = (RDVTabBarController *)self.window.rootViewController;
    NavViewController * selectVC = (NavViewController *)tVC.selectedViewController;
    if(IsEquallString(title, @"个人信息")){
        vc = self.Info;
        if ([selectVC isKindOfClass:[NavViewController class]]) {
            [selectVC  pushViewController:vc animated:YES];
        }
    }else if(IsEquallString(title, @"用户管理")){
        vc = self.UserSetting;
        if ([selectVC isKindOfClass:[NavViewController class]]) {
            [selectVC  pushViewController:vc animated:YES];
        }
    }
        else if (IsEquallString(title, @"文件下载")){
            vc = self.downAndUpLoadManager;
            if ([selectVC isKindOfClass:[NavViewController class]]) {
                [selectVC  pushViewController:vc animated:YES];
            }

        }
    //        [self.window makeKeyAndVisible];
//    else if (IsEquallString(title, @"我的照片")){
//        self.window.rootViewController = self.sharesTabBar;
//        [self.window makeKeyAndVisible];
//        NSInteger index = [self.leftMenu.menus indexOfObject:@"我的照片"];
//        self.leftMenu.menus[index] = @"我的文件";
//        self.leftMenu.imageNames[index] = @"files";
//        [self.leftMenu.settingTabelView reloadData];
//    }else if (IsEquallString(title, @"我的文件")){
//        self.window.rootViewController = self.filesTabBar;
//        [self.window makeKeyAndVisible];
//        NSInteger index = [self.leftMenu.menus indexOfObject:@"我的文件"];
//        self.leftMenu.menus[index] = @"我的照片";
//        self.leftMenu.imageNames[index] = @"photos";
//        [self.leftMenu.settingTabelView reloadData];
//    }
    else if (IsEquallString(title, @"设置")){
            vc = self.Setting;
            if ([selectVC isKindOfClass:[NavViewController class]]) {
                [selectVC  pushViewController:vc animated:YES];
            }
        }
    else if(IsEquallString(title,@"注销")){
        MyNSLog(@"注销");
        vc = self.zhuxiao;
        [SXLoadingView showProgressHUD:@"正在注销"];
        [PhotoManager shareManager].canUpload = NO;//停止上传
        FMConfigInstance.userToken = @"";
        FMConfigInstance.isCloud = NO;
        [self resetDatasource];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uploadImageArr"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PHOTO_ENTRY_UUID_STR];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uploadImageArr"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KSWITHCHON];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"siftPhoto"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"addCount"];

        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DRIVE_UUID_STR];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DIR_UUID_STR];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:ENTRY_UUID_STR];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KSTATIONID_STR];
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        [[PhotoManager shareManager] cleanUploadTask];
        [[FMPhotoManager  defaultManager] stop];
        [[FMPhotoManager  defaultManager] destroy];
        [[TYDownLoadDataManager manager] cleanTask];
     //        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"addCountNumber"];

//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:UUID_STR];
        [SXLoadingView hideProgressHUD];
        [FMDBControl reloadTables];
        [FMDBControl asyncLoadPhotoToDB];

        [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
        [[SDImageCache sharedImageCache] clearMemory];
        [[YYImageCache sharedCache].diskCache removeAllObjects];
        [[YYImageCache sharedCache].memoryCache removeAllObjects];
        self.filesTabBar = nil;
        self.sharesTabBar = nil;
        
        _Info = nil;
        _OwnCloud = nil;
        _UserSetting = nil;
        _Setting = nil;
        _Help = nil;
//        _zhuxiao = [[FMLoginViewController alloc]init];
        _downAndUpLoadManager = nil;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self skipToLogin];
        });
    }else if(IsEquallString(title,@"USER_FOOTERVIEW_CLICK")){
        vc = [FMUserLoginSettingVC new];
        if ([selectVC isKindOfClass:[NavViewController class]]) {
            [selectVC  pushViewController:vc animated:YES];
        }
    }
}

-(void)skipToLogin{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.window.rootViewController = nil;
        [self.window resignKeyWindow];
        
        for (UIView *view in self.window.subviews) {
            [view removeFromSuperview];
        }
        [self.window removeFromSuperview];
        self.UserSetting = nil;
        
        [self reloadLeftMenuIsAdmin:NO];
        FMLoginViewController * vc = [[FMLoginViewController alloc]init];
        _zhuxiao = vc;
//        vc.title = @"搜索附近设备";
        NavViewController *nav = [[NavViewController alloc] initWithRootViewController:vc];
        self.window.rootViewController = nav;
        [self.window makeKeyAndVisible];
    });
}

-(void)configUmeng{
    if(kSystemVersion>9.0){
        CTCellularData *cellularData = [[CTCellularData alloc]init];
        CTCellularDataRestrictedState state = cellularData.restrictedState;
        switch (state) {
            case kCTCellularDataRestricted:
                NSLog(@"Restricrted");
                break;
            case kCTCellularDataNotRestricted:
                NSLog(@"Not Restricted");
                break;
            case kCTCellularDataRestrictedStateUnknown:
                NSLog(@"Unknown");
                break;
            default:
                break;
        }
    }
}

-(void)configNotify{
    _notification = [CWStatusBarNotification new];
    _notification.notificationLabelBackgroundColor = StatusBar_Color;
    _notification.notificationLabelFont = [UIFont fontWithName:FANGZHENG size:13.5f];
    _notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    _notification.notificationAnimationOutStyle = CWNotificationAnimationStyleBottom;
    _notification.notificationStyle = CWNotificationStyleNavigationBarNotification;
    
    _statusBarNotification = [CWStatusBarNotification new];
    _statusBarNotification.notificationLabelBackgroundColor = StatusBar_Color;
    _statusBarNotification.notificationLabelFont = [UIFont fontWithName:FANGZHENG size:5.0f];
    _statusBarNotification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    _statusBarNotification.notificationAnimationOutStyle = CWNotificationAnimationStyleBottom;
    _statusBarNotification.notificationStyle = CWNotificationStyleStatusBarNotification;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleChangeIsAdminNotify:) name:FM_USER_ISADMIN object:nil];
}

-(void)handleChangeIsAdminNotify:(NSNotification *)notify{
    BOOL isAdmin = [notify.object boolValue];
    [self reloadLeftMenuIsAdmin:isAdmin];
}

#pragma mark - Initial Data

-(UIView *)notifyViewWithMessage:(NSString *)message{
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, 20)];
    UILabel * label = [[UILabel alloc]initWithFrame:view.bounds];
    [view addSubview:label];
    label.font = [UIFont fontWithName:FANGZHENG size:8];
    label.textAlignment = NSTextAlignmentCenter;
    view.backgroundColor = StatusBar_Color;
    label.backgroundColor = StatusBar_Color;
    return view;
}

-(void)asynAnyThings{
    //上传照片
    //    shouldUplod(^{
  
    //    });
    //监听奔溃
    //    [FMABManager shareManager];
    [JYExceptionHandler installExceptionHandler];
  
    BOOL switchOn = SWITHCHON_BOOL;
    NSString *token = DEF_Token;
    if (token.length>0) {
       
        if (switchOn) {
             [[FMPhotoManager defaultManager] start];
//            [PhotoManager shareManager].canUpload = YES;
        }else{
//            [[FMPhotoManager defaultMan ager] destroy];
//            [PhotoManager shareManager].canUpload = NO;
        }
    }
}
@end
