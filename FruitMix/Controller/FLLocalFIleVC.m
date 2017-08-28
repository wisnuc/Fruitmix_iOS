//
//  FLLocalFIleVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/2.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FLLocalFIleVC.h"
#import "TYDownLoadDataManager.h"
#import "TYDownLoadUtility.h"
#import "TYDownloadDelegate.h"
#import "FLDownloadManager.h"
#import "FLFilesCell.h"
#import "LCActionSheet.h"

@interface FLLocalFIleVC ()<UITableViewDelegate,UITableViewDataSource,UIDocumentInteractionControllerDelegate>
@property (weak, nonatomic) IBOutlet FMTableView *tableview;

@property (nonatomic) NSMutableArray * needDownloads;//正在下载
@property (nonatomic) NSMutableArray * downloadeds;//已下载

@property (nonatomic, strong) UIDocumentInteractionController *documentController;

@property (nonatomic) FLFliesCellStatus cellStatus;

@property (nonatomic) NSMutableArray * chooseArr;

@end

@implementation FLLocalFIleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self configTableView];
    [self createNavBtns];
    self.title = @"文件下载";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(freshData:) name:@"deleteCompleteNoti" object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self initData];

}

- (void)freshData:(NSNotification *)noti{
    dispatch_async(dispatch_get_main_queue(), ^{
          [self initData];
    });
}
-(void)initData{
    _downloadeds = [NSMutableArray arrayWithArray:[FMDBControl getAllDownloadFiles]];
    _needDownloads = [NSMutableArray arrayWithCapacity:0];
    [_needDownloads addObjectsFromArray:[TYDownLoadDataManager manager].downloadingModels];
    [_needDownloads addObjectsFromArray:[TYDownLoadDataManager manager].waitingDownloadModels];
    [self.tableview reloadData];
//    [self.tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_downloadeds count] - 2 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//    [self.tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_downloadeds count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)createNavBtns{
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"more_highlight"] forState:UIControlStateHighlighted];
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)rightBtnClick:(UIButton *)btn{
     @weaky(self);
    if (!self.cellStatus) {
        [[LCActionSheet sheetWithTitle:@"" cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [weak_self changeStatus];
            }
        } otherButtonTitles:@"选择", nil] show];
    }else{
        [[LCActionSheet sheetWithTitle:@"" cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [weak_self changeStatus];
            }else if ( buttonIndex == 2){
                [weak_self deleteChooseFiles];
            }
        } otherButtonTitles:@"清除选择",@"删除", nil] show];
    }
}


-(void)deleteChooseFiles{
    for (TYDownloadModel * model in self.needDownloads) {
        if ([self.chooseArr containsObject:model.fileName]) {
            [[TYDownLoadDataManager manager] cancleWithDownloadModel:model];
            [self.chooseArr removeObject:model.fileName];
        }
    }
    
    NSMutableArray * arrayTemp = self.downloadeds;
    
    NSArray * array = [NSArray arrayWithArray: arrayTemp];
    
    for (FLDownload * down in array) {
        if ([self.chooseArr containsObject:down.uuid]) {
            [FMDBControl updateDownloadWithFile:down isAdd:NO];
        }
    }
    [self changeStatus];
    
}

-(NSMutableArray *)chooseArr{
    if (!_chooseArr) {
        _chooseArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _chooseArr;
}

-(void)configTableView{
    //注册cell
//    [_tableview registerNib:[UINib nibWithNibName:@"FLFilesCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([FLFilesCell class])];
    self.cellStatus = FLFliesCellStatusNormal;
//    _tableview.contentInset = UIEdgeInsetsMake(FMDefaultOffset, 0, 0, 0);
//      _tableview.separatorInset = UIEdgeInsetsMake(FMDefaultOffset, 0, 0, 0);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFileChangeHandle:) name:FLDownloadFileChangeNotify object:nil];
}

-(void)changeStatus{
    if (_cellStatus == FLFliesCellStatusCanChoose) {
        [self.chooseArr removeAllObjects];
    }
    _cellStatus = !_cellStatus;
    [self.tableview reloadData];
}



-(void)downloadFileChangeHandle:(NSNotification *)notify{
    [self initData];
    [self.tableview reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.needDownloads.count;
    }else
        return self.downloadeds.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"正在下载";
    }
    else
        return @"已下载";
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FLFilesCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FLFilesCell class])];
    if (nil == cell) {
        cell= [[[NSBundle mainBundle] loadNibNamed:@"FLFilesCell" owner:nil options:nil] lastObject];
    }
       cell.downBtn.hidden = YES;
    [self configCell:cell andIndexpath:indexPath];
    return cell;

}

