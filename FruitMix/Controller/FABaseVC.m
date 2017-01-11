//
//  FABaseVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/12/6.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FABaseVC.h"

@interface FABaseVC ()

@end

@implementation FABaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIView * redView = [[UIView alloc]initWithFrame:CGRectMake(0, -20, __kWidth, 20)];
    redView.backgroundColor = StatusBar_Color;
    [self.navigationController.navigationBar addSubview:redView];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [MyAppDelegate.notification dismissNotification];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
