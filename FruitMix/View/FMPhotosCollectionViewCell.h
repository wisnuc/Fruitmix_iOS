//
//  FMPhotosCollectionViewCell.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/5.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMGetImage.h"
#import "IDMPhotoProtocol.h"

typedef enum : NSUInteger {
    FMPhotosCollectionViewCellStateCanChoose = 0,
    FMPhotosCollectionViewCellStateNormal,
} FMPhotosCollectionViewCellState;

@class FMPhotosCollectionViewCell;
@protocol FMPhotosCollectionViewCellDelegate <NSObject>

@optional
//点击了选择按钮
-(void)FMPhotosCollectionViewCellDidChoose:(FMPhotosCollectionViewCell *)cell;
//响应了长按手势
-(void)FMPhotosCollectionViewCellDidLongPress:(FMPhotosCollectionViewCell *)cell;

@end

@interface FMPhotosCollectionViewCell : UICollectionViewCell

@property (nonatomic , weak) id<FMPhotosCollectionViewCellDelegate> fmDelegate;

@property (weak, nonatomic) IBOutlet UIImageView *fmPhotoImageView;

@property (nonatomic) NSString * imageTag;

@property (nonatomic) FMPhotosCollectionViewCellState state;
@property (weak, nonatomic) IBOutlet UIImageView *maskLayer;
@property (weak, nonatomic) IBOutlet UIButton *lockBtn;

@property (nonatomic) BOOL isChoose;

@property (nonatomic ,weak) id<IDMPhoto> asset;

-(void)setChooseWithAnimation:(BOOL)isChoose;

@end
