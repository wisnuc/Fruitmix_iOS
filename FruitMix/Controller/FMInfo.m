//
//  FMInfo.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMInfo.h"
#import "MFTextField.h"
#import "UIColor+MaterialTextField.h"
#import "MXParallaxHeader.h"
#import "FMCommentHeader.h"
#import "MXScrollView.h"
#import "LCActionSheet.h"
#import "FMChooseHeaderVC.h"

@interface FMInfo ()<UITextFieldDelegate>
@property (nonatomic)  MXScrollView *contentScrollView;

@property (nonatomic)  UIButton *userHeadImageView;
@property (nonatomic)  UILabel *userNameLb;
@property (nonatomic)  MFTextField *emialTF;
@property (nonatomic)  MFTextField *passwordTF;
@property (nonatomic)  MFTextField *secondPWTF;

@property (nonatomic) id navDelegate;
@end

@implementation FMInfo

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    self.navDelegate =  self.navigationController.interactivePopGestureRecognizer.delegate;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
//    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] andSEL:@selector(backbtnClick:)];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self.navDelegate;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"用户信息";
    [self configScrollView];
}

-(void)configScrollView{
    CGRect frame = self.view.frame;
    self.contentScrollView = [[MXScrollView alloc]initWithFrame:frame];
    [self.view addSubview:self.contentScrollView];
    self.contentScrollView.contentSize = frame.size;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap)];
    [self.contentScrollView addGestureRecognizer:tap];
    
    FMCommentHeader * headView = [[FMCommentHeader alloc]initWithFrame:CGRectMake(0, 0, __kWidth, 300)];
    headView.headImageView.image = [UIImage imageNamed:@"img_bg.jpg"];
    self.contentScrollView.parallaxHeader.view = headView;
    self.contentScrollView.parallaxHeader.height = 200;
    self.contentScrollView.parallaxHeader.mode = MXParallaxHeaderModeFill;
    self.contentScrollView.parallaxHeader.minimumHeight = 100;
    
    self.userHeadImageView = [[UIButton alloc]initWithFrame:CGRectMake(30, -57/2, 57, 57)];
    [self.userHeadImageView setImage:[UIImage imageForName:[FMConfigInstance getUserNameWithUUID:DEF_UUID] size:self.userHeadImageView.bounds.size] forState:UIControlStateNormal];
    [self.userHeadImageView addTarget:self action:@selector(userHeaderClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentScrollView addSubview:self.userHeadImageView];
    
    
    self.userNameLb = [[UILabel alloc]initWithFrame:CGRectMake(self.userHeadImageView.jy_Right+10, 0, self.contentScrollView.jy_Width - self.userHeadImageView.jy_Right - 50, 25)];
    self.userNameLb.font = [UIFont fontWithName:DONGQING size:18];
    self.userNameLb.text = [FMConfigInstance getUserNameWithUUID:DEF_UUID];
    [self.contentScrollView addSubview:self.userNameLb];
    
    [self configEmail];
    [self configPW];
    [self configSecondPW];
    [self configCheckBox];
    [self createNavbtn];
}

-(void)userHeaderClick{
    LCActionSheet *actionSheet = [LCActionSheet sheetWithTitle:@"重置头像" cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
        
        FMChooseHeaderVC * vc = [[FMChooseHeaderVC alloc]init];
        vc.title = @"选择头像";
        [self.navigationController pushViewController:vc animated:YES];
        
    } otherButtonTitles:@"选择我的照片", nil];
    [actionSheet show];
}

-(void)handleTap{
    [self.view endEditing:YES];
}


-(void)configEmail{
    //emialTF
    
    self.emialTF = [[MFTextField alloc]initWithFrame:CGRectMake(30,60,__kWidth-60,40)];
    [self.contentScrollView addSubview:self.emialTF];
    self.emialTF.tintColor = UICOLOR_RGB(0xf57e00);
    self.emialTF.textColor = [UIColor mf_veryDarkGrayColor];
    self.emialTF.defaultPlaceholderColor = [UIColor mf_darkGrayColor];
    self.emialTF.placeholderAnimatesOnFocus = YES;
    self.emialTF.delegate = self;
    UIFontDescriptor * fontDescriptor = [self.emialTF.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    UIFont *font = [UIFont fontWithDescriptor:fontDescriptor size:self.emialTF.font.pointSize];
    
    self.emialTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"邮箱" attributes:@{NSFontAttributeName:font}];
}

-(void)configPW{
    //passwordTF
    self.passwordTF = [[MFTextField alloc]initWithFrame:CGRectMake(30,self.emialTF.jy_Bottom+20,__kWidth-60,40)];
    [self.contentScrollView addSubview:self.passwordTF];
    self.passwordTF.tintColor = UICOLOR_RGB(0xf57e00);
    self.passwordTF.textColor = [UIColor mf_veryDarkGrayColor];
    self.passwordTF.defaultPlaceholderColor = [UIColor mf_darkGrayColor];
    self.passwordTF.placeholderAnimatesOnFocus = YES;
    self.passwordTF.secureTextEntry = YES;
    self.passwordTF.delegate = self;
    UIFontDescriptor * fontDescriptor = [self.passwordTF.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    UIFont *font = [UIFont fontWithDescriptor:fontDescriptor size:self.passwordTF.font.pointSize];
    self.passwordTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密码" attributes:@{NSFontAttributeName:font}];
}
-(void)configSecondPW{
    //secondPWTF
    self.secondPWTF = [[MFTextField alloc]initWithFrame:CGRectMake(30,self.passwordTF.jy_Bottom+20,__kWidth-60,40)];
    [self.contentScrollView addSubview:self.secondPWTF];
    self.secondPWTF.tintColor = UICOLOR_RGB(0xf57e00);
    self.secondPWTF.textColor = [UIColor mf_veryDarkGrayColor];
    self.secondPWTF.defaultPlaceholderColor = [UIColor mf_darkGrayColor];
    self.secondPWTF.placeholderAnimatesOnFocus = YES;
    self.secondPWTF.delegate = self;
    self.secondPWTF.secureTextEntry = YES;
    UIFontDescriptor * fontDescriptor = [self.secondPWTF.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    UIFont *font = [UIFont fontWithDescriptor:fontDescriptor size:self.secondPWTF.font.pointSize];
    self.secondPWTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"确认密码" attributes:@{NSFontAttributeName:font}];
}


-(void)configCheckBox{
    NSLog(@"%f",__kWidth);
    UIButton * checkBoxBtn = [[UIButton alloc]initWithFrame:CGRectMake(__kWidth/2-80, self.secondPWTF.jy_Bottom +25, 60, 60)];
    [checkBoxBtn addTarget:self action:@selector(checkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [checkBoxBtn setImage:[UIImage imageNamed:@"check-box_select"] forState:UIControlStateNormal];
    [self.contentScrollView addSubview:checkBoxBtn];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(checkBoxBtn.jy_Right, checkBoxBtn.jy_Top+20, 100, 20)];
    label.text = @"密码登录";
    label.font =[UIFont fontWithName:DONGQING size:16];
    [self.contentScrollView addSubview:label];
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

- (void)checkBtnClick:(id)sender {
    
}


- (void)returnBtnClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField{
        [self.contentScrollView setContentOffset:CGPointMake(0, textField.jy_Bottom) animated:YES];
}

@end
