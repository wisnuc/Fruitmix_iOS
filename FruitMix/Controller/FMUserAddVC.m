//
//  FMUserAddVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/29.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMUserAddVC.h"
#import "FMCreateUserAPI.h"

@interface FMUserAddVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *doubleCheckTF;

@property (nonatomic) id navDelegate;

@end

@implementation FMUserAddVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.userNameTF.returnKeyType = UIReturnKeyDone;
    self.userNameTF.delegate = self;
    self.passwordTF.returnKeyType = UIReturnKeyDone;
    self.doubleCheckTF.returnKeyType = UIReturnKeyDone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self.navDelegate;
}



- (IBAction)addBtnClick:(id)sender {
    if (![NSString isUserName:_userNameTF.text]) {
        [SXLoadingView  showProgressHUDText:@"用户名含有非法字符!" duration:1];
        return;
    }
    
    if (![NSString isPassword:_passwordTF.text]) {
        [SXLoadingView  showProgressHUDText:@"密码不符合规则!" duration:1];
        return;
    }
    if (self.userNameTF.text.length<=0)
        [SXLoadingView  showProgressHUDText:@"请输入用户名!" duration:1];
    else if(self.userNameTF.text.length >= 16)
     [SXLoadingView  showProgressHUDText:@"用户名过长!" duration:1];
    else if(self.passwordTF.text.length >= 30)
     [SXLoadingView  showProgressHUDText:@"密码过长!" duration:1];
    else if(!IsEquallString(self.passwordTF.text, self.doubleCheckTF.text))
     [SXLoadingView  showProgressHUDText:@"两次密码不一致！" duration:1];
    else{
        FMCreateUserAPI * api = [FMCreateUserAPI new];
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
//         [dic setObject:@"local" forKey:@"type"];
        [dic setObject:self.userNameTF.text forKey:@"username"];
        [dic setObject:IsNilString(self.passwordTF.text)?@"":self.passwordTF.text forKey:@"password"];
        api.param = dic;
        [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            [MyAppDelegate.notification displayNotificationWithMessage:@"创建用户成功" forDuration:1];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(__kindof JYBaseRequest *request) {
            NSLog(@"%@",request.error);
            [MyAppDelegate.notification displayNotificationWithMessage:@"创建用户失败" forDuration:1];
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
     [textField resignFirstResponder];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    if (textField == _userNameTF) {
//        if (string.length == 0) {
//            return YES;
//        }
//        else if (textField.text.length + string.length >20 ) {
//            [MyAppDelegate.notification displayNotificationWithMessage:@"用户名称不能大于!" forDuration:1];
//            return NO;
//        }
//    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
