//
//  FMPhotoCollectionView.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/5.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMPhotosCollectionViewCell.h"
#import "FMHeadView.h"

@class FMPhotoCollectionView;
@protocol FMPhotoCollectionViewDelegate <NSObject>
@required
-(UICollectionViewCell *)fm_CollectionView:(FMPhotoCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

-(NSInteger)fm_CollectionView:(FMPhotoCollectionView *)collectinView numberOfRowInSection:(NSUInteger)num;

//返回一个section的headView
- (FMHeadView *)fm_CollectionView:(FMPhotoCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
@optional

-(NSInteger)fm_CollectionViewNumberOfSectionInView:(FMPhotoCollectionView *)collectinView;

-(void)fm_CollectionView:(FMPhotoCollectionView *)collectinView didSelectedIndexPath:(NSIndexPath *)indexPath;



@end


@interface FMPhotoCollectionView : UICollectionView

@property (nonatomic,weak) id<FMPhotoCollectionViewDelegate> fmDelegate;

@property (nonatomic) FMPhotosCollectionViewCellState fmState;

@property (nonatomic) NSArray * fmDataSource;

@property (nonatomic) BOOL userIndicator;

-(void)changeFlowLayoutIsBeSmall:(BOOL)isSmall;
@end
