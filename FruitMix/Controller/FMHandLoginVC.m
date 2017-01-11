//
//  FMHandLoginVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/7/7.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMHandLoginVC.h"
#import "DGPopUpViewTextView.h"
#import "NavViewController.h"
#import "FMShareViewController.h"
#import "FMAlbumsViewController.h"
#import "FMPhotosViewController.h"
#import "FMSlideMenuControllerViewController.h"
#import "FMSlideMenuController.h"
#import "TabBarViewController.h"

#import "RDVTabBarItem.h"
#import "FMGetJWTAPI.h"

@interface FMHandLoginVC ()

@property (nonatomic, strong) DGPopUpViewTextView *textView;
@property (nonatomic, strong) DGPopUpViewTextView *textView_2;
@property (nonatomic, strong) DGPopUpViewTextView *textView_3;


@property (nonatomic) UILabel * Lb1;
@property (nonatomic) UILabel * Lb2;
@property (nonatomic) UILabel * Lb3;

@end

@implementation FMHandLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"手动设置";
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self  action:@selector(handlerTap)];
    [self.view addGestureRecognizer:tap];
    [self initView];
    [self addNavBtn];
    
}

-(BOOL)checkIPIsValidate{
    NSString * pre = @"[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}:[0-9]{2,5}";
    NSPredicate * check = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pre];
    return [check evaluateWithObject:self.textView.textField.text];
}

-(void)addNavBtn{
    UIButton * rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
    rBtn.titleLabel.font = [UIFont fontWithName:FANGZHENG size:16];
    [rBtn setTitle:@"完成" forState:UIControlStateNormal];
    [rBtn addTarget:self action:@selector(rBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * item = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = item;
}

-(void)rBtnClick{
    if(![self checkIPIsValidate]){
        [SXLoadingView showAlertHUD:@"IP输入有误！" duration:1];
        return;
    }
    if (self.block) {
        FMSerachService * ser = [[FMSerachService alloc]init];
        ser.path = [NSString stringWithFormat:@"http://%@/",self.textView.textField.text];
        ser.name = @"WISNUC";
        if(self.textView.textField.text)
            ser.displayPath = [self.textView.textField.text componentsSeparatedByString:@":"][0];
        self.block(ser);
    }
    self.block = nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)handlerTap{
    [self.view endEditing:YES];
}

- (void)initView{
   
    self.textView = [[DGPopUpViewTextView alloc] initWithName:@"IP" andPlaceHolder:@"请输入IP地址"];
//    self.textView_2 = [[DGPopUpViewTextView alloc] initWithName:@"Username" andPlaceHolder: @"用户名"];
//    self.textView_3 = [[DGPopUpViewTextView alloc] initWithName:@"Password" andPlaceHolder:@"密码"];
//    self.textView_3.textField.secureTextEntry = YES;

    [self.view addSubview: self.textView];
//    [self.view addSubview: self.textView_2];
//    [self.view addSubview: self.textView_3];
    
    [self setlayout];
   
}
- (void) setlayout {
    
    self.textView.frame = CGRectMake((__kWidth- 300)/2, 60, 300, 60);
//    self.textView_2.frame = CGRectMake((__kWidth- 300)/2, 140, 300, 60);
//    self.textView_3.frame = CGRectMake((__kWidth- 300)/2, 220, 300, 60);
    
}
@end
