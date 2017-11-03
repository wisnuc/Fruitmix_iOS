//
//  FMLoginViewController.m
//  FruitMix
//
//  Created by wisnuc on 2017/8/14.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMLoginViewController.h"
#import "StationPageControl.h"
#import "LoginTableViewCell.h"
#import "FMUserLoginViewController.h"
#import "ServerBrowser.h"
#import "GCDAsyncSocket.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "LoginModel.h"
#import "FMHandLoginVC.h"
#import "WeChetLoginAPI.h"
#import "GetStationAPI.h"
#import "CloudLoginModel.h"
#import "FMCloudUserModel.h"
#import "FMGetUsersAPI.h"
#import "ChooseAlertView.h"
#import "FMCloudUserTableViewCell.h"
#import "GetStaionInfoAPI.h"
#import "GetSystemInformationAPI.h"

#define kCount 3
@interface FMLoginViewController ()
<
UIScrollViewDelegate,
UITableViewDelegate,
UITableViewDataSource,
ServerBrowserDelegate,
WXApiDelegate
>
{
    NSMutableArray *_dataSource;
    ServerBrowser* _browser;
    AFNetworkReachabilityManager * _manager;
    NSTimer* _reachabilityTimer;
    NSMutableArray *_userDataSource;
    ChooseAlertView *_alertView;
    RACSubject *_subject;
    NSString * _avatarUrl;
}
@property (strong, nonatomic) UIScrollView *stationScrollView;
@property (strong, nonatomic) UIView *stationCardView;
@property (strong, nonatomic) StationPageControl *stationPageControl;
@property (strong, nonatomic) UIButton *infoButton;
@property (strong, nonatomic) UIImageView *logoImageView;
@property (strong, nonatomic) UIImageView *stationLogoImageView;
@property (strong, nonatomic) UILabel *stationNameLabel;
@property (strong, nonatomic) UILabel *stationTypeLabel;
@property (strong, nonatomic) UILabel *stationIpLabel;
@property (strong, nonatomic) UIView *userView;
@property (strong, nonatomic) UITableView *userListTableViwe;
@property (strong, nonatomic) UIView *wechatView;
@property (strong, nonatomic) NSMutableArray *tempDataSource;
@property (nonatomic) FMSerachService * expandCell;
@property (nonatomic) NSInteger userDataCount;
@property (nonatomic) UIButton *handButton;
@property (nonatomic) UserModel * user;
@property (strong, nonatomic) NSMutableArray *cloudLoginStationArray;
@property (strong, nonatomic) NSMutableArray *cloudOriginStationArray;
@property (nonatomic) NSInteger current;
@property (nonatomic) NSString *guid;
@property (nonatomic) NSString *token;
@property (nonatomic) NSString *nickName;


@end

@implementation FMLoginViewController

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
//    [self.navigationController.navigationBar setBackgroundColor:UICOLOR_RGB(0x0288d1)];
    [UIApplication sharedApplication].statusBarStyle =UIStatusBarStyleLightContent;
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
      _reachabilityTimer =  [NSTimer scheduledTimerWithTimeInterval:12 target:self selector:@selector(searchingAndRefresh) userInfo:nil repeats:YES];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//      [self firstbeginSearching];
  }

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_reachabilityTimer invalidate];
    _reachabilityTimer = nil;
    _browser.delegate = nil;
    [_browser stopServer];
}

-(void)dealloc{
    [_reachabilityTimer invalidate];
    _reachabilityTimer = nil;
    _browser.delegate = nil;
    [_browser stopServer];
}

- (instancetype)init{
    if (self = [super init]) {
   
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataSource = [NSMutableArray arrayWithCapacity:0];
    [self.view addSubview:self.stationScrollView];
 
    [self setStationCardView];
    [self.view addSubview:self.stationPageControl];
    [self.view addSubview:self.logoImageView];
    [self.view addSubview:self.userView];
    [self.view addSubview:self.userListTableViwe];
    [self.view addSubview:self.handButton];
     if ([WXApi isWXAppInstalled]) {
     [self.view addSubview:self.wechatView];
    }
    [self firstbeginSearching];
}

- (void)beginSearching {
    _browser = [[ServerBrowser alloc] initWithServerType:@"_http._tcp" port:-1];
    _browser.delegate = self;
    double delayInSeconds = 2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"发现 %lu 台设备",(unsigned long)_browser.discoveredServers.count);
//          [self viewOfSeaching:NO];
    });
}

- (void)firstbeginSearching {
    [self viewOfSeaching:YES];
    _browser = [[ServerBrowser alloc] initWithServerType:@"_http._tcp" port:-1];
    _browser.delegate = self;
    double delayInSeconds = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"发现 %lu 台设备",(unsigned long)_browser.discoveredServers.count);
        if (_browser.discoveredServers.count == 0) {
             [SXLoadingView hideProgressHUD];
        }
    });
}

