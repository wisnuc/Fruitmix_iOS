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

NSInteger filesNameSortSecond(id file1, id file2, void *context)
{
    FLFilesModel *f1,*f2;
    f1 = (FLFilesModel *)file1;
    f1 = (FLFilesModel *)file2;
    return  [f1.name localizedCompare:f2.name];
}

@interface FLSecondFilesVC ()<UITableViewDelegate,UITableViewDataSource,FLDataSourceDelegate,LCActionSheetDelegate,floatMenuDelegate,UIDocumentInteractionControllerDelegate>
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
    //     if (self.cellStatus == FLFliesCellStatusNormal) {
    
    [UIView animateWithDuration:0.5 animations:^{
        _chooseHeadView.transform = CGAffineTransformTranslate(_chooseHeadView.transform, 0, 64);
    }];
    _addButton.hidden = NO;
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    self.cellStatus = FLFliesCellStatusCanChoose;
    [self.tableview reloadData];
    //     }
}

- (void)actionForNormalStatus{
    [UIView animateWithDuration:0.5 animations:^{
        _chooseHeadView.transform = CGAffineTransformTranslate(_chooseHeadView.transform, 0, -64);
    }];
    _addButton.hidden = YES;
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    self.cellStatus = FLFliesCellStatusNormal;
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
        if (!model.isFile) {
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

#pragma mark - FLDataSourceDelegate

-(void)fl_Datasource:(FLDataSource *)datasource finishLoading:(BOOL)finish{
    if (datasource == self.dataSource && finish) {
        [self.tableview displayWithMsg:@"暂无文件" withRowCount:self.dataSource.dataSource.count andIsNoData:YES andTableViewFrame:self.view.bounds andTouchBlock:nil];
        [self sequenceDataSource];
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
    [[FLFIlesHelper helper] configCells:cell withModel:model cellStatus:self.cellStatus viewController:self];
    
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
            if ([[FLFIlesHelper helper] containsFile:model]) {
                [[FLFIlesHelper helper] removeChooseFile:model];
            }else
                [[FLFIlesHelper helper] addChooseFile:model];
            
            [self.tableview reloadData];
        }else{
            if (!_progressView)
                _progressView = [JYProcessView processViewWithType:ProcessTypeLine];
            _progressView.descLb.text =@"正在下载文件";
            _progressView.subDescLb.text = [NSString stringWithFormat:@"1个项目 "];
            _progressView.cancleBlock = ^(){
                [[FLFIlesHelper helper] cancleDownload];
            };
            [[FLFIlesHelper helper]downloadAloneFilesWithModel:model Progress:^(TYDownloadProgress *progress) {
                if (progress.progress) {
                    [_progressView setValueForProcess:progress.progress];
                    [_progressView show];
                }
            } State:^(TYDownloadState state, NSString *filePath, NSError *error) {
                NSLog(@"%lu,%@,%@",(unsigned long)state,filePath,error);
                if (state == TYDownloadStateCompleted) {
                    [_progressView dismiss];
                    _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
                    _documentController.delegate = self;
                    [self presentOptionsMenu];
                }
            }];
        }
    }
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