-(void)configCell:(FLFilesCell *)cell andIndexpath:(NSIndexPath *)indexPath{
    cell.f_ImageView.image = [UIImage imageNamed:@"file_icon"];
    TYDownloadModel * model;
    NSString * uuid;
    if (indexPath.section == 0) {
        cell.downBtn.hidden = NO;
        model = self.needDownloads[indexPath.row];
        uuid = model.fileName;
        if (model.state != TYDownloadStateRunning){
            cell.timeLabel.text = @"等待下载";
        }
        [[TYDownLoadDataManager manager] startWithDownloadModel:model progress:^(TYDownloadProgress *progress) {
            cell.timeLabel.text = [self detailTextForDownloadProgress:progress];
        } state:^(TYDownloadState state, NSString *filePath, NSError *error) {

        }];
        cell.nameLabel.text = model.jy_fileName;
        cell.clickBlock = ^(FLFilesCell * cell){
            LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:nil
                                                                     delegate:nil
                                                            cancelButtonTitle:@"取消"
                                                        otherButtonTitleArray:@[@"取消下载"]];
            actionSheet.clickedHandle = ^(LCActionSheet *actionSheet, NSInteger buttonIndex){
                if (buttonIndex == 1) {
                    TYDownloadModel *downloadModel = [self.needDownloads objectAtIndex:indexPath.row];
                    if ([downloadModel.fileName isEqualToString:model.fileName]) {
                        [actionSheet setHidden:YES];
                        return ;
                    }
                    [[FLDownloadManager shareManager] cancleWithDownloadModel:model];
                   [self.needDownloads removeObjectAtIndex:[indexPath row]];
                    [_tableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [_tableview reloadData];
                    
                }
            };
            actionSheet.scrolling          = YES;
            actionSheet.buttonHeight       = 60.0f;
            actionSheet.visibleButtonCount = 3.6f;
            [actionSheet show];
        };

    }else{
        model = self.downloadeds[indexPath.row];
        uuid = ((FLDownload *)model).uuid;
        cell.nameLabel.text = ((FLDownload *)model).name;
        cell.timeLabel.text = [NSString stringWithFormat:@"下载于:%@",((FLDownload *)model).downloadtime];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([self.chooseArr containsObject:uuid]) {
        cell.f_ImageView.hidden = YES;
        cell.layerView.image = [UIImage imageNamed:@"check_circle_select"];
    }else{
        cell.f_ImageView.hidden = NO;
        cell.layerView.image = [UIImage imageNamed:@"check_circle"];
    }
    @weaky(self);
    cell.longpressBlock =^(FLFilesCell * cell){
        if (_cellStatus == FLFliesCellStatusNormal) {
            NSString * uuid = [model isKindOfClass:[TYDownloadModel class]]?
            ((TYDownloadModel *)model).fileName:((FLDownload*)model).uuid;
            [weak_self.chooseArr addObject:uuid];
            [weak_self changeStatus];
        }
    };
    cell.status = _cellStatus;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.cellStatus == FLFliesCellStatusCanChoose){
        id model = indexPath.section == 0?
            self.needDownloads[indexPath.row]:self.downloadeds[indexPath.row];
        NSString * uuid = [model isKindOfClass:[TYDownloadModel class]]?
                                ((TYDownloadModel *)model).fileName:((FLDownload*)model).uuid;
        
        if([self.chooseArr containsObject:uuid]){
            [self.chooseArr removeObject:uuid];
        }
        else
        {
            [self .chooseArr addObject:uuid];
        }
        [self.tableview reloadData];
    }else{
        if (indexPath.section == 1) {
            FLDownload * model = self.downloadeds[indexPath.row];
            _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",File_DownLoad_DIR,model.name]]];
            _documentController.delegate = self;
            [self presentOptionsMenu];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)updateDataCompletedWithModel:(TYDownloadModel *)model Cell:(FLFilesCell *)cell andIndexpath:(NSIndexPath *)indexPath{
}


- (void)presentOptionsMenu
{
    BOOL canOpen = [self.documentController presentPreviewAnimated:YES];
    if (!canOpen) {
        [MyAppDelegate.notification displayNotificationWithMessage:@"文件预览失败" forDuration:1];
        [_documentController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
    }
    // display third-party apps as well as actions, such as Copy, Print, Save Image, Quick Look
//    [_documentController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
}



#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
}



- (NSString *)detailTextForDownloadProgress:(TYDownloadProgress *)progress
{
    NSString *fileSizeInUnits = [NSString stringWithFormat:@"%.2f %@",
                                 [TYDownloadUtility calculateFileSizeInUnit:(unsigned long long)progress.totalBytesExpectedToWrite],
                                 [TYDownloadUtility calculateUnit:(unsigned long long)progress.totalBytesExpectedToWrite]];
    
//    NSMutableString *detailLabelText = [NSMutableString stringWithFormat:@"FileSize:%@ Downloaded:%.2f %@ (%.2f%%) Speed: %.2f %@/sec LeftTime: %dsec",fileSizeInUnits,
//                                        [TYDownloadUtility calculateFileSizeInUnit:(unsigned long long)progress.totalBytesWritten],
//                                        [TYDownloadUtility calculateUnit:(unsigned long long)progress.totalBytesWritten],progress.progress*100,
//                                        [TYDownloadUtility calculateFileSizeInUnit:(unsigned long long) progress.speed],
//                                        [TYDownloadUtility calculateUnit:(unsigned long long)progress.speed]
//                                        ,progress.remainingTime];
    NSMutableString *detailLabelText = [NSMutableString stringWithFormat:@"总大小:%@ 已下载:%.2f %@ (%.2f%%)",fileSizeInUnits,
                                        [TYDownloadUtility calculateFileSizeInUnit:(unsigned long long)progress.totalBytesWritten],
                                        [TYDownloadUtility calculateUnit:(unsigned long long)progress.totalBytesWritten],progress.progress*100
                                        ];
    return detailLabelText;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"deleteCompleteNoti" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:FLDownloadFileChangeNotify object:nil];
}
#pragma mark - DownloadDelegate

@end