-(void)viewOfSeaching:(BOOL)seaching{
    if(seaching){
        [SXLoadingView showProgressHUD:@"正在搜索..."];
    }else{
        [SXLoadingView hideProgressHUD];
    }
}

- (void)serverBrowserFoundService:(NSNetService *)service {
    for (NSData * address in service.addresses) {
        NSString* addressString = [GCDAsyncSocket hostFromAddress:address];
        [self findIpToCheck:addressString andService:service];
    }
}

- (void)serverBrowserLostService:(NSNetService *)service index:(NSUInteger)index {
    if (_browser.discoveredServers.count <= 0) {
        [self beginSearching];
    }
}

- (void)searchingAndRefresh{
    [self beginSearching];
    [self refreshDatasource];
}

-(void)rightBtnClick{
    FMHandLoginVC * vc = [[FMHandLoginVC alloc]init];
    @weaky(self)
    vc.block = ^(FMSerachService * ser){
        ser.isReadly = YES;
        [_dataSource addObject:ser];
        [weak_self refreshDatasource];
    };
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)findIpToCheck:(NSString *)addressString andService:(NSNetService *)service{
    NSString* urlString = [NSString stringWithFormat:@"http://%@:3000/", addressString];
    NSLog(@"%@", urlString);
      FMSerachService * ser = [FMSerachService new];
     RACSubject *subject = [RACSubject subject];
    [[GetStaionInfoAPI apiWithServicePath:urlString]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//        MyNSLog(@"%@",request.responseJsonObject);
        NSDictionary *rootDic =  request.responseJsonObject;
        NSString *nameString = [rootDic objectForKey:@"name"];
        if (nameString.length == 0) {
            nameString = @"闻上盒子";
        }
         [subject sendNext:nameString];
    } failure:^(__kindof JYBaseRequest *request) {
        
    }];
    
    [subject subscribeNext:^(id x) {
        [[GetSystemInformationAPI apiWithServicePath:urlString]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            //            MyNSLog(@"%@",request.responseJsonObject);
            NSDictionary *rootDic =request.responseJsonObject;
            NSDictionary *dic = [rootDic objectForKey:@"ws215i"];
            NSString *type;
            if (dic) {
                type = @"WS215i";
            }else{
                type = @"虚拟机";
            }
            ser.name = x;
            ser.path = urlString;
            ser.type = type;
            //            MyNSLog(@"%@",service.type);
            ser.displayPath = addressString;
            ser.hostName = service.hostName;
            _expandCell = ser;
            BOOL isNew = YES;
            for (FMSerachService * s in _dataSource) {
                if (IsEquallString(s.path, ser.path)) {
                    isNew = NO;
                    break;
                }
            }
            if (isNew) {
                [_dataSource addObject:ser];
                [self refreshDatasource];
            }
        } failure:^(__kindof JYBaseRequest *request) {
            
        }];
        
    }];
   
}

- (void)refreshDatasource{
    NSMutableArray * temp = [NSMutableArray arrayWithCapacity:0];
    _userDataSource = [NSMutableArray arrayWithCapacity:0];
    for (FMSerachService * ser in _dataSource) {
        if (ser.isReadly) {
            [temp addObject:ser];
        }
    }

    if(self.tempDataSource.count != temp.count){
        self.tempDataSource = temp;
        [self.userListTableViwe reloadData];
    }else if (self.tempDataSource && self.tempDataSource.count ==0){
        self.tempDataSource = temp;
        [self.userListTableViwe reloadData];
    }
    
//    for (UIView *view in _stationScrollView.subviews) {
//
////        MyNSLog(@"%@",view);
//          [view removeFromSuperview];
//    }
    if (_stationScrollView) {
        [_stationScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }

    [self updateInfo];
    [self setStationCardView];

}

- (void)updateInfo{
    _stationScrollView.contentSize = CGSizeMake(self.tempDataSource.count * JYSCREEN_WIDTH, 0);
    _stationPageControl.numberOfPages = self.tempDataSource.count;
}

- (void)setStationCardView{

    if (self.tempDataSource.count ==0) {
        _stationCardView = [[UIView alloc]init];
        _stationCardView.backgroundColor =  UICOLOR_RGB(0x03a9f4);
        _stationCardView.frame = CGRectMake(32,64,JYSCREEN_WIDTH - 32*2, 166);
        _stationCardView.layer.cornerRadius = 8;
        _stationCardView.layer.masksToBounds = YES;
        [self.stationScrollView addSubview:self.stationCardView];
//        [self setStationLogoImageView];
        [self setNullInfo];
    }else{
    for (int i = 0; i<self.tempDataSource.count; i++) {
        _stationCardView = [[UIView alloc]init];
        _stationCardView.backgroundColor =  UICOLOR_RGB(0x03a9f4);
        _stationCardView.frame = CGRectMake(i*JYSCREEN_WIDTH + 32,64,JYSCREEN_WIDTH - 32*2, 166);
        _stationCardView.layer.cornerRadius = 8;
        _stationCardView.layer.masksToBounds = YES;
        [self.stationScrollView addSubview:self.stationCardView];
        
//        [self setInfoButton];
        [self setStationLogoImageView];
        [self setInfo];
        FMSerachService *ser = _tempDataSource[i];
        if ([NSThread isMainThread]){
            [self reloadDataWithService:ser];
        }else{
            dispatch_sync(dispatch_get_main_queue(), ^{
            [self reloadDataWithService:ser];
            });  
        }
    }
    FMSerachService *serforUser;
    if (_userDataCount > 0) {
      serforUser  = _tempDataSource[_userDataCount];
    
    }else{
      serforUser  = _tempDataSource[0];
    }
     _userDataSource = serforUser.users;
    [_userListTableViwe reloadData];
    }
//    [self viewOfSeaching:NO];
}

- (void)setInfoButton{
    UIImage *infoImage = [UIImage imageNamed:@"info"];
    _infoButton = [[UIButton alloc]init];
    [_infoButton setImage:infoImage forState:UIControlStateNormal];
    [_infoButton addTarget:self action:@selector(infoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_stationCardView addSubview:self.infoButton];
    [_infoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_stationCardView.mas_right).offset(-16);
        make.centerY.equalTo(_stationCardView);
        make.size.mas_equalTo(infoImage.size);
    }];
}

