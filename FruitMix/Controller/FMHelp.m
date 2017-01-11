//
//  FMHelp.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMHelp.h"

@interface FMHelp ()

@end

@implementation FMHelp

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    [self createNavbtn];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] andSEL:@selector(backbtnClick:)];
}

- (IBAction)returnBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)createNavbtn{
//    UIButton * backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 30, 50, 20)];
//    [backBtn addTarget:self  action:@selector(backbtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [backBtn setImage:[UIImage imageNamed:@"arrow_back"] forState:UIControlStateNormal];
//    UIBarButtonItem * item1 = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
//    self.navigationItem.leftBarButtonItem = item1;
    
    UIButton * finishBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 30, 50, 20)];
    [finishBtn addTarget:self  action:@selector(backbtnClick:) forControlEvents:UIControlEventTouchUpInside];
    finishBtn.titleLabel.font = [UIFont fontWithName:FANGZHENG size:16];
    //    [finishBtn setImage:[UIImage imageNamed:@"arrow_back"] forState:UIControlStateNormal];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    UIBarButtonItem * item2 = [[UIBarButtonItem alloc]initWithCustomView:finishBtn];
    self.navigationItem.rightBarButtonItem = item2;
    
}


-(void)backbtnClick:(UIButton *)back{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
