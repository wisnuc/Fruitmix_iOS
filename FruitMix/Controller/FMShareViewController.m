//
//  FMShareViewController.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/5.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMShareViewController.h"
#import "FMCommentController.h"
#import "PhotoManager.h"
#import "FMWaterfallController.h"
#import "FMShareScrollComment.h"
#import "FMSetListVC.h"
#import "FMAlbumNamedController.h"
#import "UIViewController+JYControllerTools.h"
#import "JYExceptionHandler.h"
#import "FMSharesCell.h"
#import "FMStatusLayout.h"
#import "YYControl.h"

#import "FMABManager.h"

#import "FMMediaShareDataSource.h"

#import "UIScrollView+JYEmptyView.h"


@interface FMShareViewController ()<UITableViewDataSource,UITableViewDelegate,IDMPhotoBrowserDelegate,FMSharesCellDelegate,ShareDataSourceDelegate>

@property (nonatomic) UITableView * tableView;

@property (nonatomic, strong) MSWeakTimer    *m_timer;

@property (nonatomic,weak) FMMediaShareDataSource * dataSource;

@end

#define kSharePhotoDisplayH __kWidth/4*3

@implementation FMShareViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView]; 
    self.view.backgroundColor =   UICOLOR_RGB(0xe2e2e2);
    [self registNotify];
    [self createTimer];
    self.dataSource = [FMMediaShareDataSource sharedDataSource];
    self.dataSource.delegate = self;
    [self asynAnyThings];//做所有后台做的事
    [self shareDataSourceDidUpdate];
}

-(void)registNotify{
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(jumpToAlbum) name:APP_JUMP_TO_ALBUM_NOTIFY object:nil];
}

-(void)jumpToAlbum{
    self.rdv_tabBarController.selectedIndex = 2;
}


-(void)asynAnyThings{
    //上传照片
//    shouldUplod(^{
    [PhotoManager checkNetwork];
//    });
    //监听奔溃
//    [FMABManager shareManager];
    [JYExceptionHandler installExceptionHandler];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //初始化 DeviceUUID
        [PhotoManager getUUID];
//        [FMDBControl asynOwnerSet];//更新ownerSet
        [FMDBControl asynUsers];
    });
    
}

-(void)dealloc{
    if (_m_timer) {
        [_m_timer invalidate];
        _m_timer = nil;
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)createTimer {
    self.m_timer = [MSWeakTimer scheduledTimerWithTimeInterval:4.f target:self selector:@selector(timerEvent) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    
}

- (void)timerEvent {
    [[NSNotificationCenter defaultCenter] postNotificationName:TIMER_NOTIFY object:nil];
}


-(void)initView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor =  UICOLOR_RGB(0xe2e2e2);
    _tableView.noDataImageName = @"no_photo";
    [_tableView registerClass:[FMSharesCell class] forCellReuseIdentifier:@"sharesCell"];
    [self.view addSubview:self.tableView];
    [self updateFrames];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    CGPoint point = [touch locationInView:self.tableView];
    if (point.x < 15) {
        return NO;
    }
    return YES;
}

-(void)updateFrames{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.top.mas_equalTo(self.view.mas_top);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
}

#pragma mark - TableView DataSource delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    id<FMMediaShareProtocol> detailModel = [self.dataSource.dataSource objectAtIndex:indexPath.row];

    FMSharesCell * cell = [tableView dequeueReusableCellWithIdentifier:@"sharesCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setLayout:detailModel];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FMStatusLayout * layout = self.dataSource.dataSource[indexPath.row];
    return layout.height;
}

#pragma mark - FMSharesCellDelegate

/// 点击了 Cell
- (void)cellDidClick:(FMSharesCell *)cell{

}
/// 点击了评论
- (void)cellDidClickComment:(FMSharesCell *)cell{
    id<FMMediaShareProtocol> share = cell.layout.status;
    switch (cell.layout.cellType) {
        case FMSharesTypePhoto:{
            if (share.getAllContents.count > 0) {
                FMShareAlbumItem * item = share.getAllContents[0];
                item.shareid = share.uuid;
                FMCommentController * vc = [[FMCommentController alloc]init];
                vc.photoHash = item.digest;
                vc.item = item;
                [self presentViewController:vc animated:YES completion:nil];
            }else
                [SXLoadingView showAlertHUD:@"无照片" duration:0.5];
        }break;
        case FMSharesTypeAlbum:{
            FMWaterfallController * vc = [[FMWaterfallController alloc]init];
            vc.canComments = YES;
            vc.album = share;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        case FMSharesTypeSet:{
            FMSetListVC * vc = [[FMSetListVC alloc] init];
            vc.share = share;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        default:
            break;
    }
    
}
/// 点击了图片
- (void)cell:(FMSharesCell *)cell didClickImageAtIndex:(NSUInteger)index{
     id<FMMediaShareProtocol> share = cell.layout.status;
    switch (cell.layout.cellType) {
        case FMSharesTypePhoto:
        case FMSharesTypeSet:{
            if (share.getAllContents.count > 0) {
                IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:share.getAllContents animatedFromView:(YYControl*)cell.statusView.picViews[index]];
                [browser setInitialPageIndex:index];
                browser.showTalkView = YES;
                browser.delegate = cell;
                browser.displayActionButton = NO;
                browser.displayArrowButton = YES;
                browser.displayCounterLabel = YES;
                browser.usePopAnimation = YES;
                browser.scaleImage = [(YYControl*)cell.statusView.picViews[index] image];
                browser.displayToolbar = NO;
                browser.photoBrowserType = JYPhotoBrowserTypeShare;
                [self presentViewController:browser animated:YES completion:nil];
            }
        }break;
        case FMSharesTypeAlbum:{
            FMWaterfallController * vc = [[FMWaterfallController alloc]init];
            vc.title = share.album[TitleKey];
            vc.canComments = YES;
            vc.album = share;
            [self.navigationController pushViewController:vc animated:YES];
        }break;
        default:
            break;
    }

}

/// 点击了 Cell 查看更多按钮
- (void)cellDidClickReadMore:(FMSharesCell *)cell{
    id<FMMediaShareProtocol> share = cell.layout.status;
    FMSetListVC * vc = [[FMSetListVC alloc] init];
    vc.share = share;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma  mark - DataSource
-(void)shareDataSourceDidUpdate{
    [self.tableView reloadData];  
    [self.tableView displayWithMsg:@"暂无分享数据" withRowCount:self.dataSource.dataSource.count andIsNoData:YES  andTableViewFrame:self.view.bounds
                     andTouchBlock:nil];
}

@end