- (void)setStationLogoImageView{
    UIImage *logo = [UIImage imageNamed:@"stationLogo"];
    _stationLogoImageView = [[UIImageView alloc]initWithImage:logo];
    [self.stationCardView addSubview:self.stationLogoImageView];
    [_stationLogoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_stationCardView.mas_left).offset(16);
        make.centerY.equalTo(_stationCardView);
        make.size.mas_equalTo(logo.size);
    }];
}
- (void)setNullInfo{
    _stationTypeLabel = [[UILabel alloc]init];
    _stationTypeLabel.text = @"未搜索到设备";
    _stationTypeLabel.font = [UIFont boldSystemFontOfSize:16];
    _stationTypeLabel.textColor = [UIColor whiteColor];
    _stationTypeLabel.textAlignment = NSTextAlignmentCenter;
    _stationTypeLabel.alpha = 0.87;
    [self.stationCardView addSubview:self.stationTypeLabel];
    [_stationTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_stationCardView.mas_left).offset(16);
        make.right.equalTo(_stationCardView.mas_right).offset(-16);
        make.centerY.equalTo(_stationCardView.mas_centerY);
        make.height.equalTo(@15);
    }];
}

- (void)setInfo{
    _stationTypeLabel = [[UILabel alloc]init];
    _stationTypeLabel.text = @"我的设备";
    _stationTypeLabel.font = [UIFont systemFontOfSize:14];
    _stationTypeLabel.textColor = [UIColor whiteColor];
    _stationTypeLabel.alpha = 0.54;
    [self.stationCardView addSubview:self.stationTypeLabel];
    [_stationTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_stationLogoImageView.mas_right).offset(16);
        make.right.equalTo(_stationCardView.mas_right).offset(-16);
        make.centerY.equalTo(_stationCardView.mas_centerY).offset(2);
        make.height.equalTo(@15);
    }];

    _stationNameLabel = [[UILabel alloc]init];
    _stationNameLabel.text = @"WS215i";
    _stationNameLabel.font = [UIFont boldSystemFontOfSize:16];
    _stationNameLabel.textColor = [UIColor whiteColor];
    _stationNameLabel.alpha = 0.87;
    [self.stationCardView addSubview:self.stationNameLabel];
    [_stationNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_stationLogoImageView.mas_right).offset(16);
        make.right.equalTo(_stationCardView.mas_right).offset(-16);
        make.bottom.equalTo(_stationTypeLabel.mas_top).offset(-3.5);
        make.height.equalTo(@20);
    }];
    
    _stationIpLabel = [[UILabel alloc]init];
    _stationIpLabel.text = @"10.10.10";
    _stationIpLabel.font = [UIFont systemFontOfSize:16];
    _stationIpLabel.textColor = [UIColor whiteColor];
    _stationIpLabel.alpha = 0.54;
    [self.stationCardView addSubview:self.stationIpLabel];
    [_stationIpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_stationLogoImageView.mas_right).offset(16);
        make.right.equalTo(_stationCardView.mas_right).offset(-16);
        make.top.equalTo(_stationTypeLabel.mas_bottom).offset(2);
        make.height.equalTo(@15);
    }];
}

