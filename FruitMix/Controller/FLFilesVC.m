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
#import "FLChooseFilesVC.h"
#import "VCFloatingActionButton.h"
#import "JYProcessView.h"
#import "FLLocalFIleVC.h"

@interface FLFilesVC ()<UITableViewDelegate,UITableViewDataSource,FLDataSourceDelegate,LCActionSheetDelegate,floatMenuDelegate>
{
    UIButton * _leftBtn;
    UILabel * _countLb;
}
@property (weak, nonatomic) IBOutlet UITableView *fileTableView;

@property (nonatomic) FLDataSource * dataSource;

@property (nonatomic) FLFliesCellStatus cellStatus;

@property (nonatomic) FLFilesModel * chooseModel;

@property (nonatomic) UIView * chooseHeadView;

@property (strong, nonatomic) VCFloatingActionButton * addButton;

@property (strong, nonatomic) JYProcessView * progressView;

@property (nonatomic) BOOL shouldDownload;

@end

@implementation FLFilesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self initData];
    [self createNavBtns];
    [self.navigationController.view addSubview:self.chooseHeadView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerStatusChangeNotify:) name:FLFilesStatusChangeNotify object:nil];
    [self createControlbtn];
}

-(void)handlerStatusChangeNotify:(NSNotification *)notify{
    if (![notify.object boolValue]) {
        [self actionForNormalStatus];
    }else{
        if (self.cellStatus != FLFliesCellStatusCanChoose) {
           [self actionForChooseStatus];
        }
    }
}

-(void)createControlbtn{
    if(!_addButton){
        CGRect floatFrame = CGRectMake(self.view.jy_Width-103 , __kHeight - 64 - 56 - 88, 56, 56);
        _addButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"add_album"] andPressedImage:[UIImage imageNamed:@"icon_close"] withScrollview:_fileTableView];
        _addButton.automaticallyInsets = YES;
        _addButton.imageArray = @[@"download"];
        _addButton.labelArray = @[@""];
        _addButton.delegate = self;
        _addButton.hidden = YES;
        [self.view addSubview:_addButton];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)createNavBtns{
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"more_highlight"] forState:UIControlStateHighlighted];
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)leftBtnClick:(id)sender{
    for (FLFilesModel * model in self.dataSource.dataSource) {
        if (self.cellStatus == FLFliesCellStatusCanChoose) {
           [[FLFIlesHelper helper] removeChooseFile:model];
           [self.fileTableView reloadData];
        }
    }
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
    if (self.cellStatus){
        self.cellStatus = FLFliesCellStatusNormal;
         [self actionForNormalStatus];
    }
    else
    {
        self.cellStatus = FLFliesCellStatusCanChoose;
        [self actionForChooseStatus];
    }
    
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
#pragma mark - floatMenuDelegate

-(void)didSelectMenuOptionAtIndex:(NSInteger)row{
   
        if (self.cellStatus == FLFliesCellStatusCanChoose) {
            if ([FLFIlesHelper helper].chooseFiles.count == 0) {
                [SXLoadingView showAlertHUD:@"请先选择文件" duration:1];
            }else{
                  [[FLFIlesHelper helper] downloadChooseFiles];
                FLLocalFIleVC *downloadVC = [[FLLocalFIleVC alloc]init];
                 [self.navigationController pushViewController:downloadVC animated:YES];
                }
        }
}
#pragma mark - FLDataSourceDelegate

-(void)fl_Datasource:(FLDataSource *)datasource finishLoading:(BOOL)finish{
    
    if (datasource == self.dataSource && finish) {
        [self.fileTableView displayWithMsg:@"暂无文件" withRowCount:self.dataSource.dataSource.count andIsNoData:YES  andTableViewFrame:self.view.bounds
                             andTouchBlock:nil];
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
        vc.name = model.name;
        if (self.cellStatus == FLFliesCellStatusNormal) {
        [self.navigationController pushViewController:vc animated:YES];
        }
    }else{
        if (self.cellStatus == FLFliesCellStatusCanChoose) {
            if ([[FLFIlesHelper helper].chooseFiles containsObject:model]) {
                [[FLFIlesHelper helper] removeChooseFile:model];
            }else
                [[FLFIlesHelper helper] addChooseFile:model];
                [self.fileTableView reloadData];
        }else{
            if (!_progressView)
                _progressView = [JYProcessView processViewWithType:ProcessTypeLine];
            _progressView.descLb.text =@"正在下载文件";
            _progressView.subDescLb.text = [NSString stringWithFormat:@"1个项目 "];
            _progressView.cancleBlock = ^(){
                [[FLFIlesHelper helper] cancleWithDownloadModel];
            };
         
            [_progressView show];
//            TYDownloadModel * tymodel = model;
//                [[TYDownLoadDataManager manager] startWithDownloadModel:model progress:^(TYDownloadProgress *progress) {
//                    [_progressView setValueForProcess:progress.progress];
////                    cell.timeLabel.text = [self detailTextForDownloadProgress:progress];
//                } state:^(TYDownloadState state, NSString *filePath, NSError *error) {
//                    NSLog(@"%lu",(unsigned long)state);
//                }];
//            
            
            
//        [[FLFIlesHelper helper] downloadChooseFiles];
            
        }
    }
}

- (void)actionForChooseStatus{
//     if (self.cellStatus == FLFliesCellStatusNormal) {
    
    [UIView animateWithDuration:0.5 animations:^{
        _chooseHeadView.transform = CGAffineTransformTranslate(_chooseHeadView.transform, 0, 64);
    }];
     _addButton.hidden = NO;
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    self.cellStatus = FLFliesCellStatusCanChoose;
    [self.fileTableView reloadData];
//     }
}

- (void)actionForNormalStatus{
    [UIView animateWithDuration:0.5 animations:^{
        _chooseHeadView.transform = CGAffineTransformTranslate(_chooseHeadView.transform, 0, -64);
    }];
     _addButton.hidden = YES;
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    self.cellStatus = FLFliesCellStatusNormal;
    [self.fileTableView reloadData];
}

- (UIView *)chooseHeadView{
    if (!_chooseHeadView) {
        _chooseHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, -64, __kWidth, 64)];
        _chooseHeadView.backgroundColor = UICOLOR_RGB(0x03a9f4);
        UIButton * leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 16, 48, 48 )];
        UIImage * backImage = [UIImage imageNamed:@"back"];
        //        UIImage * backHighlightImage = [UIImage imageNamed:@"back_grayhighlight"];
        //        [backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 1, 1) resizingMode:UIImageResizingModeStretch];
        [leftBtn setImage:backImage forState:UIControlStateNormal];
        //        [leftBtn setImage:backHighlightImage forState:UIControlStateHighlighted];
        [leftBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _leftBtn = leftBtn;
        
        UILabel * countLb = [[UILabel alloc]initWithFrame:CGRectMake(__kWidth/2 - 50, 27, 100, 30)];
        countLb.textColor = [UIColor whiteColor];
        countLb.font = [UIFont fontWithName:Helvetica size:17];
        countLb.textAlignment = NSTextAlignmentCenter;
        _countLb = countLb;
        [_chooseHeadView addSubview:countLb];
        [_chooseHeadView addSubview:leftBtn];

        //    }
        _countLb.text = @"选择文件";
        _countLb.font = [UIFont fontWithName:FANGZHENG size:16];
    }
    return _chooseHeadView;
}
@end
