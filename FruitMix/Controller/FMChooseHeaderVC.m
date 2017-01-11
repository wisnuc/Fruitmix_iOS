//
//  FMChooseHeaderVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/8.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMChooseHeaderVC.h"
#import "FMPhotosCollectionViewCell.h"
#import "IDMPhotoBrowser.h"
#import "UIScrollView+IndicatorExt.h"
#import "FMPhotoAsset.h"
#import "UIViewController+JYControllerTools.h"
#import "FMPhotoDataSource.h"
#import "YSHYClipViewController.h"

@interface FMChooseHeaderVC ()<FMPhotoCollectionViewDelegate,FMPhotosCollectionViewCellDelegate,IDMPhotoBrowserDelegate,ClipViewControllerDelegate>
@property (nonatomic) FMPhotoCollectionView * collectionView;
@property (nonatomic) FMPhotoDataSource * photoDataSource;
@end

@implementation FMChooseHeaderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceFinishToLoadPhotos) name:FMPhotoDatasourceLoadFinishNotify object:nil];
    [self initView];
    [self initData];
}

-(void)initData{
    self.photoDataSource = [FMPhotoDataSource shareInstance];
    if (_photoDataSource.isFinishLoading) {
        [self.collectionView reloadData];
    }
}

-(void)initView{
    self.collectionView = [[FMPhotoCollectionView alloc]initWithFrame:CGRectZero];
    self.collectionView.fmDelegate = self;
    self.collectionView.userIndicator = YES;
    [self.view addSubview:self.collectionView];
    self.collectionView.fmState = FMPhotosCollectionViewCellStateNormal;
    [self.collectionView registerNib:[UINib nibWithNibName:@"FMPhotosCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"photocell"];
    [self addPinchGesture];
    [self updateFrame];
}

-(void)updateFrame{
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right);
        make.left.mas_equalTo(self.view.mas_left);
        make.top.mas_equalTo(self.view.mas_top);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
}

//增加捏合手势
-(void)addPinchGesture{
    UIPinchGestureRecognizer * pin = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    [self.collectionView addGestureRecognizer:pin];
}

//捏合响应
-(void)handlePinch:(UIPinchGestureRecognizer *)pin{
    if (pin.state == UIGestureRecognizerStateBegan) {
        if(pin.scale > 1.0f){
            [self.collectionView changeFlowLayoutIsBeSmall:NO];
        }else{
            [self.collectionView changeFlowLayoutIsBeSmall:YES];
        }
        [self.collectionView reloadData];
    }
}

#pragma mark - delegates

-(UICollectionViewCell *)fm_CollectionView:(FMPhotoCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FMPhotosCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photocell" forIndexPath:indexPath];
    NSArray * datas = [self.photoDataSource.dataSource objectAtIndex:indexPath.section];
    // 请求图片
    cell.fmDelegate = self;
    cell.state = collectionView.fmState;
    id<IDMPhoto> asset = datas[indexPath.row];
    cell.asset = asset;
    if (collectionView.indicator) {
        collectionView.indicator.slider.timeLabel.text = [self getMouthDateStringWithPhoto:[asset getPhotoCreateTime]];
    }
    return cell;
}

-(NSInteger)fm_CollectionView:(FMPhotoCollectionView *)collectinView numberOfRowInSection:(NSUInteger)num{
    NSArray * datas = [self.photoDataSource.dataSource objectAtIndex:num];
    return datas.count;
}

-(NSInteger)fm_CollectionViewNumberOfSectionInView:(FMPhotoCollectionView *)collectinView{
    return _photoDataSource.dataSource.count;
}


//headView
- (FMHeadView *)fm_CollectionView:(FMPhotoCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    FMHeadView * headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView" forIndexPath:indexPath];
    NSDate * date = [self.photoDataSource.timeArr objectAtIndex:indexPath.section];
    headView.headTitle = [NSDate getDateStringWithPhoto:date];
    headView.fmState = _collectionView.fmState;
    headView.fmIndexPath = indexPath;
    return headView;
}


-(NSString *)getMouthDateStringWithPhoto:(NSDate *)date{
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy年MM月";
    [formatter1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString * dateString = [formatter1 stringFromDate:date];
    //    NSLog(@"%@",dateString);
    if (IsEquallString(dateString, @"1970年01月")) {
        dateString = @"未知时间";
    }
    return dateString;
}

-(void)fm_CollectionView:(FMPhotoCollectionView *)collectinView didSelectedIndexPath:(NSIndexPath *)indexPath{
    
    NSArray * datas = [self.photoDataSource.dataSource objectAtIndex:indexPath.section];
    FMPhotoAsset * photo = datas[indexPath.row];
    
    
    YSHYClipViewController * clipView = [[YSHYClipViewController alloc]initWithPhoto:photo];
    clipView.delegate = self;
    clipView.clipType = CIRCULARCLIP; //支持圆形:CIRCULARCLIP 方形裁剪:SQUARECLIP   默认:圆形裁剪
//    if(![textField.text isEqualToString:@""])
//    {
//        radius =textField.text.intValue;
//        clipView.radius = radius;   //设置 裁剪框的半径  默认120
//    }
    //    clipView.scaleRation = 2;// 图片缩放的最大倍数 默认为3
//    [self presentViewController:clipView animated:YES completion:nil];
    [self.rt_navigationController pushViewController:clipView animated:YES complete:^(BOOL finished) {
        [self.rt_navigationController removeViewController:self];
    }];
}

//点击了选择按钮
-(void)FMPhotosCollectionViewCellDidChoose:(FMPhotosCollectionViewCell *)cell{
    NSLog(@"选择了这张图");
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    [self fm_CollectionView:self.collectionView didSelectedIndexPath:indexPath];
    
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
            return cell;
        }else{
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            [self.collectionView layoutIfNeeded];
            cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            if (cell) {
                return cell;
            }
        }
    }
    return nil;
}

#pragma mark - ClipViewControllerDelegate
-(void)ClipViewController:(YSHYClipViewController *)clipViewController FinishClipImage:(UIImage *)editImage
{
    [clipViewController dismissViewControllerAnimated:YES completion:^{
//        [btn setImage:editImage forState:UIControlStateNormal];
    }];;
}


#pragma DataSouce notify

-(void)dataSourceFinishToLoadPhotos{
    [self.collectionView reloadData];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
