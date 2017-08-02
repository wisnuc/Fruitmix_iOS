//
//  FLShareVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/2.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FLShareVC.h"
#import "FLShareDataSource.h"
#import "FLSharesCell.h"
#import "FLShareModel.h"
#import "FLSecondFilesVC.h"
#import "LCActionSheet.h"
#import "FLDownloadManager.h"

@interface FLShareVC ()<UITableViewDelegate,UITableViewDataSource,FLShareDataSourceDelegate>

@property (nonatomic) FLShareDataSource * dataSource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) FLShareModel * chooseModel;

@end

@implementation FLShareVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [FLShareDataSource new];
    self.dataSource.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"FLSharesCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([FLSharesCell class])];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.noDataImageName = @"no_file";
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FLSharesCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FLSharesCell class])];
    FLShareModel * model = [self.dataSource.dataSource objectAtIndex:indexPath.row];
    NSString * username;
    if (model.owner.count)
        username = [FMConfigInstance getUserNameWithUUID:model.owner[0]];
    else
        username = @"未知用户";
    NSString * name = model.name;
    if ([name hasPrefix:@"/"])
        name = [NSString stringWithFormat:@"%@的根目录分享",username];
    cell.fl_shareNameLb.text = name;
    cell.fl_userLb.text = username;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     FLShareModel * model = [self.dataSource.dataSource objectAtIndex:indexPath.row];
    if (!model.isFile){
        FLSecondFilesVC * vc = [FLSecondFilesVC new];
        vc.parentUUID = model.uuid;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        _chooseModel = model;
        LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:@"请选择"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"cancle"
                                                    otherButtonTitleArray:@[@"下载该文件",@"分享给好友"]];
        actionSheet.scrolling          = YES;
        actionSheet.buttonHeight       = 60.0f;
        actionSheet.visibleButtonCount = 3.6f;
        [actionSheet show];
    }
}
-(void)shareDataSourceLoadingComplete:(BOOL)complete{
    [self.tableView displayWithMsg:@"暂无分享文件" withRowCount:self.dataSource.dataSource.count andIsNoData:YES
andTableViewFrame:self.view.bounds andTouchBlock:nil];
    if (complete) {
        [self.tableView reloadData];
    }else
        [MyAppDelegate.notification displayNotificationWithMessage:@"加载失败" forDuration:1];
}

- (void)actionSheet:(LCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        FLFilesModel * model = [FLFilesModel new];
        model.name = _chooseModel.name;
        model.uuid = _chooseModel.uuid;
        [[FLDownloadManager shareManager] downloadFileWithFileModel:model];
        [MyAppDelegate.notification displayNotificationWithMessage:[NSString stringWithFormat:@"%@已添加到下载列表",_chooseModel.name] forDuration:1];
    }
}
@end
