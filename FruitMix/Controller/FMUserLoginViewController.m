//
//  FMUserLoginViewController.m
//  FruitMix
//
//  Created by wisnuc on 2017/8/15.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMUserLoginViewController.h"
#import "FMLoginTextField.h"

#define  MainColor  UICOLOR_RGB(0x03a9f4)

@interface FMUserLoginViewController ()
@property (strong, nonatomic) UIView *navigationView;
@property (strong, nonatomic) UIView *userNameBackgroudView;
@property (strong, nonatomic) UIView *userNameView;
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
- (void)eyeButtonAction:(UIButton *)sender{
      sender.selected = !sender.selected;
    if (!sender.selected) {
        _loginTextField.secureTextEntry = YES;
    }else{
        _loginTextField.secureTextEntry = NO;
    }
}

- (void)loginButtonClick:(UIButton *)sender{
    
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

- (UIView *)userNameView{
    if (!_userNameView) {
        _userNameView = [[UIView alloc]init];
        _userNameView.frame = CGRectMake(0, 0, 88, 88);
        _userNameView.center = CGPointMake(JYSCREEN_WIDTH/2, _userNameBackgroudView.frame.size.height/2 - 25);
        _userNameView.backgroundColor = [UIColor whiteColor];
        _userNameView.layer.masksToBounds = YES;
        _userNameView.layer.cornerRadius = 44;
    }
    return _userNameView;
}

- (UIButton *)loginButton{
    if (!_loginButton) {
        _loginButton = [UIButton buttionWithTitle:@"确定" target:self action:@selector(loginButtonClick:)];
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
        
    }
    return _loginTextField;
}

- (UIButton *)eyeButton{
    if (!_eyeButton) {
        UIImage *imageEye = [UIImage imageNamed:@"eye"];
        UIImage *imageEyeOff = [UIImage imageNamed:@"eye_off"];
        _eyeButton = [[UIButton alloc]initWithFrame:CGRectMake(JYSCREEN_WIDTH - 16 - imageEye.size.width, CGRectGetMinY(_leftTextFieldImageView.frame),imageEye.size.width , imageEye.size.height)];
        [_eyeButton setImage:imageEye forState:UIControlStateSelected];
        [_eyeButton setImage:imageEyeOff forState:UIControlStateNormal];
        [_eyeButton addTarget:self action:@selector(eyeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _eyeButton;
}
@end
