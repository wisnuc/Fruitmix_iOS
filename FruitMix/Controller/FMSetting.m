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

@property (nonatomic) BOOL displayProgress;

@property (nonatomic,strong)UISwitch * switchBtn;

@property (nonatomic,assign)BOOL switchOn;
@property (nonatomic,assign)NSInteger tag;
@end

@implementation FMSetting


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    self.view.backgroundColor = [UIColor whiteColor];
   //    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.settingTableView.tableFooterView = [UIView new];
    self.displayProgress = NO;
    [self createNavbtn];
    [self anySwitch];
 
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    self.displayProgress = NO;
//    if (_tag == 1) {
        [self setSwitch];
//    }else{
//           _switchOn = IsEquallString(DEF_UUID, USER_SHOULD_SYNC_PHOTO);
//    }

    [self.settingTableView reloadData];
//    self.navDelegate =  self.navigationController.interactivePopGestureRecognizer.delegate;
//    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
//    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] andSEL:@selector(backbtnClick:)];

}

- (void)setSwitch{
    _switchOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"swithOn"];
//     [self.settingTableView reloadData];
}

-(void)anySwitch{
    if (_switchOn) {
        [PhotoManager shareManager].canUpload = YES;
    }else{
        
        [PhotoManager shareManager].canUpload = NO;

    }
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    self.navigationController.interactivePopGestureRecognizer.delegate = self.navDelegate;
}

- (void)setNotifacation{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(swichActionForNot) name:@"dontBackUp" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(swichAction) name:@"backUp" object:nil];
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

- (instancetype)initPrivate {
    self  = [super init];
    [self setNotifacation];
//    _switchOn = NO;
 
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"123"];
    if (indexPath.row == 0) {
        UILabel * titleLb = [[UILabel alloc] initWithFrame:CGRectMake(16, 23, 200, 17)];
        titleLb.text = @"照片自动备份:";
        titleLb.font = [UIFont systemFontOfSize:17];
        
        [cell.contentView addSubview:titleLb];
        cell.contentView.layer.masksToBounds = YES;
        UISwitch *switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(__kWidth - 70, 16, 50, 40)];
        switchBtn.on = _switchOn;
        [switchBtn addTarget:self  action:@selector(switchBtnHandleForSync:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:switchBtn];
     
//        if(switchBtn.isOn){
//            UILabel * lb = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, __kWidth, 12)];
//            lb.font = [UIFont systemFontOfSize:12];
//            lb.textAlignment = NSTextAlignmentCenter;
//            lb.text = _displayProgress?@"点击收回备份详情": @"点击查看备份详情";
//            [cell.contentView addSubview:lb];
//            
//            UILabel * progressLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, __kWidth, 15)];
//            progressLb.font = [UIFont systemFontOfSize:12];
//            progressLb.textAlignment = NSTextAlignmentCenter;
//            [FMDBControl getDBAllLocalPhotosWithCompleteBlock:^(NSArray<FMLocalPhoto *> *result) {
//                NSMutableArray * tmp = [NSMutableArray arrayWithCapacity:0];
//                for (FMLocalPhoto * p in result) {
//                    [tmp addObject:p.localIdentifier];
//                }
//                NSInteger allPhotos = result.count;
//                FMDBSet * dbSet = [FMDBSet shared];
//                FMDTSelectCommand * scmd  = FMDT_SELECT(dbSet.syncLogs);
//                [scmd where:@"userId" equalTo:DEF_UUID];
//                [scmd where:@"localId" containedIn:tmp];
//                [scmd fetchArrayInBackground:^(NSArray *results) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        progressLb.text = [NSString stringWithFormat:@"本地照片总数: %ld张    已上传张数: %ld张",(long)allPhotos,results.count];
//                    });
//                }];
//            }];
//            
//            [cell.contentView addSubview:progressLb];
//            progressLb.hidden = !_displayProgress;
//        }
    }
    if (indexPath.row == 1) {
        UILabel * titleLb = [[UILabel alloc] initWithFrame:CGRectMake(16, 23, 200, 17)];
        titleLb.text = @"手机网络上传:";
        titleLb.font = [UIFont systemFontOfSize:17];
        [cell.contentView addSubview:titleLb];
        
        UISwitch *switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(__kWidth - 70, 16, 50, 40)];
        switchBtn.on = SHOULD_WLNN_UPLOAD;
        [switchBtn addTarget:self  action:@selector(switchBtnHandleForWWNN:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:switchBtn];
    }else if(indexPath.row == 2){
        UILabel * titleLb = [[UILabel alloc] initWithFrame:CGRectMake(16, 23, 200, 17)];
        titleLb.text = @"清除缓存";
        titleLb.font = [UIFont systemFontOfSize:17];
        [cell.contentView addSubview:titleLb];
        
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
    if(indexPath.row == 0){
        _displayProgress = !_displayProgress;
        [self.settingTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (indexPath.row == 2) {
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(IsEquallString(DEF_UUID, USER_SHOULD_SYNC_PHOTO) && indexPath.row == 0 && _displayProgress)
        return 100;
    return 64;
        
}


- (void)actionSheet:(LCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
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
    
//    NSString *name= [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_SHOULD_SYNC_PHOTO_STR"];
//    NSLog(@"%@",name);
    if (switchBtn.isOn) {
        [PhotoManager shareManager].canUpload = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"swithOn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _switchOn = YES;
    }else{
//        NSLog(@"%@",USER_SHOULD_SYNC_PHOTO);
//        if (IsEquallString(USER_SHOULD_SYNC_PHOTO, DEF_UUID)) {
             [PhotoManager shareManager].canUpload = NO;
         _switchOn = NO;
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"swithOn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
//        }
    }
//    [self.settingTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:100];
}

- (void)swichActionForNot{
//    dispatch_sync(dispatch_get_main_queue(), ^{
//     [_switchBtn setOn:NO];
//    });
       _tag = 1;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"swithOn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)swichAction{
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        [_switchBtn setOn:YES];
//    });
       _tag = 1;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"swithOn"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (IBAction)cleanBtnClick:(id)sender {
   
}

-(void)backbtnClick:(UIButton *)back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"dontBackUp" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"backUp" object:nil];
}

@end
