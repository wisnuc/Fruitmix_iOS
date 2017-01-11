//
//  FMSetListVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/2.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMSetListVC.h"
#import "FMPhotosCollectionViewCell.h"
#import "FMHeadView.h"
#import "IDMPhotoBrowser.h"
#import "UIScrollView+IndicatorExt.h"

@interface FMSetListVC ()<FMPhotoCollectionViewDelegate,FMPhotosCollectionViewCellDelegate,FMHeadViewDelegate,IDMPhotoBrowserDelegate>

@property (nonatomic) FMPhotoCollectionView * collectionView;

@property (nonatomic) UIView * chooseHeadView;

@property (nonatomic) NSMutableArray  * dataSource;

@property (nonatomic) NSMutableArray * imageArr;
@property (nonatomic) NSMutableArray * timeArr;

@end

@implementation FMSetListVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel * titleLb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
    titleLb.textAlignment = NSTextAlignmentCenter;
    titleLb.font = [UIFont fontWithName:FANGZHENG size:18];
    titleLb.textColor = UICOLOR_RGB(0xffffff);
    titleLb.text = self.title;
    self.navigationItem.titleView = titleLb;
    [self initView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initData];
    });
}

-(void)initData{
    self.imageArr = [NSMutableArray arrayWithCapacity:0];
    self.timeArr = [NSMutableArray arrayWithCapacity:0];
    self.dataSource = [NSMutableArray arrayWithCapacity:0];
    [self initPhotos];
}



-(void)initPhotos{
    if(self.share.getAllContents.count){
        for (FMShareAlbumItem * item in self.share.getAllContents) {
            item.shareid = self.share.uuid;
            [self.imageArr addObject:item];
        }
        [self sequencePhotos];
    }
}



-(void)initView{
    self.collectionView = [[FMPhotoCollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.jy_Width, self.view.jy_Height-64)];
    self.collectionView.fmDelegate = self;
    self.collectionView.userIndicator = YES;
    [self.view addSubview:self.collectionView];
    self.collectionView.fmState = FMPhotosCollectionViewCellStateNormal;
    [self.collectionView registerNib:[UINib nibWithNibName:@"FMPhotosCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"photocell"];
    [self addPinchGesture];
}


//增加捏合手势
-(void)addPinchGesture{
    UIPinchGestureRecognizer * pin = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    [self.collectionView addGestureRecognizer:pin];
}


#pragma mark - handle

//捏合响应
-(void)handlePinch:(UIPinchGestureRecognizer *)pin{
    if (pin.state == UIGestureRecognizerStateBegan) {
        if(pin.scale > 1.0f){
            [self.collectionView changeFlowLayoutIsBeSmall:NO];
        }else{
            [self.collectionView changeFlowLayoutIsBeSmall:YES];
        }
    }
    
}

/********************************************************************************************************/
/*************************************     delegate    **************************************************/
/********************************************************************************************************/

#pragma mark - FMPhotoCollectionViewDelegate

-(UICollectionViewCell *)fm_CollectionView:(FMPhotoCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FMPhotosCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photocell" forIndexPath:indexPath];
    NSArray * datas = [self.dataSource objectAtIndex:indexPath.section];
    FMPhotoAsset * asset = datas[indexPath.row];
    cell.asset = asset;
    if (collectionView.indicator) {
        collectionView.indicator.slider.timeLabel.text = [self getMouthDateStringWithPhoto:asset.createtime];
    }
    // 请求图片
    cell.fmDelegate = self;
    cell.state = collectionView.fmState;
    return cell;
}

-(NSInteger)fm_CollectionView:(FMPhotoCollectionView *)collectinView numberOfRowInSection:(NSUInteger)num{
    NSArray * datas = [self.dataSource objectAtIndex:num];
    return datas.count;
}

-(NSInteger)fm_CollectionViewNumberOfSectionInView:(FMPhotoCollectionView *)collectinView{
    return _dataSource.count;
}

//headView
- (FMHeadView *)fm_CollectionView:(FMPhotoCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    FMHeadView * headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView" forIndexPath:indexPath];
    NSDate * date = [self.timeArr objectAtIndex:indexPath.section];
    headView.headTitle = [NSDate getDateStringWithPhoto:date];
    headView.fmState = _collectionView.fmState;
    //判断该区是否选中状态
    headView.isChoose = NO;
    headView.fmIndexPath = indexPath;
    headView.fmDelegate = self;
    return headView;
}

-(void)fm_CollectionView:(FMPhotoCollectionView *)collectinView didSelectedIndexPath:(NSIndexPath *)indexPath{
    FMPhotosCollectionViewCell *cell = (FMPhotosCollectionViewCell *)[collectinView cellForItemAtIndexPath:indexPath];
    //在数据源找到对象
    if(self.collectionView.fmState == FMPhotosCollectionViewCellStateNormal){
        //当前选中的是第多少张图
        NSInteger index = indexPath.row;
        for (int i = 0; i < indexPath.section; i ++) {
            index += [self.collectionView numberOfItemsInSection:i];
        }
        
        NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
        for (NSArray * arr1 in self.dataSource) {
            [arr addObjectsFromArray:arr1];
        }
        
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:arr animatedFromView:cell];
        [browser setInitialPageIndex:index];
        browser.delegate = self;
        browser.displayActionButton = NO;
        browser.displayArrowButton = YES;
        browser.displayCounterLabel = YES;
        browser.usePopAnimation = YES;
        browser.scaleImage = cell.fmPhotoImageView.image;
        browser.displayToolbar = NO;
        browser.photoBrowserType = JYPhotoBrowserTypeShare;
        browser.showTalkView = YES;
        [self presentViewController:browser animated:YES completion:nil];
    }
}



#pragma mark - FMHeadViewDelegate

//选择了全选整个区的按钮
- (void)FMHeadView:(FMHeadView *)headView isChooseBtn:(BOOL)isChoose{

}


#pragma mark - FMPhotosCollectionViewCellDelegate
//点击了选择按钮
-(void)FMPhotosCollectionViewCellDidChoose:(FMPhotosCollectionViewCell *)cell{
    NSLog(@"选择了这张图");
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    [self fm_CollectionView:self.collectionView didSelectedIndexPath:indexPath];
    
}
//响应了长按手势
-(void)FMPhotosCollectionViewCellDidLongPress:(FMPhotosCollectionViewCell *)cell{
    
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
            return ((FMPhotosCollectionViewCell *)cell).fmPhotoImageView;
        }else{
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            [self.collectionView layoutIfNeeded];
            cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            if (cell) {
                return ((FMPhotosCollectionViewCell *)cell).fmPhotoImageView;
            }
        }
    }
    return nil;
}

