//
//  FMUserLoginViewController.m
//  FruitMix
//
//  Created by wisnuc on 2017/8/15.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMUserLoginViewController.h"
#import "FMLoginTextField.h"
#import "UIButton+EnlargeEdge.h"
#import "FMGetUserInfo.h"
#import "FMUploadFileAPI.h"
#define  MainColor  UICOLOR_RGB(0x03a9f4)

@interface FMUserLoginViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) UIView *navigationView;
@property (strong, nonatomic) UIView *userNameBackgroudView;
@property (strong, nonatomic) UIImageView *userNameView;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIImageView *leftTextFieldImageView;
@property (strong, nonatomic) FMLoginTextField *loginTextField;
@property (strong, nonatomic) UILabel *passwordLabel;
@property (strong, nonatomic) UIButton *eyeButton;
@end

@implementation FMUserLoginViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:animated];
    [self.loginTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.loginTextField resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.loginTextField resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.navigationView];
    [self.view addSubview:self.userNameBackgroudView];
    [self setShadowForUserNameView];
    [self.userNameBackgroudView addSubview:self.userNameView];
    [self.view addSubview:self.loginButton];
    [self.view addSubview:self.leftTextFieldImageView];
    [self.view addSubview:self.passwordLabel];
    [self.view addSubview:self.loginTextField];
    [self.view addSubview:[self setTextFieldLine]];
    [self.view addSubview:self.eyeButton];
}

#pragma mark textFiledDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
     [self.view endEditing:YES];
    return YES;
}

- (void)eyeButtonAction:(UIButton *)sender{
      sender.selected = !sender.selected;
    if (!sender.selected) {
        _loginTextField.secureTextEntry = YES;
    }else{
        _loginTextField.secureTextEntry = NO;
    }
}

- (void)loginButtonClick:(UIButton *)sender{
    [self.view endEditing:YES];
    sender.userInteractionEnabled = NO;
    
    
    [SXLoadingView showProgressHUD:@"正在登录"];
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    NSString * UUID = [NSString stringWithFormat:@"%@:%@",_user.uuid,IsNilString(_loginTextField.text)?@"":_loginTextField.text];
    NSString * Basic = [UUID base64EncodedString];
//    NSLog(@"%@, %@", UUID, Basic);
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Basic %@",Basic] forHTTPHeaderField:@"Authorization"];
    [manager GET:[NSString stringWithFormat:@"%@token",_service.path] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"%@",responseObject);
        [SXLoadingView hideProgressHUD];
        [FMDBControl asyncLoadPhotoToDB];
        [self loginToDoWithResponse:responseObject];
        sender.userInteractionEnabled = YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SXLoadingView hideProgressHUD];
        NSHTTPURLResponse * res = (NSHTTPURLResponse *)task.response;
        [SXLoadingView showAlertHUD:[NSString stringWithFormat:@"登录失败:%ld",(long)res.statusCode] duration:1];
        sender.userInteractionEnabled = YES;
        NSLog(@"%@",error);
    }];
}

//登录完成 做的事
-(void)loginToDoWithResponse:(id)response{
    NSString * token = response[@"token"];
//    [FMDBControl reloadTables];
    [[NSUserDefaults standardUserDefaults]setObject:@0 forKey:@"addCount"];
    [_service.task cancel];
    NSString * def_token = DEF_Token;

    MyNSLog(@"登录");
       //判断是否为同一用户退出后登录
    if (!IsNilString(DEF_UUID) && !IsEquallString(DEF_UUID, _user.uuid) ) {
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  //清除deviceID
}
    FMConfigInstance.userToken = token;
    FMConfigInstance.userUUID = _user.uuid;
    //更新图库
    JYRequestConfig * config = [JYRequestConfig sharedConfig];
    config.baseURL = self.service.path;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"uploadImageArr"];
    if(IsNilString(USER_SHOULD_SYNC_PHOTO) || IsEquallString(USER_SHOULD_SYNC_PHOTO, _user.uuid)){
        //设置   可备份用户为
        [[NSUserDefaults standardUserDefaults] setObject:_user.uuid forKey:USER_SHOULD_SYNC_PHOTO_STR];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //重启photoSyncer
//        [PhotoManager shareManager].canUpload = YES;
    }
    //重置数据
    [MyAppDelegate resetDatasource];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //保存用户信息
        FMUserLoginInfo * info = [FMUserLoginInfo new];
        info.userName = _user.username;
        MyNSLog(@"登录用户:%@",_user.username);
        info.uuid = _user.uuid;
        //        info.deviceId = [PhotoManager getUUID];
        info.jwt_token = token;
        info.bonjour_name = _service.hostName;
//           NSLog(@"%@",_service.hostName);
        [FMDBControl addUserLoginInfo:info];
