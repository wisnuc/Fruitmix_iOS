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
#import "VCFloatingActionButton.h"
#import "JYProcessView.h"
#import "FLLocalFIleVC.h"

@interface FMScecondFilesDownloadViewHelper : NSObject

+(instancetype)defaultHelper;

@property (nonatomic ,copy) void (^downloadCompleteBlock)(BOOL success,NSString *filePath);

@end

@implementation FMScecondFilesDownloadViewHelper

+(instancetype)defaultHelper{
    static FMScecondFilesDownloadViewHelper * helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [FMScecondFilesDownloadViewHelper new];
    });
    return helper;
}

@end

NSInteger filesNameSortSecond(id file1, id file2, void *context)
{
    FLFilesModel *f1,*f2;
    f1 = (FLFilesModel *)file1;
    f1 = (FLFilesModel *)file2;
    return  [f1.name localizedCompare:f2.name];
}

@interface FLSecondFilesVC  ()<UITableViewDelegate,UITableViewDataSource,FLDataSourceDelegate,LCActionSheetDelegate,floatMenuDelegate,UIDocumentInteractionControllerDelegate,TYDownloadDelegate,FilesHelperOpenFilesDelegate>
{
    UIButton * _leftBtn;
    UILabel * _countLb;

}

@property (nonatomic) FLDataSource * dataSource;

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (nonatomic) FLFilesModel * chooseModel;

@property (nonatomic) UIView * chooseHeadView;

@property (strong, nonatomic) VCFloatingActionButton * addButton;

@property (strong, nonatomic) JYProcessView * progressView;

@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@property (nonatomic, strong) JYProcessView * pv;

@property (nonatomic) BOOL shouldDownload;

@property (nonatomic, assign) BOOL isSelect;

@end

@implementation FLSecondFilesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    [self initData];
    [self createNavBtns];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerStatusChangeNotify:) name:FLFilesStatusChangeNotify object:nil];
    self.title = self.name;
    [self createControlbtn];
    [self.navigationController.view addSubview:self.chooseHeadView];
    [self initMjRefresh];
     [TYDownLoadDataManager manager].delegate = self;
    [FLFIlesHelper helper].openFilesdelegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    for (FLFilesModel * model in self.dataSource.dataSource) {
        if (self.cellStatus == FLFliesCellStatusCanChoose) {
            [[FLFIlesHelper helper] removeChooseFile:model];
        }
    }
}

- (void)initMjRefresh{
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    self.tableview.mj_header.ignoredScrollViewContentInsetTop = 8;
    // 马上进入刷新状态
//    [self.tableview.mj_header beginRefreshing];
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

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)createControlbtn{
    if(!_addButton){
        CGRect floatFrame = CGRectMake(JYSCREEN_WIDTH-80 , __kHeight - 64 - 56 - 88, 56, 56);
//        NSLog(@"%f",self.view.jy_Width);
        _addButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"add_album"] andPressedImage:[UIImage imageNamed:@"icon_close"] withScrollview:_tableview];
        _addButton.automaticallyInsets = YES;
        _addButton.imageArray = @[@"download"];
        _addButton.labelArray = @[@""];
        _addButton.delegate = self;
        _addButton.hidden = YES;
        [self.view addSubview:_addButton];
    }
}

-(void)createNavBtns{
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"more_highlight"] forState:UIControlStateHighlighted];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,rightItem,nil];
}

- (void)loadNewData{
   [self.dataSource.dataSource removeAllObjects];
   [_dataSource getFilesWithUUID:_parentUUID];
    NSLog(@"%lu",(unsigned long)_dataSource.dataSource.count);
    _cellStatus = FLFliesCellStatusNormal;
    [self.tableview reloadData];
//    self.tableview.mj_header.hidden = YES;
}

- (void)leftBtnClick:(id)sender{
    for (FLFilesModel * model in self.dataSource.dataSource) {
        if (self.cellStatus == FLFliesCellStatusCanChoose) {
            [[FLFIlesHelper helper] removeChooseFile:model];
            [self.tableview reloadData];
        }
    }
}