#pragma mark - 排序数据源。
//排序
-(void)sequencePhotos{
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSComparator cmptr = ^(IDMPhoto * photo1, IDMPhoto * photo2){
            if ([[[photo1 getPhotoCreateTime]laterDate:[photo2 getPhotoCreateTime]] isEqualToDate:[photo1 getPhotoCreateTime]]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            if ([[[photo1 getPhotoCreateTime]laterDate:[photo2 getPhotoCreateTime]] isEqualToDate:[photo2 getPhotoCreateTime]]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        };
        
        [weak_self.imageArr sortUsingComparator:cmptr];
        
        [weak_self getTimeArrAndPhotoGroupArrWithCompleteBlock:^(NSMutableArray *tGroup, NSMutableArray *pGroup) {
            weak_self.timeArr = tGroup;
            weak_self.dataSource = pGroup;
            [weak_self.collectionView reloadData];
        }];
    });
}

//排序分组：
-(void)getTimeArrAndPhotoGroupArrWithCompleteBlock:(SortSuccessBlock)block{
    NSMutableArray * tArr = [NSMutableArray array];//时间组
    NSMutableArray * pGroupArr = [NSMutableArray array];//照片组数组
    if (self.imageArr.count>0) {
        IDMPhoto * photo = self.imageArr[0];
        NSMutableArray * photoDateGroup1 = [NSMutableArray array];//第一组照片
        [photoDateGroup1 addObject:photo];
        [pGroupArr addObject:photoDateGroup1];
        [tArr addObject:[photo getPhotoCreateTime]];
        
        NSMutableArray * photoDateGroup2 = photoDateGroup1;//最近的一组
        for (int i = 1 ; i < self.imageArr.count; i++) {
            IDMPhoto * photo1 =  self.imageArr[i];
            IDMPhoto * photo2 = self.imageArr[i-1];
            if([[self getDateStringWithPhoto:[photo1 getPhotoCreateTime]] isEqualToString:[self getDateStringWithPhoto:[photo2 getPhotoCreateTime]]]){
                [photoDateGroup2 addObject:photo1];
            }
            else{
                [tArr addObject:[photo1 getPhotoCreateTime]];
                photoDateGroup2 = nil;
                photoDateGroup2 = [NSMutableArray array];
                [photoDateGroup2 addObject:photo1];
                [pGroupArr addObject:photoDateGroup2];
            }
            
        }
    }
    //主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        block(tArr,pGroupArr);
    });
}

-(NSDate *)getFormatDateWithDate:(NSDate *)date{
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    [formatter1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString * dateString = [formatter1 stringFromDate:date];
    NSDate * dateB = [formatter1 dateFromString:dateString];
    return dateB;
}


-(NSString *)getDateStringWithPhoto:(NSDate *)date{
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy-MM-dd";
    NSString * dateString = [formatter1 stringFromDate:date];
    return dateString;
}

-(NSString *)getMouthDateStringWithPhoto:(NSDate *)date{
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy年MM月";
    NSString * dateString = [formatter1 stringFromDate:date];
    return dateString;
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    for (NSArray * arr in self.dataSource) {
        for (id<IDMPhoto> photo in arr) {
            [photo unloadUnderlyingImage];
        }
    }
}


@end