//     NSLog(@"%@",[FMDBControl findUserLoginInfo:_user.uuid]);
    });
    //组装UI
    if (def_token.length == 0 ) {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否自动备份该手机的照片至WISNUC服务器" preferredStyle:UIAlertControllerStyleAlert];
        // 2.添加取消按钮，block中存放点击了“取消”按钮要执行的操作
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"点击了取消按钮");
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //                [PhotoManager shareManager].canUpload = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"dontBackUp" object:nil userInfo:nil];
                NSLog(@"点击了确定按钮");
            });
        }];
        
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"备份" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
    }
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
//    [self siftPhotos];
}

- (void)siftPhotos{
    @weaky(self)
    NSString *entryuuid = PHOTO_ENTRY_UUID;
    if (entryuuid.length == 0) {
        [FMUploadFileAPI getDriveInfoCompleteBlock:^(BOOL successful) {
            if (successful) {
                [FMUploadFileAPI getDirectoriesForPhotoCompleteBlock:^(BOOL successful) {
                    if (successful) {
                        [FMUploadFileAPI creatPhotoDirEntryCompleteBlock:^(BOOL successful) {
                            if (successful) {
                                [FMUserLoginViewController siftPhotoFromNetwork];
                            }
                        }];
                    }
                }];
            }
        }];
  
    }else{
        [FMUserLoginViewController siftPhotoFromNetwork];
    }
}

+ (void)siftPhotoFromNetwork{
    @weaky(self)
//    NSCondition *condition = [[NSCondition alloc] init];
//    [condition lock];
    NSString *entryuuid = PHOTO_ENTRY_UUID;
    [FMUploadFileAPI getDirEntryWithUUId:entryuuid success:^(NSURLSessionDataTask *task, id responseObject) {
        //NSLog(@"%@",responseObject);
        NSDictionary * dic = responseObject;
        NSMutableArray * photoArrHash = [NSMutableArray arrayWithCapacity:0];
        
        NSArray * arr = [dic objectForKey:@"entries"];
        for (NSDictionary *dic in arr) {
            FMNASPhoto *nasPhoto = [FMNASPhoto yy_modelWithJSON:dic];
            [photoArrHash addObject:nasPhoto.fmhash];
        }
        [FMDBControl getDBAllLocalPhotosWithCompleteBlock:^(NSArray<FMLocalPhoto *> *result) {
            NSMutableArray *localPhotoHashArr = [NSMutableArray arrayWithCapacity:0];
            for (FMLocalPhoto * p in result) {
                if (p.degist.length >0) {
                    [localPhotoHashArr addObject:p.degist];
                }
            }
            NSSet *photoArrHashSet = [NSSet setWithArray:photoArrHash];
            NSSet *localPhotoHashArrSet = [NSSet setWithArray:localPhotoHashArr];
            
            NSPredicate * filterPredicate_same = [NSPredicate predicateWithFormat:@"SELF IN %@",[localPhotoHashArrSet allObjects]];
            NSArray * filter_no = [[photoArrHashSet allObjects] filteredArrayUsingPredicate:filterPredicate_same];
            NSMutableArray * siftPhotoArrHash  = [NSMutableArray arrayWithCapacity:0];
            [siftPhotoArrHash addObjectsFromArray:filter_no];
//            NSLog(@"😜😜😜😜😜%ld",(long)filter_no.count);
            [[NSUserDefaults standardUserDefaults] setObject:siftPhotoArrHash forKey:@"uploadImageArr"];
            [[NSUserDefaults standardUserDefaults]  synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"siftPhoto" object:nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"siftPhotoForLeftMenu" object:nil];
        }];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSHTTPURLResponse * rep = (NSHTTPURLResponse *)task.response;
        NSLog(@"%ld",(long)rep.statusCode);
        if (rep.statusCode == 404) {
            [FMUploadFileAPI getDriveInfoCompleteBlock:^(BOOL successful) {
                if (successful) {
                    [FMUploadFileAPI getDirectoriesForPhotoCompleteBlock:^(BOOL successful) {
                        if (successful) {
                            [FMUploadFileAPI creatPhotoDirEntryCompleteBlock:^(BOOL successful) {
                                if (successful) {
                                    [weak_self siftPhotos];
                                }
                            }];
                        }
                    }];
                }
            }];
        }
    }];
//     [condition wait];
//    [condition unlock];
}

#pragma mark - 验证手机号
+(BOOL)checkForMobilePhoneNo:(NSString *)mobilePhone{
    
    NSString *regEx = @"^1[3|4|5|7|8][0-9]\\d{8}$";
    return [self baseCheckForRegEx:regEx data:mobilePhone];
}

#pragma mark - 私有方法
/**
 *  基本的验证方法
 *
 *  @param regEx 校验格式
 *  @param data  要校验的数据
 *
 *  @return YES:成功 NO:失败
 */
+(BOOL)baseCheckForRegEx:(NSString *)regEx data:(NSString *)data{
    
    NSPredicate *card = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    
    if (([card evaluateWithObject:data])) {
        return YES;
    }
    return NO;
}

