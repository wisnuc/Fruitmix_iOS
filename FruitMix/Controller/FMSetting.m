//
//  FMSetting.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMSetting.h"
#import "LCActionSheet.h"

@interface FMSetting ()<UITableViewDelegate,UITableViewDataSource,LCActionSheetDelegate>
@property (nonatomic) id navDelegate;

@end

@implementation FMSetting

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    self.view.backgroundColor = [UIColor whiteColor];
//    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.settingTableView.tableFooterView = [UIView new];
    [self createNavbtn];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.settingTableView reloadData];
//    self.navDelegate =  self.navigationController.interactivePopGestureRecognizer.delegate;
//    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
//    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] andSEL:@selector(backbtnClick:)];

}




-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    self.navigationController.interactivePopGestureRecognizer.delegate = self.navDelegate;
}


-(void)createNavbtn{
//    UIButton * finishBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 30, 50, 20)];
//    [finishBtn addTarget:self  action:@selector(backbtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    finishBtn.titleLabel.font = [UIFont fontWithName:FANGZHENG size:16];
//    //    [finishBtn setImage:[UIImage imageNamed:@"arrow_back"] forState:UIControlStateNormal];
//    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
//    UIBarButtonItem * item2 = [[UIBarButtonItem alloc]initWithCustomView:finishBtn];
//    self.navigationItem.rightBarButtonItem = item2;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"123"];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"照片自动备份:";
        UISwitch * switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];
        switchBtn.on = IsEquallString(DEF_UUID, USER_SHOULD_SYNC_PHOTO);
        [switchBtn addTarget:self  action:@selector(switchBtnHandleForSync:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchBtn;
    }
    if (indexPath.row == 1) {
        cell.textLabel.text = @"手机网络上传:";
        UISwitch * switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];
        switchBtn.on = SHOULD_WLNN_UPLOAD;
        [switchBtn addTarget:self  action:@selector(switchBtnHandleForWWNN:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchBtn;
    }else if(indexPath.row == 2){
        cell.textLabel.text = @"清除缓存";
        UIButton * cleanBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, 40)];
        cleanBtn.userInteractionEnabled = NO;
        [cleanBtn setTitle:@"正在计算..." forState:UIControlStateNormal];
        cleanBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [cleanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSUInteger  i = [SDImageCache sharedImageCache].getSize;
            NSLog(@"%ld",[[YYImageCache sharedCache].diskCache totalCost]);
            i = i + [[YYImageCache sharedCache].diskCache totalCost];
            dispatch_async(dispatch_get_main_queue(), ^{
                [cleanBtn setTitle:[NSString stringWithFormat:@"%luM",i/(1024*1024)] forState:UIControlStateNormal];
            });
        });        
        cell.accessoryView = cleanBtn;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:@"确认清除缓存"
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                    otherButtonTitleArray:@[@"清除"]];
        actionSheet.scrolling          = YES;
        actionSheet.buttonHeight       = 60.0f;
        actionSheet.visibleButtonCount = 3.6f;
        [actionSheet show];
    }
}

- (void)actionSheet:(LCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 2) {
        [SXLoadingView showProgressHUD:@"正在清除缓存"];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[SDImageCache sharedImageCache] cleanDisk];
            [[SDImageCache sharedImageCache] clearDisk];
            [[YYImageCache sharedCache].diskCache removeAllObjects];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SXLoadingView hideProgressHUD];
                [SXLoadingView showAlertHUD:@"清除完成" duration:0.5];
                [self.settingTableView reloadData];
            });
        });
    }
}

-(void)switchBtnHandleForWWNN:(UISwitch *)switchBtn{
    [[NSUserDefaults standardUserDefaults]setBool:switchBtn.isOn forKey:SHOULD_WLNN_UPLOAD_STR];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if([PhotoManager shareManager].netStatus == FMNetStatusWWAN ){
        if (switchBtn.isOn) {
            [PhotoManager shareManager].canUpload = YES;
        }else{
            [PhotoManager shareManager].canUpload = NO;
        }
    }
}

-(void)switchBtnHandleForSync:(UISwitch *)switchBtn{
    [[NSUserDefaults standardUserDefaults]setObject:switchBtn.isOn?DEF_UUID:NO_USER forKey:USER_SHOULD_SYNC_PHOTO_STR];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (switchBtn.isOn) {
        [PhotoManager shareManager].canUpload = YES;
    }else{
        if (IsEquallString(USER_SHOULD_SYNC_PHOTO, DEF_UUID)) {
             [PhotoManager shareManager].canUpload = NO;
        }
    }
}

- (IBAction)cleanBtnClick:(id)sender {
}

-(void)backbtnClick:(UIButton *)back{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