- (void)reloadDataWithService:(FMSerachService *)ser{
//    if (ser.ws215i && ser.ws215i.length > 0) {
//        _stationCardView.backgroundColor = UICOLOR_RGB(0x8bc3a4);
//        _stationScrollView.backgroundColor = UICOLOR_RGB(0x689f38);
//    }else{
//        _stationCardView.backgroundColor =  UICOLOR_RGB(0x03a9f4);
//        _stationScrollView.backgroundColor = UICOLOR_RGB(0x0288d1);
//     
//    }
   
    _stationTypeLabel.text = ser.type;
    if ([ser.type isEqualToString:@"虚拟机"]) {
         _stationLogoImageView.image = [UIImage imageNamed:@"virtual_machine"];
    }
    _stationNameLabel.text = ser.name;
     _stationIpLabel.text = ser.displayPath;
      [self viewOfSeaching:NO];
}

- (void)applicationWillResignActive:(NSNotification*)notification {
    [self.userListTableViwe reloadData];
}

- (void) applicationDidBecomeActive:(NSNotification*)notification {
    [self beginSearching];
}

-(void)wechatLoginAction:(id)sender{
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"App";
        [WXApi sendReq:req];
    }
    else {
        [self setupAlertController];
    }
}

- (void)setupAlertController{
    [SXLoadingView showProgressHUDText:@"您尚未安装微信" duration:1.5];
}

- (void)weChatCallBackRespCode:(NSString *)code{
    @weaky(self)
    [FMDBControl asyncLoadPhotoToDB];
    [SXLoadingView showProgressHUD:@"正在登录"];
    [[WeChetLoginAPI apiWithCode:code] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        MyNSLog(@"%@",request.responseJsonObject);
        [SXLoadingView hideProgressHUD];
        [weak_self loginToDoWithResponse:request.responseJsonObject];
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView hideProgressHUD];
        MyNSLog(@"%@",request.error);
        NSHTTPURLResponse * res = (NSHTTPURLResponse *)request.dataTask.response;
        [SXLoadingView showAlertHUD:[NSString stringWithFormat:@"登录失败:%ld",(long)res.statusCode] duration:1];
    }];
}
- (void)infoButtonClick:(UIButton *)sender{
    NSLog(@"点击了信息");
}

-(void)loginToDoWithResponse:(id)response{
    @weaky(self)
//    CloudLoginModel * model = [CloudLoginModel yy_modelWithJSON:response];
    NSDictionary *dic = response;
    NSDictionary *dataDic = dic[@"data"];
    NSString *token = dataDic[@"token"];
    _token = token;
//    FMCloudUserModel *userModel = [FMCloudUserModel yy_modelWithDictionary:dataDic];
    NSDictionary *userDic = dataDic[@"user"];
    NSString *GUID = userDic[@"id"];
    _guid = GUID;
    _nickName = userDic[@"nickName"];
    NSString *avatarString = userDic[@"avatarUrl"];
    _avatarUrl = avatarString;
    MyNSLog(@"Cloud登录");
    FMConfigInstance.userToken = token;
    FMConfigInstance.userUUID = userDic[@"id"];
    JYRequestConfig * config = [JYRequestConfig sharedConfig];
    config.baseURL = WX_BASE_URL;
    [weak_self getStationWithGUID:GUID userDic:userDic];
}