-(void)rightBtnClick:(UIButton *)btn{
    @weaky(self);
//    if (self.cellStatus != FLFliesCellStatusCanChoose) {
//        [self actionForChooseStatus];
//    }
    if (!self.cellStatus) {
        [[LCActionSheet sheetWithTitle:@"" cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [weak_self actionForChooseStatus];
            }
        } otherButtonTitles:@"选择文件", nil] show];
    }else{
        [[LCActionSheet sheetWithTitle:@"" cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[FLFIlesHelper helper] removeAllChooseFile];
            }else if ( buttonIndex == 2){
                [[FLFIlesHelper helper] downloadChooseFilesParentUUID:_parentUUID];
//                [weak_self.rt_navigationController popToRootViewControllerAnimated:NO complete:^(BOOL finished) {
                    [weak_self.rdv_tabBarController setSelectedIndex:2];
//                }];
            }
        } otherButtonTitles:@"清除选择",@"下载所选项", nil] show];
    }
}


- (void)changeStatus{
    if (self.cellStatus){
        self.cellStatus = FLFliesCellStatusNormal;
        [self actionForNormalStatus];
    }
    else
    {
        self.cellStatus = FLFliesCellStatusCanChoose;
        [self actionForChooseStatus];
    }
    
    [self.tableview reloadData];
}

- (void)actionForChooseStatus{
    if (self.cellStatus == FLFliesCellStatusCanChoose) {
             return;
    }
    if (self.dataSource.dataSource.count == 0) {
        [SXLoadingView showAlertHUD:@"您所在的文件夹没有文件可以选择" duration:2];
        return;
    }

     [self.tableview.mj_header setHidden:YES];
    [UIView animateWithDuration:0.5 animations:^{
        _chooseHeadView.transform = CGAffineTransformTranslate(_chooseHeadView.transform, 0, 64);
    }];
    _addButton.hidden = NO;
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    self.cellStatus = FLFliesCellStatusCanChoose;
    _countLb.text = [NSString stringWithFormat:@"已选%ld个文件",(unsigned long)[FLFIlesHelper helper].chooseFiles.count];
    [self.tableview reloadData];
    //     }
}

- (void)actionForNormalStatus{
    if (self.cellStatus == FLFliesCellStatusNormal){
        return;
    }
    [self.tableview.mj_header setHidden:NO];
    [UIView animateWithDuration:0.5 animations:^{
        _chooseHeadView.transform = CGAffineTransformTranslate(_chooseHeadView.transform, 0, -64);
    }];
    _addButton.hidden = YES;
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    self.cellStatus = FLFliesCellStatusNormal;
     _countLb.text = [NSString stringWithFormat:@"已选1个文件"];
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
    self.tableview.contentInset = UIEdgeInsetsMake(FMDefaultOffset, 0, 0, 0);
}

- (void)sequenceDataSource{

//    NSMutableArray *needSortArray = [NSMutableArray arrayWithArray:self.dataSource.dataSource];
//    NSMutableArray *classifiedArray = [[NSMutableArray alloc] init];
//    for(int i='A';i<='Z';i++){
//        NSMutableArray *rulesArray = [[NSMutableArray alloc] init];
//        NSString *indexString = [NSString stringWithFormat:@"%c",i];
//        for(int j = 0; j < needSortArray.count; j++){
//            FLFilesModel * model = [needSortArray objectAtIndex:j];
//            
//            if([[self toPinyin: model.name] isEqualToString:indexString]){
//                //把model.name首字母相同的放到同一个数组里面
//                [rulesArray addObject:model];
//                [needSortArray removeObject:model];
//                j--;
//            }
//        }
//        if (rulesArray.count !=0) {
//            [classifiedArray addObject:rulesArray];
//        }
//        
//        if (needSortArray.count == 0) {
//            break;
//        }
//    }
//    
//    // 剩下的就是非字母开头数据，加在classifiedArray的后面
//    if (needSortArray.count !=0) {
//        [classifiedArray addObject:needSortArray];
//    }
//    
//    //最后再分别对每个数组排序
//    NSMutableArray *sortCompleteArray = [NSMutableArray array];
//    for (NSArray *tempArray in classifiedArray) {
//        NSArray *sortedElement = [tempArray sortedArrayUsingFunction:filesNameSortSecond context:NULL];
//        [sortCompleteArray addObject:sortedElement];
//    }
//    
//    [self.dataSource.dataSource removeAllObjects];
//    NSMutableArray *isFilesArr = [NSMutableArray arrayWithCapacity:0];
//    //sortCompleteArray就是最后排好序的二维数组了
//    for ( NSMutableArray * arr in sortCompleteArray) {
//        // NSLog(@"🍄🍄🍄🍄🍄🍄🍄🍄🍄🍄🍄🍄🍄🍄🍄🍄%@",arr);
//        for ( FLFilesModel * model  in arr) {
////            NSLog(@"🍄🍄🍄🍄🍄🍄🍄🍄🍄🍄🍄🍄🍄🍄🍄🍄%@",model);
//            if (!model.isFile) {
//                [self.dataSource.dataSource addObject:model];
//            }
//            else{
//                [isFilesArr addObject:model];
//            }
//        }
//    }

//    for ( FLFilesModel * model in isFilesArr) {
//        [self.dataSource.dataSource addObjectsFromArray:isFilesArr];
//    }
   
    NSMutableArray *isFilesArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *isNotFilesArr = [NSMutableArray arrayWithCapacity:0];
    for ( FLFilesModel * model  in self.dataSource.dataSource) {
        if (![model.type isEqualToString:@"file"]) {
            [isNotFilesArr addObject: model];
        }
        else{
            [isFilesArr addObject: model];
        }
    }
    [self.dataSource.dataSource removeAllObjects];
    [self.dataSource.dataSource addObjectsFromArray:isNotFilesArr];
    [self.dataSource.dataSource addObjectsFromArray:isFilesArr];
}

