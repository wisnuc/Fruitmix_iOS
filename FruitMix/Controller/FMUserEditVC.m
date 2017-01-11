//
//  FMUserEditVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/12/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMUserEditVC.h"
#import "FMChangePwdVC.h"

#import "LCActionSheet.h"
#import "FMChooseHeaderVC.h"
#import "YSHYClipViewController.h"

@interface FMUserEditVC ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ClipViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *headerEditBtn;

@property (weak, nonatomic) IBOutlet UITextField *userNameTF;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@end

@implementation FMUserEditVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑用户信息";
    self.backgroundView.backgroundColor = UICOLOR_RGB(0x3f51b5);
}

- (IBAction)changeAvater:(id)sender {
    LCActionSheet *actionSheet = [LCActionSheet sheetWithTitle:@"重置头像" cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
        if(buttonIndex == 1){
            //资源类型为照相机
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            //判断是否有相机
            if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.sourceType = sourceType;
                [self presentViewController:picker animated:YES completion:^{
                    [UIApplication sharedApplication].statusBarHidden = YES;
                }];
            }else {
                NSLog(@"该设备无摄像头");
            }
        }else{
            FMChooseHeaderVC * vc = [[FMChooseHeaderVC alloc]init];
            vc.title = @"选择头像";
            [self.navigationController pushViewController:vc animated:YES];
        }
    } otherButtonTitles:@"照相机",@"选择我的照片", nil];
    [actionSheet show];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navLine"]
                       forBarPosition:UIBarPositionAny
                           barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.layer.shadowOpacity = 0;
}
- (IBAction)changePwdBtn:(id)sender {
    FMChangePwdVC * vc = [[FMChangePwdVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    
    YSHYClipViewController * clipView = [[YSHYClipViewController alloc]initWithImage:image];
    clipView.delegate = self;
    clipView.clipType = CIRCULARCLIP;
    [picker dismissViewControllerAnimated:NO completion:^{
         [UIApplication sharedApplication].statusBarHidden = NO;
    }];
    [self.navigationController pushViewController:clipView animated:YES];
//    PhotoViewController *photoVC = [[PhotoViewController alloc] init];
//    photoVC.oldImage = image;
//    //    photoVC.btnBackgroundColor = COLOR_NAV;
//    //    photoVC.backImage = ;自定义返回按钮图片
//    photoVC.mode = PhotoMaskViewModeCircle;
//    photoVC.cropWidth = CGRectGetWidth(self.view.bounds) - 80;
//    photoVC.isDark = YES;
//    photoVC.delegate = self;
//    //    photoVC.lineColor = COLOR_NAV;
//    [picker pushViewController:photoVC animated:YES];
}

-(void)ClipViewController:(YSHYClipViewController *)clipViewController FinishClipImage:(UIImage *)editImage{
    
}
@end