- (void)getStationWithGUID:(NSString *)Guid userDic:(NSDictionary *)userDic{
    @weaky(self)
    [[GetStationAPI apiWithGUID:Guid]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        MyNSLog(@"%@",request.responseJsonObject);
        NSDictionary *rootDic = request.responseJsonObject;
        _cloudOriginStationArray = [NSMutableArray arrayWithCapacity:0];
        if([rootDic[@"data"] isEqual:[NSNull null]]||rootDic[@"data"] ==nil) {
            [SXLoadingView showProgressHUDText:@"您的微信尚未绑定任何设备" duration:1];
            FMConfigInstance.userToken = nil;
            JYRequestConfig * config = [JYRequestConfig sharedConfig];
            config.baseURL = nil;
        }else{
            NSMutableArray *dataArray = [NSMutableArray arrayWithArray:[rootDic objectForKey:@"data"]];
            [_expandCell.task cancel];
            [_reachabilityTimer invalidate];
            _reachabilityTimer = nil;
            [_browser stopServer];
             self.cloudLoginStationArray=[NSMutableArray arrayWithCapacity:0];
            _subject = [RACSubject subject];
            [weak_self setChooseView];
//            __block BOOL fresh = false;
//            [dataArray enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL * _Nonnull stop) {
//                 NSNumber * isOnlineNumber = dic[@"isOnline"];
//                 BOOL isOnline =  [isOnlineNumber boolValue];
//                if (isOnline) {
//                    FMConfigInstance.isCloud = YES;
//                    //常规登录
//                    //[self LoginActionWithUserDic:userDic StationDic:dic];
//                    [weak_self getUsersWithStationDic:dic completeBlock:^(NSMutableDictionary *mutableDic) {
//                        _alertView.hidden = NO;
//                        [_subject sendNext:@"1"];
//                    }];
//                    *stop = YES;
                      FMConfigInstance.isCloud = NO;
            
                    for (NSDictionary *dic in dataArray) {
                        NSLog(@"%@",dic);
                        NSNumber * isOnlineNumber = dic[@"isOnline"];
                        BOOL isOnline =  [isOnlineNumber boolValue];
                        if (isOnline) {
                            FMConfigInstance.isCloud = YES;
                            //常规登录
                            //[self LoginActionWithUserDic:userDic StationDic:dic];
                            [weak_self getUsersWithStationDic:dic completeBlock:^(NSMutableDictionary *mutableDic) {
                                  _alertView.hidden = NO;
                                [_subject sendNext:@"1"];
                            }];
                        }
//                            else{
//                          [SXLoadingView showProgressHUDText:@"没有在线设备或未绑定设备" duration:1];
//                        }
                    }
                    
//                }
//            }];
            
            [_subject subscribeNext:^(id x) {
                if (self.cloudLoginStationArray.count == 0) {
                    FMConfigInstance.userToken = nil;
                    FMConfigInstance.isCloud = NO;
                    [SXLoadingView showProgressHUDText:@"没有在线设备或未绑定设备" duration:1];
                }else{
                    [_alertView.tableView reloadData];
                }
            }];
            FMConfigInstance.userToken = nil;
//            self.cloudLoginStationArray = userArr;
//            if (self.cloudLoginStationArray.count == 1) {
//                [self loginButtonClick:nil];
//            }else
        }
    } failure:^(__kindof JYBaseRequest *request) {
         NSLog(@"%@",request.error);
    }];
    
}

- (void)getUsersWithStationDic:(NSDictionary *)stationDic completeBlock:(void(^)(NSMutableDictionary *mutableDic))block{
     NSString *stationId = stationDic[@"id"];
    FMGetUsersAPI *api = [FMGetUsersAPI apiWithStationId:stationId];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
         MyNSLog(@"%@",request.responseJsonObject);
        NSDictionary *rootDic = request.responseJsonObject;
        NSMutableArray *arr = rootDic[@"data"];
        NSMutableDictionary *mutableDic;
        for (int i = 0; i<arr.count; i++) {
            NSDictionary *dic = arr[i];
            if (dic[@"global"]!=nil && dic[@"global"]!=[NSNull null]) {
                NSDictionary *globalDic = dic[@"global"];
                NSString * idString =  globalDic[@"id"];
                if ([_guid isEqualToString:idString]) {
                     mutableDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                    [mutableDic addEntriesFromDictionary:stationDic];
                    NSLog(@"%@",mutableDic);
                    [_cloudLoginStationArray addObject:mutableDic];
                 
                    block(mutableDic);
                }
                   [_alertView.tableView reloadData];
            }
        }
 
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
    }];
}

- (void)setChooseView{
    _alertView = [[[NSBundle mainBundle] loadNibNamed:@"ChooseAlertView" owner:self options:nil] lastObject];
    _alertView.frame = CGRectMake(0, 0, JYSCREEN_WIDTH, JYSCREEN_HEIGHT);
    _alertView.tableView.delegate = self;
    _alertView.tableView.dataSource = self;
    [_alertView.loginButton addTarget:self action:@selector(loginButtonClick:) forControlEvents:UIControlEventTouchUpInside];
   [self.view addSubview:_alertView];
    _alertView.hidden = YES;
}