- (NSString *)toPinyin:(NSString *)str{
    NSMutableString *ms = [[NSMutableString alloc]initWithString:str];
    if (CFStringTransform((__bridge CFMutableStringRef)ms, 0,kCFStringTransformMandarinLatin, NO)) {
    }
    // 去除拼音的音调
    if (CFStringTransform((__bridge CFMutableStringRef)ms, 0,kCFStringTransformStripDiacritics, NO)) {
        if (str.length) {
            NSString *bigStr = [ms uppercaseString];
            NSString *cha = [bigStr substringToIndex:1];
            return cha;
        }
    }
    return str;
}


- (void)shareFiles{
#warning stand by
    //    [[FLFIlesHelper helper] downloadChooseFilesParentUUID:_parentUUID];
    //准备照片
    @weaky(self);
    [self clickDownloadWithShare:YES andCompleteBlock:^(NSArray *files) {
        //            UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:files applicationActivities:nil];
        //            //初始化回调方法
        //            UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(NSString *activityType,BOOL completed,NSArray *returnedItems,NSError *activityError)
        //            {
        //                NSLog(@"activityType :%@", activityType);
        //                if (completed)
        //                {
        //                    NSLog(@"share completed");
        //                }
        //                else
        //                {
        //                    NSLog(@"share cancel");
        //                }
        //
        //            };
        //
        //            // 初始化completionHandler，当post结束之后（无论是done还是cancell）该blog都会被调用
        //            activityVC.completionWithItemsHandler = myBlock;
        //
        //            //关闭系统的一些activity类型 UIActivityTypeAirDrop 屏蔽aridrop
        //            activityVC.excludedActivityTypes = @[];
        //
        //            [weak_self presentViewController:activityVC animated:YES completion:nil];
        for (NSString *filePath in files) {
            _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
            
            //设置代理
            _documentController.delegate = self;
            
            BOOL canOpen = [_documentController presentOpenInMenuFromRect:CGRectZero
                                                                   inView:self.view
                                                                 animated:YES];
            
            if (!canOpen) {
                NSLog(@"沒有程序可以打開要分享的文件");
            }
            
        }
        
        
    }];
    
}

-(void)clickDownloadWithShare:(BOOL)share andCompleteBlock:(void(^)(NSArray * files))block{
    NSArray * chooseItems = [[FLFIlesHelper helper].chooseFiles copy];
    if (!_pv)
        _pv = [JYProcessView processViewWithType:ProcessTypeLine];
    _pv.descLb.text = share?@"正在准备文件":@"正在下载文件";
    _pv.subDescLb.text = [NSString stringWithFormat:@"%lu个项目 ",(unsigned long)chooseItems.count];
    [_pv show];
    _shouldDownload = YES;
    _pv.cancleBlock = ^(){
        _shouldDownload = NO;
    };
    [self downloadItems:chooseItems withShare:share andCompleteBlock:block];
    [self leftBtnClick:_leftBtn];
}

