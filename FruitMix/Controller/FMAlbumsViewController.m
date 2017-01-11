//
//  FMAlbumsViewController.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/5.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMAlbumsViewController.h"
#import "FMChoosePhotosController.h"
#import "FMAlbumNamedController.h"

#import "FMWaterfallController.h"
#import "FMMediaShareTask.h"

#import "UIViewController+JYControllerTools.h"
#import "CWStatusBarNotification.h"
#import "NSString+Extension.h"

#import "FMGetThumbImage.h"
#import "UIColor+fm_color.h"
#import "FMAlbumSwipeCell.h"

#import "FMAlbumDataSource.h"
#import "FMBalloon.h"
#import "LCActionSheet.h"

@interface FMAlbumsViewController ()<UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate,FMAlbumDataSourceDelegate>
@property (nonatomic) UITableView * tableView;
@property (nonatomic) UIButton * controlBtn;

@property (nonatomic) BOOL isDisplayControlBtn;

@property (nonatomic) FMAlbumDataSource * albumDataSource;


@end

@implementation FMAlbumsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void)initView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight - 64 - 49) style:UITableViewStylePlain];
    [self.tableView registerClass:[FMAlbumSwipeCell class] forCellReuseIdentifier:@"albumCell"];
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 60;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorForCellBackground];
    self.tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self createControlbtn];
    self.isDisplayControlBtn = YES;
    [self loadData];
}

-(void)loadData{
    self.albumDataSource = [FMAlbumDataSource new];
    _albumDataSource.delegate = self;
}

#pragma mark - FMAlbumDataSource Delegate

-(void)albumDataSourceDidChange{
    [self.tableView reloadData];
}

#pragma mark - View Life Circle and SubViews

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.tableView.frame = CGRectMake(0, 0, __kWidth, __kHeight - 64);
    [self shouldHiddenControlBtn:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.tableView.frame = CGRectMake(0, 0, __kWidth, __kHeight - 64 - 49);
    [self.rdv_tabBarController setTabBarHidden:NO animated:NO];
    if (self.albumDataSource.dataSource.count) {
        [FMBalloon showBalloonInAlbum];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)createControlbtn{
    if (!_controlBtn) {
        _controlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _controlBtn.showsTouchWhenHighlighted = YES;
        [_controlBtn setImage:[UIImage imageNamed:@"add_album"] forState:UIControlStateNormal];
        _controlBtn.frame = CGRectMake(self.view.jy_Width-80 , self.view.jy_Height - 64 - 88 -56, 56, 56);
        _controlBtn.layer.cornerRadius = 28;
        _controlBtn.layer.masksToBounds = YES;
        [_controlBtn addTarget:self action:@selector(_controlBtnChick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_controlBtn];
    }
}

#pragma mark - handle
//加号响应事件
-(void)_controlBtnChick:(UIButton *)sender{
    FMChoosePhotosController * vc = [[FMChoosePhotosController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)shouldHiddenControlBtn:(BOOL)should{
//    if (should) {
//        if (_controlBtn.jy_Top < self.view.jy_Height) {
//            [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.4 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                _controlBtn.jy_Top = self.view.jy_Height;
//            } completion:^(BOOL finished) {
//                
//            }];
//        }
//    }else{
//        if (_controlBtn.jy_Top > self.view.jy_Height - 120) {
//            [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.4 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                _controlBtn.jy_Top = self.view.jy_Height-120;
//            } completion:^(BOOL finished) {
//                
//            }];
//        }
//    }
}
#pragma mark - utility

#pragma mark - delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.albumDataSource.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FMAlbumSwipeCell * cell = [tableView dequeueReusableCellWithIdentifier:@"albumCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    id<FMMediaShareProtocol> album = self.albumDataSource.dataSource[indexPath.row];
    if ([album getAllContents].count>0) {
        [self cell:cell getImageWithMediaShare:album];
    }else{
        cell.albumFaceImageView.image = [UIImage imageNamed:@"photo_placeholder"];
    }
    NSString * albumName = album.album[TitleKey];
    NSString * albumDesc = album.album[TextKey];
    
    cell.albumNameAndNumLb.text = [NSString stringWithFormat:@"%@ .%ld张",albumName,(unsigned long)album.getAllContents.count];
    cell.hasDesc = albumDesc.length > 0;
    cell.descriptionlb.text = albumDesc;
    cell.timeLb.text = [NSString stringWithFormat:@"%@   %@",[self getDateStringWithShareDate:[NSDate dateWithTimeIntervalSince1970:[album getTime]/1000]],[FMConfigInstance getUserNameWithUUID:album.author]];
    cell.isShare = [album viewers].count >= 2;
    return cell;
}

-(NSString *)getDateStringWithShareDate:(NSDate *)date{
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy年MM月dd日";
    NSString * dateString = [formatter1 stringFromDate:date];
    return dateString;
}


-(void)cell:(FMAlbumSwipeCell *)cell getImageWithMediaShare:(id<FMMediaShareProtocol>)album{
    NSString * degist = ((FMShareAlbumItem *)(album.getAllContents[0])).digest;
    cell.contentView.backgroundColor = [UIColor colorForCellBackground];
    cell.albumFaceImageView.image = nil;
    cell.imgTag = degist;
    [FMGetThumbImage getThumbImageWithAsset:(FMShareAlbumItem *)(album.getAllContents[0]) andCompleteBlock:^(UIImage *image, NSString *tag) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (IsEquallString(tag, cell.imgTag)) {
                cell.albumFaceImageView.image = image;
            }
        });
    }];
//     getThumbImageWithPhotoHash:degist andCompleteBlock:^(UIImage *image, NSString *tag) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (IsEquallString(tag, cell.imgTag)) {
//                cell.albumFaceImageView.image = image;
//            }
//        });
//    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 113+5;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id<FMMediaShareProtocol> album = self.albumDataSource.dataSource[indexPath.row];
    FMWaterfallController * vc = [[FMWaterfallController alloc]init];
    vc.album = album;
    vc.canComments = NO;
    vc.title = album.album[TitleKey];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
     [self shouldHiddenControlBtn:NO];
}