- (void)loginButtonClick:(UIButton *)sender{
    [_alertView removeFromSuperview];
    _alertView =nil;
    
    NSMutableDictionary *mutableDic;
    if (_cloudLoginStationArray.count!=0) {
     mutableDic  = _cloudLoginStationArray[_current];
        
    }else{
        FMConfigInstance.userToken = nil;
        FMConfigInstance.isCloud = NO;
        [SXLoadingView showProgressHUDText:@"没有在线设备或未绑定设备" duration:1];
        return;
    }
    FMConfigInstance.userToken = _token;
    FMConfigInstance.isCloud = YES;
    FMConfigInstance.userUUID = mutableDic[@"uuid"];
    FMConfigInstance.avatarUrl = _avatarUrl;
    [[NSUserDefaults standardUserDefaults] setObject:mutableDic[@"id"] forKey:KSTATIONID_STR];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults]setObject:@0 forKey:@"addCount"];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uploadImageArr"];
    if(IsNilString(USER_SHOULD_SYNC_PHOTO) || IsEquallString(USER_SHOULD_SYNC_PHOTO, mutableDic[@"id"])){
        //设置   可备份用户为
        [[NSUserDefaults standardUserDefaults] setObject:mutableDic[@"id"] forKey:USER_SHOULD_SYNC_PHOTO_STR];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //重启photoSyncer
        //        [PhotoManager shareManager].canUpload = YES;
    }
    //重置数据
    [MyAppDelegate resetDatasource];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //保存用户信息
        FMUserLoginInfo * info = [FMUserLoginInfo new];
        if ( _nickName.length !=0) {
            info.userName = _nickName;
        }
        MyNSLog(@"登录用户:%@", info.userName);
        info.uuid = mutableDic[@"uuid"];
        //        info.deviceId = [PhotoManager getUUID];
        //            info.jwt_token = token;
        info.bonjour_name = mutableDic[@"name"] ;
        //           NSLog(@"%@",_service.hostName);
        [FMDBControl addUserLoginInfo:info];
        //     NSLog(@"%@",[FMDBControl findUserLoginInfo:_user.uuid]);
    });
    //组装UI
    //        if (def_token.length == 0 ) {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否自动备份该手机的照片至WISNUC服务器" preferredStyle:UIAlertControllerStyleAlert];
    // 2.添加取消按钮，block中存放点击了“取消”按钮要执行的操作
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"点击了取消按钮");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //                [PhotoManager shareManager].canUpload = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dontBackUp" object:nil userInfo:nil];
            NSLog(@"点击了确定按钮");
        });
    }];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"备份" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //                 [PhotoManager shareManager].canUpload = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"backUp" object:nil];
            NSLog(@"点击了确定按钮");
        });
    }];
    // 3.将“取消”和“确定”按钮加入到弹框控制器中
    [alertVc addAction:cancle];
    [alertVc addAction:confirm];
    [self presentViewController:alertVc animated:YES completion:^{
    }];

    MyAppDelegate.window.rootViewController = nil;
    [MyAppDelegate.window resignKeyWindow];
    [MyAppDelegate.window removeFromSuperview];
    MyAppDelegate.sharesTabBar = [[RDVTabBarController alloc]init];
    [MyAppDelegate initWithTabBar:MyAppDelegate.sharesTabBar];
    [MyAppDelegate.sharesTabBar setSelectedIndex:0];
    MyAppDelegate.filesTabBar = nil;
    [MyAppDelegate resetDatasource];
    MyAppDelegate.leftMenu = nil;
    
    [MyAppDelegate initLeftMenu];
    [UIApplication sharedApplication].keyWindow.rootViewController = MyAppDelegate.sharesTabBar;
}


- (void)LoginActionWithUserDic:(NSDictionary *)userDic StationDic:(NSDictionary *)stationDic{
//        NSString * def_token = DEF_Token;
        [[NSUserDefaults standardUserDefaults] setObject:stationDic[@"id"] forKey:KSTATIONID_STR];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults]setObject:@0 forKey:@"addCount"];
    
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uploadImageArr"];
        if(IsNilString(USER_SHOULD_SYNC_PHOTO) || IsEquallString(USER_SHOULD_SYNC_PHOTO, userDic[@"id"])){
            //设置   可备份用户为
            [[NSUserDefaults standardUserDefaults] setObject:userDic[@"id"] forKey:USER_SHOULD_SYNC_PHOTO_STR];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //重启photoSyncer
            //        [PhotoManager shareManager].canUpload = YES;
        }
        //重置数据
        [MyAppDelegate resetDatasource];

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //保存用户信息
            FMUserLoginInfo * info = [FMUserLoginInfo new];
            info.userName = userDic[@"nickName"];
            MyNSLog(@"登录用户:%@", info.userName);
            info.uuid = userDic[@"id"];
            //        info.deviceId = [PhotoManager getUUID];
//            info.jwt_token = token;
            info.bonjour_name = stationDic[@"name"] ;
            //           NSLog(@"%@",_service.hostName);
            [FMDBControl addUserLoginInfo:info];
            //     NSLog(@"%@",[FMDBControl findUserLoginInfo:_user.uuid]);
        });
        //组装UI
//        if (def_token.length == 0 ) {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否自动备份该手机的照片至WISNUC服务器" preferredStyle:UIAlertControllerStyleAlert];
            // 2.添加取消按钮，block中存放点击了“取消”按钮要执行的操作
            UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                NSLog(@"点击了取消按钮");
    
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //                [PhotoManager shareManager].canUpload = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"dontBackUp" object:nil userInfo:nil];
                    NSLog(@"点击了确定按钮");
                });
            }];
    
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"备份" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //                 [PhotoManager shareManager].canUpload = YES;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"backUp" object:nil];
                    NSLog(@"点击了确定按钮");
                });
            }];
            // 3.将“取消”和“确定”按钮加入到弹框控制器中
            [alertVc addAction:cancle];
            [alertVc addAction:confirm];
            [self presentViewController:alertVc animated:YES completion:^{
            }];
