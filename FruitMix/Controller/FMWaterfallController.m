//
//  FMWaterfallController.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/26.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMWaterfallController.h"
#import "FMWaterfallCell.h"
#import "FMAlbumAddPhotosVC.h"
#import "FMChoosePhotosController.h"
#import "FMAlbumEditViewController.h"
#import "FMAlbumDeleteVC.h"
//#import "FMMediaShareTask.h"
#import "FMAlbumDataSource.h"

#import "FMGetThumbImage.h"
#import "LCActionSheet.h"

#define CELL_COUNT 30
#define CELL_IDENTIFIER @"WaterfallCell"
@interface FMWaterfallController ()<IDMPhotoBrowserDelegate>{
    UIView * _backView;
}
@property (nonatomic, strong) NSArray *cellSizes;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic) UIView * settingView;//设置图
@property (nonatomic) NSArray * itemsArr;//用于 把datasource 都转化为 sharealbumitem  对象组
@property (nonatomic) NSMutableArray * hashArr;//用户传递给AddVC
@end

@implementation FMWaterfallController
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
        
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
//        layout.headerHeight = 15;
//        layout.footerHeight = 10;
        layout.minimumColumnSpacing = 5;
        layout.minimumInteritemSpacing = 5;
        layout.columnCount = 2;
//        layout.itemRenderDirection =CHTCollectionViewWaterfallLayoutItemRenderDirectionLeftToRight;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor blackColor];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[FMWaterfallCell class]
            forCellWithReuseIdentifier:CELL_IDENTIFIER];
    }
    return _collectionView;
}

-(NSMutableArray *)dataSource{
    if(!_dataSource){
        _dataSource = [NSMutableArray arrayWithArray:self.album.getAllContents];
    }
    return _dataSource;
}

//传递给photoBrowser
- (NSArray *)itemsArr{
    if (!_itemsArr) {
        @autoreleasepool {
            NSMutableArray * tempArr =  [NSMutableArray arrayWithCapacity:0];
            for (FMShareAlbumItem * item in self.dataSource) {
                item.shareid = [self.album uuid];
                [tempArr addObject:item];
            }
            _itemsArr = [tempArr copy];
        }
    }
    return  _itemsArr;
}

-(NSMutableArray *)hashArr{
    if (!_hashArr) {
        NSMutableArray * tempArr =  [NSMutableArray array];
        for (id<IDMPhoto> p in self.itemsArr) {
            [tempArr addObject:[p getPhotoHash]];
        }
        _hashArr = tempArr;
    }
    return _hashArr;
}
-(void)dealloc{

}

- (NSArray *)cellSizes {
    if (!_cellSizes) {
        _cellSizes = @[
                       [NSValue valueWithCGSize:CGSizeMake(500, 350)],
                       [NSValue valueWithCGSize:CGSizeMake(350, 500)],
                       [NSValue valueWithCGSize:CGSizeMake(1000, 700)],
                       [NSValue valueWithCGSize:CGSizeMake(700, 1000)]
                       ];
    }
    return _cellSizes;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.collectionView];
    if(!self.canComments){
        [self initNav];
    }
}

-(void)initNav{
    UIButton * right = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 20)];
    [right setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [right setImage:[UIImage imageNamed:@"more_highlight"] forState:UIControlStateHighlighted];
    [right addTarget:self  action:@selector(morebtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rItem = [[UIBarButtonItem alloc]initWithCustomView:right];
    self.navigationItem.rightBarButtonItem = rItem;
}

-(void)addSettingView{
    if (!_settingView) {
        _settingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, __kWidth,__kHeight)];
        _settingView.backgroundColor = [UIColor clearColor];
        [self.navigationController.view addSubview:_settingView];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self  action:@selector(removeSettingView)];
        [_settingView addGestureRecognizer:tap];
        UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(__kWidth - 269/2 - 10, 30, 269/2, 408/2-25)];
        backView.backgroundColor = [UIColor whiteColor];
        backView.layer.cornerRadius = 4;
        backView.layer.masksToBounds = YES;
        _backView = backView;
        [_settingView addSubview:backView];
        NSArray * nameArr = nil;
        if ([self.album viewers].count>1) {
            nameArr = @[@"设置相册",@"编辑照片",@"设置为私密",@"删除相册"];
        }else
            nameArr = @[@"设置相册",@"编辑照片",@"设置为分享",@"删除相册"];
        
        for (int i = 0; i<4; i++) {
            UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(39/2, (204-46)/4*i+12, 269/2-39/2, (204-46)/4)];
            [btn setTitle:nameArr[i] forState:UIControlStateNormal];
            btn.titleLabel.font= [UIFont fontWithName:DONGQING size:18];
            [btn setTitleColor:UICOLOR_RGB(0x333333) forState:UIControlStateNormal];
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [btn addTarget:self  action:@selector(settingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 10000+i;
            [backView addSubview:btn];
        }
    }
    
    for (UIButton * btn in _backView.subviews) {
        if (btn.tag == 10002) {
            NSString * str = self.album.viewers.count>1?@"设置为私密":@"设置为分享";
            [btn setTitle:str forState:UIControlStateNormal];
        }
    }
    
    _settingView.hidden = NO;
}

-(void)removeSettingView{
    if (_settingView) {
        _settingView.hidden = YES;
    }
}