-(void)downloadItems:(NSArray *)items withShare:(BOOL)isShare andCompleteBlock:(void(^)(NSArray * files))block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            __block float complete = 0.f;
            __block int successCount = 0;
            __block int finish = 0;
            FMScecondFilesDownloadViewHelper  * helper = [FMScecondFilesDownloadViewHelper defaultHelper];
            __weak typeof(helper) weakHelper = helper;
            __block NSUInteger allCount = items.count;
            @weaky(self);
            NSMutableArray * tempDownArr = [NSMutableArray arrayWithCapacity:0];
            helper.downloadCompleteBlock = ^(BOOL success ,NSString *filePath){
                complete ++;finish ++;
                if (successCount) successCount++;
                CGFloat progress =  complete/allCount;
                if (filePath && isShare) [tempDownArr addObject:filePath];
                [weak_self.pv setValueForProcess:progress];
                if (items.count > complete) {
                    [weak_self downloadWithModel:items[finish] withShare:isShare withCompleteBlock:weakHelper.downloadCompleteBlock];
                }else{
                    _shouldDownload = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weak_self.pv dismiss];
                        if (!isShare)
                            [MyAppDelegate.notification displayNotificationWithMessage:@"下载完成" forDuration:0.5f];
                        if (block) block([tempDownArr copy]);
                    });
                }
            };
            
            [self downloadWithModel:items[0] withShare:isShare withCompleteBlock:weakHelper.downloadCompleteBlock];
        }
    });
}

-(void)downloadWithModel:(FLFilesModel *)model withShare:(BOOL)share withCompleteBlock:(void(^)(BOOL isSuccess,  NSString *filePath))block{
    if (model) {
        [[FLFIlesHelper helper]downloadAloneFilesWithModel:model parentUUID:DRIVE_UUID Progress:^(TYDownloadProgress *progress) {
        } State:^(TYDownloadState state, NSString *filePath, NSError *error) {
            if (state == TYDownloadStateCompleted && filePath.length >0) {
                if (share) {
                    block(YES,filePath);
                }else{
                    block(NO,filePath);
                }
            }
        }];
        
    }
    
}

#pragma mark - FLDataSourceDelegate

-(void)fl_Datasource:(FLDataSource *)datasource finishLoading:(BOOL)finish{
 
    if (datasource == self.dataSource && finish) {
        [self sequenceDataSource];
        [self.tableview reloadData];
        [self.tableview.mj_header endRefreshing];
        [self.tableview displayWithMsg:@"暂无文件" withRowCount:self.dataSource.dataSource.count andIsNoData:YES andTableViewFrame:self.view.bounds andTouchBlock:nil];
    }
}


#pragma mark -Delegate DataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FLFilesCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (nil == cell) {
        cell= (FLFilesCell *)[[[NSBundle  mainBundle]  loadNibNamed:@"FLFilesCell" owner:self options:nil]  lastObject];
    }
    FLFilesModel * model = self.dataSource.dataSource[indexPath.row];
    [[FLFIlesHelper helper] configCells:cell withModel:model cellStatus:self.cellStatus viewController:self parentUUID:_parentUUID];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.dataSource.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isSelect == false) {
        self.isSelect = true;
        [self performSelector:@selector(repeatDelay) withObject:nil afterDelay:0.5f];
    FLFilesModel * model = self.dataSource.dataSource[indexPath.row];
    if (![model.type isEqualToString:@"file"]){
        FLSecondFilesVC * vc = [FLSecondFilesVC new];
        vc.parentUUID = model.uuid;
        vc.cellStatus = self.cellStatus;
        vc.name = model.name;
        if (self.cellStatus == FLFliesCellStatusNormal) {
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else{
        if (self.cellStatus == FLFliesCellStatusCanChoose) {
            if ([[FLFIlesHelper helper] containsFile:model]) {
                [[FLFIlesHelper helper] removeChooseFile:model];
            }else
                [[FLFIlesHelper helper] addChooseFile:model];
            _countLb.text = [NSString stringWithFormat:@"已选%ld个文件",(unsigned long)[FLFIlesHelper helper].chooseFiles.count];
            [self.tableview reloadData];
        }else{
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"JYDownloadCache/%@",model.name]];
            
//            for (TYDownloadModel * downloadModelIn in [TYDownLoadDataManager manager].waitingDownloadModels) {
//                if ([downloadModelIn.fileName isEqualToString:model.name]) {
//                    [SXLoadingView showProgressHUDText:@"该文件正在下载"duration:1];
//                    return;
//                }
//            }
//            for (TYDownloadModel * downloadModelIn in [TYDownLoadDataManager manager].waitingDownloadModels) {
//                if ([downloadModelIn.fileName isEqualToString:model.name]) {
//                   [SXLoadingView showProgressHUDText:@"该文件正在等待下载"duration:1];
//                    return;
//                }
//            }
//            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] &&[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil].fileSize != model.size){
//                [SXLoadingView showProgressHUDText:@"该文件正在下载"duration:1];
//                return;
//            }
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]&&[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil].fileSize == model.size) {
                _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
                _documentController.delegate = self;
                [self presentOptionsMenu];
            }
            else{
                //                UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否下载该文件" preferredStyle:UIAlertControllerStyleAlert];
                //                UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                //
                //                }];
                //
                //                UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                if ([TYDownLoadDataManager manager].downloadingModels.count>0) {
                    __block BOOL isExist = NO;
                    [[TYDownLoadDataManager manager].downloadingModels enumerateObjectsUsingBlock:^(TYDownloadModel * downloadModelIn, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([downloadModelIn.fileName isEqualToString:model.name]) {
                            isExist = YES;
                        }
                    }];
                    if (isExist) {
                        FLLocalFIleVC *localVC = [[FLLocalFIleVC alloc]init];
                        [self.navigationController pushViewController:localVC animated:YES];
                        return;
                    }
                    
                }
                
                if ([TYDownLoadDataManager manager].waitingDownloadModels.count>0) {
                    [[TYDownLoadDataManager manager].waitingDownloadModels enumerateObjectsUsingBlock:^(TYDownloadModel * downloadModelIn, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([downloadModelIn.fileName isEqualToString:model.name]) {
                            [[TYDownLoadDataManager manager].waitingDownloadModels removeObject:downloadModelIn];
                        }
                    }];
                }
                
                //            {
                
                if (_progressView) {
                    [_progressView dismiss];
                    _progressView = nil;
                }
                if (!_progressView){
                    _progressView = [JYProcessView processViewWithType:ProcessTypeLine];
                    _progressView.descLb.text =@"正在下载文件";
                    _progressView.subDescLb.text = [NSString stringWithFormat:@"1个项目 "];
                    _progressView.cancleBlock = ^(){
                        [[FLFIlesHelper helper] cancleDownload];
                    };
                    
                    [[FLFIlesHelper helper]downloadAloneFilesWithModel:model parentUUID:_parentUUID Progress:^(TYDownloadProgress *progress) {
                        if (progress.progress) {
                            [_progressView setValueForProcess:progress.progress];
                            [_progressView show];
                        }
                    } State:^(TYDownloadState state, NSString *filePath, NSError *error) {
                        //                NSLog(@"%lu,%@,%@",(unsigned long)state,filePath,error);
                        if (state == TYDownloadStateCompleted) {
                            [_progressView dismiss];
                            _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
                            _documentController.delegate = self;
                            [self presentOptionsMenu];
                        }
                    }];
                }
                //                }];
                //                [alertVc addAction:cancle];
                //                [alertVc addAction:confirm];
                //                [self presentViewController:alertVc animated:YES completion:^{
                //                }];
            }
        }
    }
  }
}

