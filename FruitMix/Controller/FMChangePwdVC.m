//
//  FMChangePwdVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/12/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMChangePwdVC.h"

@interface FMChangePwdVC ()
@property (weak, nonatomic) IBOutlet UITextField *pwdTF;
@property (weak, nonatomic) IBOutlet UITextField *rePwdTF;

@end

@implementation FMChangePwdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 48, 48)];
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont fontWithName:FANGZHENG size:16];
    rightBtn.titleLabel.textColor = UICOLOR_RGB(0xffffff);
    UIBarButtonItem *negativeSpacer = [[ UIBarButtonItem alloc ]
                                       initWithBarButtonSystemItem : UIBarButtonSystemItemFixedSpace
                                       target : nil action : nil ];
    negativeSpacer. width = -8;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,[[UIBarButtonItem alloc]initWithCustomView:rightBtn]];
}

-(void)rightBtnClick:(UIButton *)btn{
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


@end