- (UILabel *)setTextFieldLine{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_loginTextField.frame), CGRectGetMaxY(_loginTextField.frame) + 8, _loginTextField.frame.size.width, 1)];
    label.backgroundColor = COR1;
    return label;
}

- (void)setShadowForUserNameView {
    UIView *userNameShadow = [[UIView alloc]init];
    userNameShadow.frame = CGRectMake(0, 0, 100, 100);
    userNameShadow.center = CGPointMake(JYSCREEN_WIDTH/2, _userNameBackgroudView.frame.size.height/2 -25);
    userNameShadow.backgroundColor = [UIColor whiteColor];
    userNameShadow.alpha = 0.12;
    userNameShadow.layer.masksToBounds = YES;
    userNameShadow.layer.cornerRadius = 50;
    [self.userNameBackgroudView addSubview:userNameShadow];
}

- (void)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)navigationView{
    if (!_navigationView) {
        _navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, JYSCREEN_WIDTH, 64)];
        _navigationView.backgroundColor = MainColor;
        UIImage *image = [UIImage imageNamed:@"back"];
        UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(16, CGRectGetMidY(_navigationView.frame), image.size.width, image.size.height)];
        [backButton setImage:image forState:UIControlStateNormal];
        [backButton setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
        [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        [_navigationView addSubview:backButton];
    }
    return _navigationView;
}

- (UIView *)userNameBackgroudView{
    if (!_userNameBackgroudView) {
        _userNameBackgroudView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_navigationView.frame), JYSCREEN_WIDTH , 160)];
        _userNameBackgroudView.backgroundColor = MainColor;
    }
    return _userNameBackgroudView;
}

- (UIImageView *)userNameView{
    if (!_userNameView) {
        _userNameView = [[UIImageView alloc]init];
        _userNameView.frame = CGRectMake(0, 0, 88, 88);
        _userNameView.center = CGPointMake(JYSCREEN_WIDTH/2, _userNameBackgroudView.frame.size.height/2 - 25);
        _userNameView.backgroundColor = [UIColor whiteColor];
        _userNameView.layer.masksToBounds = YES;
        _userNameView.layer.cornerRadius = 44;
        _userNameView.image = [UIImage imageWhiteForName:_user.username size:_userNameView.bounds.size];
    }
    return _userNameView;
}

- (UIButton *)loginButton{
    if (!_loginButton) {
        _loginButton = [UIButton buttionWithTitle:@"登录" target:self action:@selector(loginButtonClick:)];
    }
    return _loginButton;
}

- (UIImageView *)leftTextFieldImageView{
    if (!_leftTextFieldImageView) {
        UIImage *image = [UIImage imageNamed:@"key"];
        _leftTextFieldImageView = [[UIImageView alloc]initWithImage:image];
        _leftTextFieldImageView.frame = CGRectMake(16, CGRectGetMaxY(_userNameBackgroudView.frame) + 32 + 8 +15, image.size.width, image.size.height);
    }
    return _leftTextFieldImageView;
}

-(UILabel *)passwordLabel{
    if (!_passwordLabel) {
        _passwordLabel = [[UILabel alloc]initWithFrame:CGRectMake(16+CGRectGetMaxX(_leftTextFieldImageView.frame), CGRectGetMaxY(_userNameBackgroudView.frame) + 32, 100, 15)];
        _passwordLabel.text = @"密码";
        _passwordLabel.font = [UIFont systemFontOfSize:12];
        _passwordLabel.textColor = COR3;
        _passwordLabel.alpha = 0.54;
    }
    return _passwordLabel;
}
- (FMLoginTextField *)loginTextField{
    if (!_loginTextField) {
        _loginTextField = [[FMLoginTextField alloc]initWithFrame:CGRectMake(CGRectGetMinX(_passwordLabel.frame), CGRectGetMaxY(_passwordLabel.frame) + 8, JYSCREEN_WIDTH - CGRectGetMinX(_passwordLabel.frame) - 16, 20)];
        _loginTextField.secureTextEntry = YES;
        _loginTextField.returnKeyType = UIReturnKeyDone;
        _loginTextField.delegate = self;
    }
    return _loginTextField;
}

- (UIButton *)eyeButton{
    if (!_eyeButton) {
        UIImage *imageEye = [UIImage imageNamed:@"eye"];
        UIImage *imageEyeOff = [UIImage imageNamed:@"eye_off"];
        _eyeButton = [[UIButton alloc]initWithFrame:CGRectMake(JYSCREEN_WIDTH - 16 - imageEye.size.width, CGRectGetMinY(_leftTextFieldImageView.frame),imageEye.size.width , imageEye.size.height)];
        [_eyeButton setEnlargeEdgeWithTop:3 right:3 bottom:3 left:3];
        [_eyeButton setImage:imageEye forState:UIControlStateSelected];
        [_eyeButton setImage:imageEyeOff forState:UIControlStateNormal];
        [_eyeButton addTarget:self action:@selector(eyeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _eyeButton;
}
@end
