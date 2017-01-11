//
//  FLSecondFilesVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FLSecondFilesVC.h"
#import "FLDownloadManager.h"
#import "LCActionSheet.h"
#import "FLFIlesHelper.h"
#import "UIScrollView+JYEmptyView.h"

@interface FLSecondFilesVC ()<UITableViewDelegate,UITableViewDataSource,FLDataSourceDelegate,LCActionSheetDelegate>

@property (nonatomic) FLDataSource * dataSource;

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (nonatomic) FLFilesModel * chooseModel;

@end

@implementation FLSecondFilesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self initData];
    [self createNavBtns];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerStatusChangeNotify:) name:FLFilesStatusChangeNotify object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

-(void)handlerStatusChangeNotify:(NSNotification *)notify{
    if (![notify.object boolValue]) {
        self.cellStatus = FLFliesCellStatusNormal;
        [self.tableview reloadData];
    }else{
        self.cellStatus = FLFliesCellStatusCanChoose;
        [self.tableview reloadData];
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
    @weakify(self);
    if (!self.cellStatus) {
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
//                [weak_self.rt_navigationController popToRootViewControllerAnimated:NO complete:^(BOOL finished) {
                    [weak_self.rdv_tabBarController setSelectedIndex:2];
//                }];
            }
        } otherButtonTitles:@"清除选择",@"下载所选项", nil] show];
    }
}


-(void)changeStatus{
    if (self.cellStatus)
        self.cellStatus = FLFliesCellStatusNormal;
    else
        self.cellStatus = FLFliesCellStatusCanChoose;
    [self.tableview reloadData];
}


-(void)initData
{
    _dataSource = [[FLDataSource alloc]initWithFileUUID:_parentUUID];
    _dataSource.delegate = self;
    [self.tableview reloadData];
}

-(void)initViews{
    [self.tableview registerNib:[UINib nibWithNibName:@"FLFilesCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([FLFilesCell class])];
    self.tableview.tableFooterView = [UIView new];
    self.tableview.noDataImageName = @"no_file";
}

#pragma mark - FLDataSourceDelegate

-(void)fl_Datasource:(FLDataSource *)datasource finishLoading:(BOOL)finish{
    if (datasource == self.dataSource && finish) {
        [self.tableview displayWithMsg:@"暂无文件" withRowCount:self.dataSource.dataSource.count andIsNoData:YES andTouchBlock:nil];
        [self.tableview reloadData];
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
            if ([[FLFIlesHelper helper] containsFile:model]) {
                [[FLFIlesHelper helper] removeChooseFile:model];
            }else
                [[FLFIlesHelper helper] addChooseFile:model];
            
            [self.tableview reloadData];
        }
    }
}

@end