- (void)repeatDelay{
    self.isSelect = false;
}

-(void)downloadModel:(TYDownloadModel *)downloadModel didChangeState:(TYDownloadState)state filePath:(NSString *)filePath error:(NSError *)error{
    
    if (state == TYDownloadStateCompleted) {
         MyNSLog(@"🙄%@",downloadModel.jy_fileName);
        FLDownload * download = [FLDownload new];
        download.name = downloadModel.jy_fileName;
        NSLog(@"%@",download.name);
        NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
        formatter1.dateFormat = @"yyyy-MM-dd hh:mm:ss";
        [formatter1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        NSString * dateString = [formatter1 stringFromDate:[NSDate date]];
        download.downloadtime = dateString;
        download.uuid = downloadModel.fileName;
        download.filePath = downloadModel.filePath;
        download.userId = FMConfigInstance.userUUID;
        [FMDBControl updateDownloadWithFile:download isAdd:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:FLDownloadFileChangeNotify object:nil];
    }
}
#pragma mark - floatMenuDelegate

-(void)didSelectMenuOptionAtIndex:(NSInteger)row{
    
    if (self.cellStatus == FLFliesCellStatusCanChoose) {
        if ([FLFIlesHelper helper].chooseFiles.count == 0) {
            [SXLoadingView showAlertHUD:@"请先选择文件" duration:1];
        }else{
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[FLFIlesHelper helper] downloadChooseFilesParentUUID:_parentUUID];
                FLLocalFIleVC *downloadVC = [[FLLocalFIleVC alloc]init];
                [self.navigationController pushViewController:downloadVC animated:YES];
//            });
        }
    }
}

#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self;
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

- (void)openTheFileWithFilePath:(NSString *)filePath{
    _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
    _documentController.delegate = self;
    [self presentOptionsMenu];
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
        _countLb.text = [NSString stringWithFormat:@"已选1个文件"];
        _countLb.font = [UIFont fontWithName:FANGZHENG size:16];
    }
    return _chooseHeadView;
}

@end
