//
//  FLFilesVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/8/31.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FLFilesVC.h"
#import "FLFilesCell.h"
#import "FLDataSource.h"
#import "FLSecondFilesVC.h"
#import "FLDownloadManager.h"
#import "FLFIlesHelper.h"

@interface FLFilesVC ()<UITableViewDelegate,UITableViewDataSource,FLDataSourceDelegate>
@property (weak, nonatomic) IBOutlet UITableView *fileTableView;

@property (nonatomic) FLDataSource * dataSource;

@property (nonatomic) FLFliesCellStatus cellStatus;

@property (nonatomic) FLFilesModel * chooseModel;
@end

@implementation FLFilesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self initData];
    [self createNavBtns];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerStatusChangeNotify:) name:FLFilesStatusChangeNotify object:nil];
}

-(void)handlerStatusChangeNotify:(NSNotification *)notify{
    if (![notify.object boolValue]) {
        self.cellStatus = FLFliesCellStatusNormal;
        [self.fileTableView reloadData];
    }else{
        self.cellStatus = FLFliesCellStatusCanChoose;
        [self.fileTableView reloadData];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)createNavBtns{
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"MORE"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)rightBtnClick:(UIButton *)btn{
    if (!self.cellStatus) {
        @weakify(self);
        [[LCActionSheet sheetWithTitle:@"" cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [weak_self changeStatus];
            }
        } otherButtonTitles:@"选择文件", nil] show];
    }else{
        [[LCActionSheet sheetWithTitle:@"" cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[FLFIlesHelper helper] removeAllChooseFile];
            }else if ( buttonIndex == 2){
                [[FLFIlesHelper helper] downloadChooseFiles];
                [self.rdv_tabBarController setSelectedIndex:2];
            }
        } otherButtonTitles:@"清除选择",@"下载所选项", nil] show];
    }
}


-(void)changeStatus{
    if (self.cellStatus)
        self.cellStatus = FLFliesCellStatusNormal;
    else
        self.cellStatus = FLFliesCellStatusCanChoose;
    [self.fileTableView reloadData];
}

-(void)initData
{
    _dataSource = [FLDataSource new];
    _dataSource.delegate = self;
    _cellStatus = FLFliesCellStatusNormal;
    [self.fileTableView reloadData];
}

-(void)initViews{
    [self.fileTableView registerNib:[UINib nibWithNibName:@"FLFilesCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([FLFilesCell class])];
    self.fileTableView.tableFooterView = [UIView new];
    self.fileTableView.noDataImageName = @"no_file";
}

#pragma mark - FLDataSourceDelegate

-(void)fl_Datasource:(FLDataSource *)datasource finishLoading:(BOOL)finish{
    
    if (datasource == self.dataSource && finish) {
        [self.fileTableView displayWithMsg:@"暂无文件" withRowCount:self.dataSource.dataSource.count andIsNoData:YES andTouchBlock:nil];
        [self.fileTableView reloadData];
    }
}

#pragma mark -Delegate DataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FLFilesCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FLFilesCell class])];
    FLFilesModel * model = self.dataSource.dataSource[indexPath.row];
    [[FLFIlesHelper helper] configCells:cell withModel:model cellStatus:self.cellStatus];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.dataSource.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FLFilesModel * model = self.dataSource.dataSource[indexPath.row];
    if (!model.isFile){
        FLSecondFilesVC * vc = [FLSecondFilesVC new];
        vc.parentUUID = model.uuid;
        vc.cellStatus = self.cellStatus;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        if (self.cellStatus == FLFliesCellStatusCanChoose) {
            if ([[FLFIlesHelper helper].chooseFiles containsObject:model]) {
                [[FLFIlesHelper helper] removeChooseFile:model];
            }else
                [[FLFIlesHelper helper] addChooseFile:model];
            
            [self.fileTableView reloadData];
        }
    }
}

@end