//公开私有 按钮
-(void)fmAlbumSwitchCell:(UITableViewCell *)cell didClickLeftBtn:(UIButton *)btn{
    [self shouldHiddenControlBtn:NO];
    
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    id<FMMediaShareProtocol> album = self.albumDataSource.dataSource[indexPath.row];
    if(IsEquallString(album.author, DEF_UUID)){
        [FMAlbumDataSource updateAlbum:album andComPleteBlock:^(BOOL success, BOOL isShare) {
            [self successToChangeAlbums:success];
        }];
    }else
        [MyAppDelegate.notification displayNotificationWithView:[FMNotifyView notifyViewWithMessage:@"没有权限操作"] forDuration:1];
    
//    NSMutableDictionary * dic = [self _dicForShare:YES andAlbum:album];
//    if(IsEquallString(album.author, DEF_UUID)){
//        if([album isKindOfClass:[FMMediaShare class]]){
//            [MyAppDelegate.notification displayNotificationWithView:[self createNotificationView:@"正在修改"] completion:nil];
//            FMMediaPatchAPI * api = [[FMMediaPatchAPI alloc] initWithType:PatchTypeReplace
//                                                                  andPath:album.uuid
//                                                                 andValue:dic];
//            [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//                [self successToChangeAlbums];
//            } failure:^(__kindof JYBaseRequest *request) {
//                 [MyAppDelegate.notification dismissNotification];
//                if (request.responseStatusCode == 200) {
//                    [self successToChangeAlbums];
//                }
//            }];
//        }else if ([album isKindOfClass:[FMNeedUploadMediaShare class]]){
//            [(FMNeedUploadMediaShare *)album setViewers:dic[@"viewers"]];
//            [(FMNeedUploadMediaShare *)album setMaintainers:dic[@"maintainers"]];
//            BOOL success = [FMMediaShareTask managerUpdateAtMediaShare:album];
//            [[NSNotificationCenter defaultCenter] postNotificationName:FM_NEED_UPDATE_UI_NOTIFY object:nil];
//            //若已上传 刷新 mediaShare  不做操作
//            if (!success) {
//                NSLog(@"本地此mediaShare以上传");
//            }
//        }
//    }else{
        
//    }
}