//        }
        MyAppDelegate.window.rootViewController = nil;
        [MyAppDelegate.window resignKeyWindow];
        [MyAppDelegate.window removeFromSuperview];
        MyAppDelegate.sharesTabBar = [[RDVTabBarController alloc]init];
        [MyAppDelegate initWithTabBar:MyAppDelegate.sharesTabBar];
        [MyAppDelegate.sharesTabBar setSelectedIndex:0];
        MyAppDelegate.filesTabBar = nil;
        [MyAppDelegate resetDatasource];
        MyAppDelegate.leftMenu = nil;
    
        [MyAppDelegate initLeftMenu];
        [UIApplication sharedApplication].keyWindow.rootViewController = MyAppDelegate.sharesTabBar;
}
//- (void)pageTurn:(UIPageControl *)pageControl{
////    NSInteger page = pageControl.currentPage;
//    
//  [_stationScrollView setContentOffset:CGPointMake(JYSCREEN_WIDTH * pageControl.currentPage, 0) animated:YES];
//
//}

#pragma mark ScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.stationScrollView &&scrollView.contentOffset.x > JYSCREEN_WIDTH/2) {
        
//    if () {
    int page = scrollView.contentOffset.x/JYSCREEN_WIDTH;
    _stationPageControl.currentPage = page;
    FMSerachService *ser = _tempDataSource[page];
    _userDataSource = ser.users;
    _userDataCount = page;
//    if (ser.ws215i && ser.ws215i.length > 0) {
//        _stationCardView.backgroundColor = UICOLOR_RGB(0x8bc3a4);
//        _stationScrollView.backgroundColor = UICOLOR_RGB(0x689f38);
//    }else{
//        _stationCardView.backgroundColor =  UICOLOR_RGB(0x03a9f4);
//        _stationScrollView.backgroundColor = UICOLOR_RGB(0x0288d1);
//    }
//        MyNSLog(@"%f",scrollView.contentOffset.x);
//        if (scrollView.contentOffset.x == JYSCREEN_WIDTH *page) {
       
//        }
//    }
   
//    if (_stationPageControl.currentPage) {
//        _stationPageControl.transform=CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
     if (scrollView == self.stationScrollView) {
      [_userListTableViwe reloadData];
     }
}

#pragma mark tableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == _alertView.tableView) {
        return _cloudLoginStationArray.count;
    }else{
        return _userDataSource.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _userListTableViwe) {
        LoginTableViewCell *cell;
        self.userListTableViwe.separatorStyle = UITableViewCellSeparatorStyleNone;
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LoginTableViewCell class])];
        if (!cell) {
            cell= [[[NSBundle mainBundle] loadNibNamed:@"LoginTableViewCell" owner:nil options:nil] lastObject];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UserModel *model = _userDataSource[indexPath.row];
        
        //    NSLog(@"%@======%lu",model.username,(unsigned long)_userDataSource.count);
        cell.userNameLabel.text = model.username;
        cell.userNameImageView.image = [UIImage imageForName:model.username size:cell.userNameImageView.bounds.size];
        
        return cell;
    }else{
     _alertView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
      FMCloudUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FMCloudUserTableViewCell class])];
        if (!cell) {
            cell= [[[NSBundle mainBundle] loadNibNamed:@"FMCloudUserTableViewCell" owner:nil options:nil] lastObject];
        }
//        NSLog(@"%@",_cloudLoginStationArray);
       NSDictionary *modelDic = _cloudLoginStationArray[indexPath.row];
       cell.userNameLabel.text = [NSString stringWithFormat:@"%@",modelDic[@"username"]];
       cell.stationName.text = [NSString stringWithFormat:@"在%@上",modelDic[@"name"]];
        return cell;
    }
    
}

#pragma mark tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == _userListTableViwe) {
        UserModel *model = _userDataSource[indexPath.row];;
        
        FMUserLoginViewController *userLoginVC = [[FMUserLoginViewController alloc]init];
        FMSerachService * ser;
        if (_userDataCount >0) {
            ser  = _tempDataSource[_userDataCount];
        }else{
            ser = _tempDataSource[0];
        }
        userLoginVC.service = ser;
        userLoginVC.user = model;
        
        [self.navigationController pushViewController:userLoginVC animated:YES];
        
        [self applicationWillResignActive:nil];
    }else{
        _current=indexPath.row;
        [_alertView.tableView reloadData];
    }
    
}