-(void)settingBtnClick:(UIButton *)btn{
    NSInteger tag = btn.tag;
    switch (tag) {
        case 10000:{//设置相册
            [self removeSettingView];
            if(IsEquallString(self.album.author, DEF_UUID)){
                FMAlbumEditViewController * vc = [[FMAlbumEditViewController alloc]init];
                vc.album = self.album;
                [self.navigationController pushViewController:vc animated:YES];
            }else
                [SXLoadingView showAlertHUD:@"没有权限操作！" duration:0.5];
        }
            break;
        case 10001:{//编辑照片
            if ([self.album.maintainers containsObject:DEF_UUID] || [self.album.author isEqualToString:DEF_UUID]) {
                FMAlbumDeleteVC * vc = [[FMAlbumDeleteVC alloc]init];
                vc.block = ^(NSMutableArray * arr){
                    self.itemsArr = arr;
                    [self.collectionView reloadData];
                };
                vc.album = self.album;
                [self.navigationController pushViewController:vc animated:YES];
            }else
                [SXLoadingView showAlertHUD:@"没有权限编辑" duration:1];
            [self removeSettingView];
        }
            break;
        case 10002:{//设置私密或公开
            [self removeSettingView];
            if(IsEquallString(self.album.author, DEF_UUID)){
                [FMAlbumDataSource updateAlbum:self.album andComPleteBlock:^(BOOL success, BOOL isShare) {
                    if (success) {
                        if(isShare)
                            [(FMMediaShare *)_album setViewers:[FMDBControl getAllUsersUUID]];
                        else
                            [(FMMediaShare *)_album setViewers:@[]];
                        [SXLoadingView showAlertHUD:[NSString stringWithFormat:@"%@成功",isShare?@"分享":@"私密"] duration:1];
                    }else
                        [SXLoadingView showAlertHUD:[NSString stringWithFormat:@"%@失败",isShare?@"分享":@"私密"] duration:1];
                }];
            }else
                [SXLoadingView showAlertHUD:@"没有权限操作！" duration:0.5];
            
        }
            break;
        case 10003:{//删除相册
            [self removeSettingView];
            //删除本地记录
            if ([self.album.maintainers containsObject:DEF_UUID] || [self.album.author isEqualToString:DEF_UUID]) {
                @weakify(self);
                
                [[LCActionSheet sheetWithTitle:@"确认删除？" cancelButtonTitle:@"取消" clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
                    if (buttonIndex == 1 ) {
                        [SXLoadingView showProgressHUD:@"正在处理"];
                        [FMAlbumDataSource deleteAlbum:_album andComPleteBlock:^(BOOL success) {
                            if(success)
                                [weak_self deleteSuccess];
                            else{
                                [SXLoadingView hideProgressHUD];
                                [SXLoadingView showAlertHUD:@"删除失败" duration:1];
                            }
                        }];
                    }
                } otherButtonTitles:@"确认", nil] show];
                
            }else
                [SXLoadingView showAlertHUD:@"没有权限操作！" duration:0.5];
        }
            break;
        default:
            break;
    }
}



-(void)deleteSuccess{
    [SXLoadingView hideProgressHUD];
    [SXLoadingView showAlertHUD:@"删除成功" duration:1];
    [[NSNotificationCenter defaultCenter] postNotificationName:FM_NEED_UPDATE_UI_NOTIFY object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)morebtnClick:(UIButton *)btn{
    [self addSettingView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
//    self.navGestureDelegate =  self.navigationController.interactivePopGestureRecognizer.delegate;
//    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    self.navigationController.interactivePopGestureRecognizer.delegate = self.navGestureDelegate;
    [self removeSettingView];
}

-(void)cell:(FMWaterfallCell *)cell getImageWithItem:(FMShareAlbumItem *)item{
    NSString * degist = [item getPhotoHash];
    if(degist){
        [FMGetThumbImage getThumbImageWithAsset:item andCompleteBlock:^(UIImage *image, NSString *tag) {
            if(IsEquallString(tag, cell.imageTag))
                cell.imageView.image = image;
        }];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemsArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FMWaterfallCell *cell =
    (FMWaterfallCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER
                                                                                forIndexPath:indexPath];
    FMShareAlbumItem * item = self.itemsArr[indexPath.row]  ;
    cell.imageTag = [item getPhotoHash];
    cell.imageView.image = nil;
    [self cell:cell getImageWithItem:item];
//    cell.imageView.image = [UIImage imageNamed:self.dataSource[indexPath.item % 4]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    FMWaterfallCell *cell =  (FMWaterfallCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSInteger index = indexPath.row;
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:self.itemsArr animatedFromView:cell];
    [browser setInitialPageIndex:index];
    browser.delegate = self;
    browser.displayActionButton = NO;
    browser.displayArrowButton = YES;
    browser.displayCounterLabel = YES;
    browser.usePopAnimation = YES;
    browser.scaleImage = cell.imageView.image;
    browser.displayToolbar = NO;
    browser.photoBrowserType = JYPhotoBrowserTypeAlbum;
    browser.showTalkView = self.canComments;
    [self presentViewController:browser animated:YES completion:nil];

}

#pragma mark - IDMPhotoBrowserDelegate
- (UIView *)photoBrowser:(IDMPhotoBrowser *)photoBrowser needAnimationViewWillDismissAtPageIndex:(NSUInteger)index{
    NSInteger  sections = [self.collectionView numberOfSections];
    NSInteger _index = index;
    NSIndexPath * indexPath = nil;
    for (int i = 0; i<sections; i++) {
        NSInteger j = [self.collectionView numberOfItemsInSection:i];
        if( j < (_index+1)){
            _index -= j;
        }
        else{
            indexPath = [NSIndexPath indexPathForRow:_index inSection:i];
            break;
        }
    }
    UICollectionViewCell * cell = nil;
    if (indexPath) {
        cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        if (cell) {
            return ( (FMWaterfallCell *)cell).imageView;
        }else{
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            [self.collectionView layoutIfNeeded];
            cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            if (cell) {
                return ((FMWaterfallCell *)cell).imageView;
            }
        }
    }
    return nil;
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.cellSizes[indexPath.item % 4] CGSizeValue];
}

@end
