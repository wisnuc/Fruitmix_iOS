//
//  FMAlbumAddPhotosVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/5/23.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMAlbumAddPhotosVC.h"

#import "UIScrollView+IndicatorExt.h"
#import "FMPhotosCollectionViewCell.h"
#import "FMHeadView.h"
#import "FMPhoto.h"
#import "FMAlbumNamedController.h"
#import "NSString+JYImageType.h"
#import "FMPhotoDataSource.h"

@interface FMAlbumAddPhotosVC ()<FMPhotoCollectionViewDelegate,FMPhotosCollectionViewCellDelegate,FMHeadViewDelegate>

@property (nonatomic) FMPhotoCollectionView * collectionView;

//选择的照片
@property (nonatomic) NSMutableSet * choosePhotos;
//选择了整组
@property (nonatomic) NSMutableArray * chooseSection;

@property (nonatomic) UIButton * scrollBtn;

@property (nonatomic) NSMutableSet * addArr;//patch

@property (nonatomic) FMPhotoDataSource * photoDatasource;
@end

@implementation FMAlbumAddPhotosVC
{
    UIButton * _rightbtn;//导航栏右边按钮
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
    self.title = @"添加照片";
}

-(void)initData{
    self.choosePhotos = [NSMutableSet set];
    self.chooseSection = [NSMutableArray arrayWithCapacity:0];
    self.addArr = [NSMutableSet set];
    self.photoDatasource = [FMPhotoDataSource shareInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:FMPhotoDatasourceLoadFinishNotify object:nil];
    
    if (self.photoDatasource.isFinishLoading) {
        [self.collectionView reloadData];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)reloadData{
    [self.collectionView reloadData];
}

-(void)initView{
    self.collectionView = [[FMPhotoCollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.jy_Width, self.view.jy_Height-64)];
    self.collectionView.fmDelegate = self;
    [self.view addSubview:self.collectionView];
    self.collectionView.userIndicator = YES;
    self.collectionView.fmState = FMPhotosCollectionViewCellStateCanChoose;
    [self.collectionView registerNib:[UINib nibWithNibName:@"FMPhotosCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"photocell"];
    [self addBtns];
}


//添加 导航器右边按钮
-(void)addBtns{
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 48, 48)];
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont fontWithName:FANGZHENG size:16];
    rightBtn.titleLabel.textColor = UICOLOR_RGB(0xffffff);
    _rightbtn = rightBtn;
    UIBarButtonItem *negativeSpacer = [[ UIBarButtonItem alloc ]
                                       initWithBarButtonSystemItem : UIBarButtonSystemItemFixedSpace
                                       target : nil action : nil ];
    negativeSpacer. width = -8;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,[[UIBarButtonItem alloc]initWithCustomView:rightBtn]];
}

#pragma mark - handle