- (UITableViewCellAccessoryType)tableView:(UITableView*)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath*)indexPath
{
    
    if(tableView == _alertView.tableView){
        if(_current==indexPath.row)
        {
            return UITableViewCellAccessoryCheckmark;
        }
        else
        {
            return UITableViewCellAccessoryNone;
        }
    }else{
        return UITableViewCellAccessoryNone;
    }
   
}
- (UIScrollView *)stationScrollView{
    if (!_stationScrollView) {
        _stationScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, JYSCREEN_WIDTH,448/2 + 64)];
        _stationScrollView.backgroundColor = UICOLOR_RGB(0x0288d1);
        _stationScrollView.pagingEnabled = YES;
//        _stationScrollView.contentSize = CGSizeMake(self.tempDataSource.count * JYSCREEN_WIDTH, 0);
        _stationScrollView.delegate = self;
        _stationScrollView.bounces = YES;
        _stationScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _stationScrollView;
}

- (UIPageControl *)stationPageControl{
    if (!_stationPageControl) {
        _stationPageControl = [[StationPageControl alloc] initWithFrame:CGRectMake(0,self.stationScrollView.frame.size.height - 36 , JYSCREEN_WIDTH, 30)];
//        _stationPageControl.numberOfPages = self.tempDataSource.count;
        _stationPageControl.currentPage = 0;
    }
    return _stationPageControl;
}

- (UIImageView *)logoImageView{
    if (!_logoImageView) {
        UIImage *logoImage = [UIImage imageNamed:@"logo"];
        CGSize logoSize=logoImage.size;
        _logoImageView = [[UIImageView alloc]initWithImage:logoImage];
        _logoImageView.frame = CGRectMake(16, 40, logoSize.width, logoSize.height);
    }
    return _logoImageView;
}

-(UIView *)userView{
    if (!_userView) {
        _userView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.stationScrollView.frame) + 8, JYSCREEN_WIDTH , 40)];
        _userView.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, JYSCREEN_WIDTH - 16, 40)];
        label.text = @"用户";
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor lightGrayColor];
        [_userView addSubview:label];
    }
    return _userView;
}

- (UITableView *)userListTableViwe{
    if (!_userListTableViwe) {
        _userListTableViwe = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.userView.frame), JYSCREEN_WIDTH, JYSCREEN_HEIGHT - _stationScrollView.frame.size.height - 8 - _userView.frame.size.height -48) style:UITableViewStylePlain];
        if (![WXApi isWXAppInstalled]) {
            _userListTableViwe.frame = CGRectMake(0, CGRectGetMaxY(self.userView.frame), JYSCREEN_WIDTH, JYSCREEN_HEIGHT - _stationScrollView.frame.size.height - 8 - _userView.frame.size.height);
        }
        _userListTableViwe.delegate = self;
        _userListTableViwe.dataSource = self;
        _userListTableViwe.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _userListTableViwe;
}

- (UIView *)wechatView{
    if (!_wechatView) {
        _wechatView = [[UIView alloc]initWithFrame:CGRectMake(0, JYSCREEN_HEIGHT - 48, JYSCREEN_WIDTH, 48)];
        _wechatView.backgroundColor = [UIColor whiteColor];
        _wechatView.layer.shadowColor = [[UIColor blackColor]CGColor];
        _wechatView.layer.shadowOffset = CGSizeMake(0, 2);
        _wechatView.layer.shadowRadius = 2.0;
        _wechatView.layer.shadowOpacity = 0.4;
        _wechatView.userInteractionEnabled = YES;
        
        UIImage *wechatImage = [UIImage imageNamed:@"WeChat"];
        UIImageView *wechatImageView = [[UIImageView alloc]initWithImage:wechatImage];
        [_wechatView addSubview:wechatImageView];
        [wechatImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_wechatView.mas_centerX).offset(-30);
            make.centerY.equalTo(_wechatView.mas_centerY);
            make.size.mas_equalTo(wechatImage.size);
        }];
        
        UILabel *label = [[UILabel alloc]init];
        label.text = @"微信登录";
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor blackColor];
        label.alpha = 0.87;
        [_wechatView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wechatImageView.mas_right).offset(8);
            make.centerY.equalTo(_wechatView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(100,20));
        }];
        
        UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(wechatLoginAction:)];
        [_wechatView addGestureRecognizer:tapGesture];
    }
    return _wechatView;
}

- (UIButton *)handButton{
    if (!_handButton) {
        _handButton = [[UIButton alloc]initWithFrame:CGRectMake(JYSCREEN_WIDTH - 16 - 30 , CGRectGetMinY(_logoImageView.frame) - 5, 30, 30)];
        [_handButton setImage:[UIImage imageNamed:@"PLUS"] forState:UIControlStateNormal];
        [_handButton addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_handButton setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
      }
    return _handButton;
}
@end
