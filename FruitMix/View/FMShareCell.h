//
//  FMShareCell.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FMShareHeadView.h"
#import "FMShareLikeView.h"
#import "FMShareTalkView.h"

@class FMShareCell;
@protocol FMShareCellDelegate <NSObject>

@optional
-(void)shareCell:(UITableViewCell *)cell didSelectLikeBtn:(UIButton *)btn;
-(void)shareCell:(UITableViewCell *)cell didSelectTalkBtn:(UIButton *)btn;
@required
-(CGSize)shareCellGetImageSize:(UITableViewCell *)cell;

//仅仅适用于 setImages
-(void)fm_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface FMShareCell : UITableViewCell

@property (nonatomic) id<FMShareCellDelegate> delegate;

@property (nonatomic) FMShareLikeView * likeView;

@property (nonatomic) FMShareTalkView * talkView;

@property (nonatomic) FMShareHeadView * headView;

@property (nonatomic) UIImageView * shareImage;

@property (nonatomic) UIView * shareContentView;

@property (nonatomic) id<FMMediaShareProtocol> model;


+(CGFloat)getHeightWithModel:(id<FMMediaShareProtocol>)model;

@end
