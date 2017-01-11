//
//  FMShareAlbumCell.h
//  FruitMix
//
//  Created by 杨勇 on 16/5/3.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMShareHeadView.h"
#import "FMShareLikeView.h"
#import "FMShareCell.h"

@interface FMShareAlbumCell : UITableViewCell

@property (nonatomic) id<FMShareCellDelegate> delegate;

@property (nonatomic) FMShareLikeView * likeView;

@property (nonatomic) FMShareHeadView * headView;

@property (nonatomic) UIImageView * shareImage;

@property (nonatomic) UIView * shareContentView;
@property (nonatomic) id<FMMediaShareProtocol> model;

@property (nonatomic) UILabel * nameAndCountLb;

+(CGFloat)getHeightWithModel:(id<FMMediaShareProtocol>)model;
@end
