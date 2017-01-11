//
//  FMPhotoCollectionView.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/5.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMPhotoCollectionView.h"
#import "UIScrollView+IndicatorExt.h"
#import "FMUtil.h"
#import "TYDecorationSectionLayout.h"
#import "FMGetThumbImage.h"

int const i = 2;//cell 距离

@interface FMPhotoCollectionView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>

@end


//@interface FMGetImage ()
//-(void)getThumbImageWithHash:(NSString *)hash
//                    andCount:(NSInteger)count
//               andPressBlock:(SDWebImageDownloaderProgressBlock)progress
//             andCompletBlock:(getImageComplete)block
//                    andQueue:(dispatch_queue_t)queue;
//-(void)getThumbImageWithLocalPhotoHash:(NSString *)hash
//                      andCompleteBlock:(getImageComplete)block
//                              andQueue:(dispatch_queue_t)queue;
//@end


@implementation FMPhotoCollectionView{
    TYDecorationSectionLayout * _fmCollectionViewLayout;
    NSInteger _multiple;//每行几个元素
    NSInteger _currentScale;//缩放比例
}

-(instancetype)initWithFrame:(CGRect)frame{
    _multiple = 3;
    _currentScale = 1;//初始化缩放比例为 1
    _fmCollectionViewLayout = [[TYDecorationSectionLayout alloc]init];
    //layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _fmCollectionViewLayout.alternateDecorationViews = YES;
    // costom xib names
    _fmCollectionViewLayout.decorationViewOfKinds = @[@"FirstDecorationSectionView"];
    _fmCollectionViewLayout.scrollDirection=UICollectionViewScrollDirectionVertical;
    _fmCollectionViewLayout.sectionInset = UIEdgeInsetsMake(0, 0, 20, 0);
    _fmCollectionViewLayout.minimumLineSpacing = i;
//    if(kSystemVersion >= 9.0){
//        _fmCollectionViewLayout.sectionHeadersPinToVisibleBounds = YES;
//    }
    _fmCollectionViewLayout.minimumInteritemSpacing = i;
    _fmCollectionViewLayout.itemSize = CGSizeMake((__kWidth- i*(_multiple-1))/_multiple, (__kWidth- i*(_multiple-1))/_multiple);
    if(self = [super initWithFrame:frame collectionViewLayout:_fmCollectionViewLayout]){
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.backgroundColor = UICOLOR_RGB(0xe2e2e2);
        [self setDataSource:self];
        [self setDelegate:self];
        self.fmState = FMPhotosCollectionViewCellStateNormal;//默认状态
        [self registerClass:[FMHeadView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView"];
        
    }
    return self;
}

//重写set方法
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    if (self.indicator) {
        self.indicator.frame = CGRectMake(self.indicator.frame.origin.x, self.indicator.frame.origin.y, frame.size.width, CGRectGetHeight(frame) - 2 * kILSDefaultSliderMargin);
    }
}

-(void)changeFlowLayoutIsBeSmall:(BOOL)isSmall{
    if (!isSmall && _multiple == 1) {
        return;
    }
    if(
       isSmall && _multiple == 6){
        return;
    }
    TYDecorationSectionLayout *layout = [[TYDecorationSectionLayout alloc]init];
    //layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.alternateDecorationViews = YES;
    // costom xib names
    layout.decorationViewOfKinds = @[@"FirstDecorationSectionView"];
    layout.scrollDirection=UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 20, 0);
    layout.minimumLineSpacing = i;
    layout.minimumInteritemSpacing = i;
//    if(kSystemVersion >= 9.0){
//        layout.sectionHeadersPinToVisibleBounds = YES;
//    }
    if (isSmall) {
        _multiple = _multiple + 1;
    }
    else{
        _multiple = _multiple - 1;
    }
    NSLog(@"%ld",(long)_multiple);
    layout.itemSize = CGSizeMake((__kWidth- i*(_multiple-1))/_multiple, (__kWidth- i*(_multiple-1))/_multiple);
    [self setCollectionViewLayout:layout animated:YES];
}

#pragma mark - UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.fmDelegate){
        if ([self.fmDelegate respondsToSelector:@selector(fm_CollectionView:didSelectedIndexPath:)]) {
            [self.fmDelegate fm_CollectionView:self didSelectedIndexPath:indexPath];
        }
    }
}

#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(self.fmDelegate){
        if ([self.fmDelegate respondsToSelector:@selector(fm_CollectionView:numberOfRowInSection:)]) {
            return [self.fmDelegate fm_CollectionView:self numberOfRowInSection:section];
        }
        return 0;
    }
    return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self.fmDelegate fm_CollectionView:self cellForItemAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if(self.fmDelegate){
        if ([self.fmDelegate respondsToSelector:@selector(fm_CollectionViewNumberOfSectionInView:)]) {
            return [self.fmDelegate fm_CollectionViewNumberOfSectionInView:self];
        }
        return 1;
    }
    return 1;
}

