//
//  FMShareLikeView.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//



#import <UIKit/UIKit.h>

@interface FMShareLikeView : UIView

/**
 *  聊天按钮
 */
@property (nonatomic) UIButton * talkBtn;

/**
 *  聊天数目
 */
@property (nonatomic) UILabel * talkNumLb;

/**
 *  点赞按钮
 */
@property (nonatomic) UIButton * likeBtn;

/**
 *  喜欢数目
 */
@property (nonatomic) UILabel * likeNumLb;

+(FMShareLikeView *)fmShareLikeViewWithModel:(id<FMMediaShareProtocol>)model andFrame:(CGRect)rect;

//+(CGFloat)getHeightWithModel:(FMShareModel *)model;
@end
