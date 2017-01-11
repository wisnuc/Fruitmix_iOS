//
//  FMShareSetItem.m
//  FruitMix
//
//  Created by 杨勇 on 16/5/3.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMShareSetItem.h"
#import "FMShareSetCell.h"
#import "FMGetThumbImage.h"

@interface FMShareSetItem ()<UICollectionViewDelegate,UICollectionViewDataSource>

@end

@implementation FMShareSetItem{
    UICollectionViewFlowLayout * _fmCollectionViewLayout;
    NSInteger _multiple;//每行几个元素
    NSInteger _currentScale;//缩放比例
}
-(instancetype)initWithFrame:(CGRect)frame{
    _multiple = 3;
    _currentScale = 1;//初始化缩放比例为 1
    _fmCollectionViewLayout = [[UICollectionViewFlowLayout alloc]init];
    _fmCollectionViewLayout.scrollDirection=UICollectionViewScrollDirectionVertical;
    _fmCollectionViewLayout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);
    _fmCollectionViewLayout.minimumLineSpacing = 3;
    if(IOS9){
        _fmCollectionViewLayout.sectionHeadersPinToVisibleBounds = YES;
    }
    _fmCollectionViewLayout.minimumInteritemSpacing = 3;
    _fmCollectionViewLayout.itemSize = CGSizeMake((frame.size.width- 2*(_multiple-1)-10)/_multiple , (frame.size.width- 2*(_multiple-1)- 10)/_multiple );
    if(self = [super initWithFrame:frame collectionViewLayout:_fmCollectionViewLayout]){
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.backgroundColor = [UIColor whiteColor];
        self.scrollEnabled = NO;
        [self setDataSource:self];
        [self setDelegate:self];
    }
    
    [self registerNib:[UINib nibWithNibName:@"FMShareSetCell" bundle:nil] forCellWithReuseIdentifier:@"shareSet"];
    return self;
}

-(void)setShare:(id<FMMediaShareProtocol>)share{
    _share = share;
    [self reloadData];
}

#pragma mark - UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.fmDelegate) {
        [self.fmDelegate fmSet_collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}

#pragma mark -
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.share.getAllContents.count>9) {
        return 9;
    }
    return self.share.getAllContents.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FMShareSetCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"shareSet" forIndexPath:indexPath];
    
    NSArray * contentsArr = self.share.getAllContents;
    NSString * digest = ((FMShareAlbumItem *)contentsArr[indexPath.row]).digest;
    cell.imgTag = digest;
    [FMGetThumbImage getThumbImageWithAsset:(FMShareAlbumItem *)contentsArr[indexPath.row] andCompleteBlock:^(UIImage *image, NSString *tag) {
        if (IsEquallString(cell.imgTag, tag)) {
            cell.setImage.image = image;
        }
    }];
//    [FMGetThumbImage getThumbImageWithPhotoHash:digest andCompleteBlock:^(UIImage *image, NSString *tag) {
//        if (IsEquallString(cell.imgTag, tag)) {
//            cell.setImage.image = image;
//        }
//    }];

    return cell;
}

+(NSInteger)getHeightWithModel:(id<FMMediaShareProtocol>)model{
    NSInteger i = model.getAllContents.count/3;
    NSInteger j = model.getAllContents.count%3;
    NSInteger l = i > 3 ? 3:i;
    if (j>0 && l<3) {
        l= l+1;
    }
    return ((__kWidth- 6)/3)* l + 10;
}

- (UIView *)photoBrowser:(IDMPhotoBrowser *)photoBrowser needAnimationViewWillDismissAtPageIndex:(NSUInteger)index{
    NSInteger  sections = [self numberOfSections];
    NSInteger _index = index;
    NSIndexPath * indexPath = nil;
    for (int i = 0; i<sections; i++) {
        NSInteger j = [self numberOfItemsInSection:i];
        if( j < (_index+1)){
            _index -= j;
        }
        else{
            indexPath = [NSIndexPath indexPathForRow:_index inSection:i];
            break;
        }
    }
    UICollectionViewCell * cell = nil;
    if (indexPath.row>8) {
        indexPath = [NSIndexPath indexPathForRow:8 inSection:0];
    }
    if (indexPath) {
        cell = [self cellForItemAtIndexPath:indexPath];
        if (cell) {
            return cell;
        }else{
            [self scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            [self layoutIfNeeded];
            cell = [self cellForItemAtIndexPath:indexPath];
            if (cell) {
                return cell;
            }
        }
    }
    return nil;
}

@end