//head的高度
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size={__kWidth,42};
    return size;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath

{
        return [self.fmDelegate fm_CollectionView:self viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
}

-(void)animationForItems{
    CGFloat viewHeight = self.bounds.size.height + self.contentInset.top;
    for (UICollectionViewCell *cell in [self visibleCells]) {
        CGFloat y = cell.jy_CenterY - self.contentOffset.y;
        CGFloat p = y - viewHeight / 2;
        CGFloat scale = cos(p / viewHeight * 0.9) * 0.95;
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
            [(FMPhotosCollectionViewCell *)cell fmPhotoImageView].transform = CGAffineTransformMakeScale(scale, scale);
        } completion:NULL];
    }
}

bool isAnimation = NO;
bool isDecelerating = NO;

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    isDecelerating = YES;
    
    if (self.userIndicator) {
        if (!self.indicator) {
            //导航按钮
            [self registerILSIndicator];
            [self.indicator.slider addObserver:self forKeyPath:@"sliderState" options:0x01 context:nil];
        }else {
            if (!isAnimation) {
                self.indicator.transform = CGAffineTransformIdentity;
            }else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.indicator.transform = CGAffineTransformIdentity;
                });
            }
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self hiddenIndicator];
}

-(void)hiddenIndicator{
    if (self.userIndicator) {
        if (self.indicator.slider.sliderState == UIControlStateNormal && CGAffineTransformIsIdentity(self.indicator.transform)) {
            isDecelerating = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(!isDecelerating){
                    isAnimation = YES;
                    [UIView animateWithDuration:0.5 animations:^{
                        self.indicator.transform = CGAffineTransformMakeTranslation(40, 0);
                    }completion:^(BOOL finished) {
                        isAnimation = NO;
                        isDecelerating = NO;
                    }];
                    
                }
            });
            
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate){
        [self hiddenIndicator];
    }
}

//加速加载cell的图片
//-(void)quckToLoadCellsImage{
//    for (UICollectionViewCell * cell in self.visibleCells) {
//        if ([cell isKindOfClass:[FMPhotosCollectionViewCell class]]) {
//            FMPhotosCollectionViewCell * tempCell = (FMPhotosCollectionViewCell *)cell;
//            if ([tempCell.asset getThumbImage]) {
//                tempCell.fmPhotoImageView.image = [tempCell.asset getThumbImage];
//            }else{
//                tempCell.fmPhotoImageView.image = [UIImage imageNamed:@"photo_placeholder"];
//                if (![tempCell.asset getPhotoHash] && [tempCell.asset isKindOfClass:[FMPhotoAsset class]]) {//没有 digest
//                    FMPhotoAsset * pA = (FMPhotoAsset *)tempCell.asset;
//                    tempCell.imageTag = pA.localId;
//                    [[FMGetThumbImage defaultGetThumbImage] getLocalThumbWithLocalId:pA.localId andCompleteBlock:^(UIImage *image, NSString *tag) {
//                        [pA setThumbImage:image];
//                        if ([tempCell.imageTag isEqualToString:tag]) {
//                            //主线程 刷新 防止卡顿
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                tempCell.fmPhotoImageView.image = image;
//                            });
//                        }
//                    } andQueue:[FMUtil setterHighQueue]];
//                }else{ //有 digest
//                    [FMGetThumbImage getThumbImageQuickWithPhotohash:[tempCell.asset getPhotoHash] andCompleteBlock:^(UIImage *image, NSString *tag) {
//                        [tempCell.asset setThumbImage:image];
//                        if ([tempCell.imageTag isEqualToString:tag]) {
//                            //主线程 刷新 防止卡顿
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                tempCell.fmPhotoImageView.image = image;
//                            });
//                        }
//                    }];
//                }
//            }
//        }
//    }
//}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
//    [self quckToLoadCellsImage];
    
    [self hiddenIndicator];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (self.userIndicator) {
        if (IsEquallString(keyPath, @"sliderState")) {
            //加速加载
//            [self quckToLoadCellsImage];
            if (self.indicator.slider.sliderState == UIControlStateNormal && CGAffineTransformIsIdentity(self.indicator.transform)) {
                //延时一秒缩回
                isDecelerating = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if(!isDecelerating){
                        isAnimation = YES;
                        [UIView animateWithDuration:0.5 animations:^{
                            self.indicator.transform = CGAffineTransformMakeTranslation(40, 0);
                        }completion:^(BOOL finished) {
                            isAnimation = NO;
                            isDecelerating = NO;
                        }];
                    }
                });
            }else{
                isDecelerating = YES;
            }
                    
        }
    }
}

-(void)dealloc{
    if (self.indicator) {
        [self.indicator.slider removeObserver:self forKeyPath:@"sliderState"];
        [self removeObserver:self.indicator forKeyPath:@"contentOffset"];
    }
}
@end