-(void)rightBtnClick:(id)sender{
    if (self.addSuccessblock) {
        self.addSuccessblock([self.addArr allObjects]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Util
/********************************************************************************************************/
/*************************************       Util      **************************************************/
/********************************************************************************************************/
//清楚所有选中的照片
-(void)removeAllSelectData{
    [self.chooseSection removeAllObjects];
    [self.choosePhotos removeAllObjects];
}

//是否为全选了整个区
-(BOOL)isSectionShouldSelect:(NSUInteger)section{
    NSArray *  items = [self.photoDatasource.dataSource objectAtIndex:section];
    BOOL isShouldSelect = YES;
    for (FMPhoto * photo in items) {
        if(![self.choosePhotos containsObject:photo]){
            if (![photo isKindOfClass:[FMNASPhoto class]] || [((FMNASPhoto *)photo).sharing boolValue]) {
                isShouldSelect = NO;
                break;
            }
        }
    }
    return isShouldSelect;
}

-(NSString *)getHashWithPhoto:(IDMPhoto *)photo{
    if (photo) {
        return [photo getPhotoHash];
    }
    return @"";
}
/********************************************************************************************************/
/*************************************     delegate    **************************************************/
/********************************************************************************************************/

#pragma mark - FMPhotoCollectionViewDelegate

-(UICollectionViewCell *)fm_CollectionView:(FMPhotoCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FMPhotosCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photocell" forIndexPath:indexPath];
    // 请求图片
    cell.fmDelegate = self;
    cell.state = collectionView.fmState;
    NSArray * datas = [self.photoDatasource.dataSource objectAtIndex:indexPath.section];
    id<IDMPhoto> asset = datas[indexPath.row];
    cell.asset = asset;
    if (collectionView.indicator) {
        collectionView.indicator.slider.timeLabel.text = [self getMouthDateStringWithPhoto:[asset getPhotoCreateTime]];
    }
    if ([self.choosePhotos containsObject:asset]||[self.addArr containsObject:asset]) {
        cell.isChoose = YES;
    }else{
        cell.isChoose = NO;
    }
    return cell;
}

-(NSInteger)fm_CollectionView:(FMPhotoCollectionView *)collectinView numberOfRowInSection:(NSUInteger)num{
    NSArray * datas = [self.photoDatasource.dataSource objectAtIndex:num];
    return datas.count;
}

-(NSInteger)fm_CollectionViewNumberOfSectionInView:(FMPhotoCollectionView *)collectinView{
    return self.photoDatasource.dataSource.count;
}

//headView
- (FMHeadView *)fm_CollectionView:(FMPhotoCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    FMHeadView * headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView" forIndexPath:indexPath];
    
    NSDate * date = [self.photoDatasource.timeArr objectAtIndex:indexPath.section];
    headView.headTitle = [NSDate getDateStringWithPhoto:date];
    headView.fmState = _collectionView.fmState;
    
    //判断该区是否选中状态
    BOOL isChooseSection = NO;
    for (NSIndexPath * inPath in self.chooseSection) {
        if (inPath.section == indexPath.section) {
            isChooseSection = YES;
            break;
        }
    }
    
    headView.isChoose = isChooseSection;
    headView.fmIndexPath = indexPath;
    headView.fmDelegate = self;
    
    return headView;
}

-(void)fm_CollectionView:(FMPhotoCollectionView *)collectinView didSelectedIndexPath:(NSIndexPath *)indexPath{
    FMPhotosCollectionViewCell *cell = (FMPhotosCollectionViewCell *)[collectinView cellForItemAtIndexPath:indexPath];
    //在数据源找到对象
    NSArray * datas = [self.photoDatasource.dataSource objectAtIndex:indexPath.section];
    id<IDMPhoto> photo = datas[indexPath.row];
    if(self.collectionView.fmState == FMPhotosCollectionViewCellStateCanChoose){
        
        if([photo isKindOfClass:[FMNASPhoto class]] && ![((FMNASPhoto *)photo).sharing boolValue]){
            [SXLoadingView showAlertHUD:@"非本人照片，不能操作" duration:0.5];
            return ;
        }
        
        //需要添加
        if (![self.choosePhotos containsObject:photo] && ![self.addArr containsObject:photo]) {
            [self.addArr addObject:photo];
            [cell setIsChoose:YES];
            //如果该组全选, 则全选section
            if ([self isSectionShouldSelect:indexPath.section]) {
                NSIndexPath * inxPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
                [self.chooseSection addObject:inxPath];
                [self.collectionView reloadData];
            }
        }
        else{
            //刚已添加
            if(![self.choosePhotos containsObject:photo] && [self.addArr containsObject:photo]){
                [self.addArr removeObject:photo];
                [cell setIsChoose:NO];
                
                //如果该组是全选状态 则取消全选状态
                for (NSIndexPath * inPath in self.chooseSection) {
                    if (inPath.section == indexPath.section) {
                        [self.chooseSection removeObject:inPath];
                        [self.collectionView reloadData];
                        break;
                    }
                }
            }else
                [SXLoadingView showAlertHUD:@"不可操作的图片" duration:0.5];
        }
    }
}



#pragma mark - FMHeadViewDelegate

//选择了全选整个区的按钮
- (void)FMHeadView:(FMHeadView *)headView isChooseBtn:(BOOL)isChoose{
    NSLog(@"选择了 第 %ld 区",(long)headView.fmIndexPath.section);
    NSUInteger section = headView.fmIndexPath.section;
    NSArray * items = [self.photoDatasource.dataSource objectAtIndex:section];
    if (isChoose) {
        int i = 0;
        //添加选中该区所有图片
        for (id photo in items) {
            
            if ([self.photoDatasource.netphotoArr containsObject:photo]) {
                FMNASPhoto * p = (FMNASPhoto *)photo;
                if (![p.sharing boolValue]) {
                    continue;
                }
            }
            
            if (![self.choosePhotos containsObject:photo]) {
                [self.addArr addObjectsFromArray:items];
                i++;
            }
        }
        if (i>0) {
            [self.chooseSection addObject:headView.fmIndexPath];
        }
    }else{
        [self.chooseSection removeObject:headView.fmIndexPath];
        //删除选中该区所有照片
        for (id<IDMPhoto> photo in items) {
            [self.addArr removeObject:photo];
        }
    }
    [self.collectionView reloadData];
}


#pragma mark - FMPhotosCollectionViewCellDelegate
//点击了选择按钮
-(void)FMPhotosCollectionViewCellDidChoose:(FMPhotosCollectionViewCell *)cell{
    NSLog(@"选择了这张图");
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    [self fm_CollectionView:self.collectionView didSelectedIndexPath:indexPath];
    
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
    //    NSDate *date = [photo getPhotoCreateTime];
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy-MM-dd";
    NSString * dateString = [formatter1 stringFromDate:date];
    return dateString;
}

-(NSString *)getMouthDateStringWithPhoto:(NSDate *)date{
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy年MM月";
    NSString * dateString = [formatter1 stringFromDate:date];
    //    NSLog(@"%@",dateString);
    if (IsEquallString(dateString, @"1970年01月")) {
        dateString = @"未知时间";
    }
    return dateString;
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    for (NSArray * arr in self.photoDatasource.dataSource) {
        for (id<IDMPhoto> photo in arr) {
            [photo unloadUnderlyingImage];
        }
    }
}


@end