-(void)successToChangeAlbums:(BOOL)success{
    NSLog(@"成功");
    [MyAppDelegate.notification dismissNotification];
    [MyAppDelegate.notification displayNotificationWithView:[FMNotifyView notifyViewWithMessage:success?@"操作成功":@"操作失败"] forDuration:1];
    [[NSNotificationCenter defaultCenter] postNotificationName:FM_NEED_UPDATE_UI_NOTIFY object:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SXLoadingView hideProgressHUD];
    });
}
//删除按钮
-(void)fmAlbumSwitchCell:(UITableViewCell *)cell didClickRightBtn:(UIButton *)btn{
    [self shouldHiddenControlBtn:NO];
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    id<FMMediaShareProtocol> album = self.albumDataSource.dataSource[indexPath.row];
    if(IsEquallString(album.author, DEF_UUID)){
        [FMAlbumDataSource deleteAlbum:album andComPleteBlock:^(BOOL success) {
            if(success)
                [self successToChangeAlbums:success];
            else
                [MyAppDelegate.notification displayNotificationWithView:[FMNotifyView notifyViewWithMessage:@"操作失败"] forDuration:1];
        }];
    }
    else
         [MyAppDelegate.notification displayNotificationWithView:[FMNotifyView notifyViewWithMessage:@"没有权限操作"] forDuration:1];
    
//    [self shouldHiddenControlBtn:NO];
//    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
//    id<FMMediaShareProtocol> album = self.albumDataSource.dataSource[indexPath.row];
//    if(IsEquallString(album.author, DEF_UUID)){
//        if([album isKindOfClass:[FMMediaShare class]]){
//            NSMutableDictionary * dic = [self _dicForShare:NO andAlbum:album];
//            FMMediaPatchAPI * api = [[FMMediaPatchAPI alloc] initWithType:PatchTypeReplace
//                                                                  andPath:album.uuid
//                                                                 andValue:dic];
//            [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//                [self successToChangeAlbums];
//            } failure:^(__kindof JYBaseRequest *request) {
//                if (request.responseStatusCode == 200) {
//                    [self successToChangeAlbums];
//                }else
//                    NSLog(@"失败,%@",request.error);
//            }];
//        }else if ([album isKindOfClass:[FMNeedUploadMediaShare class]]){
//            [FMMediaShareTask managerDeleteShareWithShareID:album.uuid];
//            [self loadData];
//        }
//        
//    }
//    else
//        [MyAppDelegate.notification displayNotificationWithMessage:@"没有权限操作" forDuration:1];
}


- (UIView *)createNotificationView:(NSString *)message
{
    CGFloat width = [message sizeWithFont:[UIFont fontWithName:FANGZHENG size:13.5f] maxSize:CGSizeMake(MAXFLOAT, 20)].width;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 20)];
    view.backgroundColor = StatusBar_Color;
    
    UILabel *notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(view.frame) / 2) - (width/2), 2.5f, width, 17)];
    notificationLabel.font = [UIFont fontWithName:FANGZHENG size:13.5f];
    notificationLabel.textColor = [UIColor whiteColor];
    notificationLabel.text = message;
    [view addSubview:notificationLabel];
    
    //Activity Indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.frame = CGRectMake(notificationLabel.frame.origin.x - 22, 6, 20, 10);
    activityIndicator.transform = CGAffineTransformMakeScale(0.60, 0.60);
    activityIndicator.hidesWhenStopped = YES;
    [activityIndicator startAnimating];
    [view addSubview:activityIndicator];
    
    return view;
}


#pragma mark Swipe Delegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return YES;
}

-(NSArray*)swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    id<FMMediaShareProtocol> album = self.albumDataSource.dataSource[indexPath.row];
    swipeSettings.transition = MGSwipeTransitionBorder;
    swipeSettings.enableSwipeBounces = NO;
    expansionSettings.buttonIndex = -1;
    
    @weakify(self);
    if (direction == MGSwipeDirectionLeftToRight) {
        expansionSettings.fillOnTrigger = NO;
        NSString * btnTitle =  album.viewers.count< 2?@"分享":@"私密";
        return @[[MGSwipeButton buttonWithTitle:btnTitle backgroundColor:[UIColor colorForOrangeColor]  padding:30 callback:^BOOL(MGSwipeTableCell *sender) {
            [weak_self fmAlbumSwitchCell:sender didClickLeftBtn:nil];
            return YES;
        }]];
    }else{
        expansionSettings.fillOnTrigger = NO;
        return @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"del"] backgroundColor:[UIColor redColor] padding:35 callback:^BOOL(MGSwipeTableCell *sender) {
            [[LCActionSheet sheetWithTitle:@"确认删除？" cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 1 ) {
                    [weak_self fmAlbumSwitchCell:sender didClickRightBtn:nil];
                }
            } otherButtonTitles:@"确认", nil] show];
            return YES;
        }]];
    }
}

@end
