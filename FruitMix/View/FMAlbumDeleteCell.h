//
//  FMAlbumDeleteCell.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/6.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FMAlbumDeleteCell;
@protocol FMAlbumDeleteCellDetegate <NSObject>

-(void)albumDeleteCell:(FMAlbumDeleteCell *)cell didSelectDeleteBtn:(UIButton *)btn;

@end

@interface FMAlbumDeleteCell : UICollectionViewCell

@property (nonatomic) id<FMAlbumDeleteCellDetegate> fm_delegate;

@property (weak, nonatomic) IBOutlet UIImageView *albumImage;

@property (nonatomic) NSString * imageTag;


@end
