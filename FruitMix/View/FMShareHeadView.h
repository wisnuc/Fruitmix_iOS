//
//  FMShareHeadView.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMShareHeadView : UIView
/**
 *  头像
 */
@property (nonatomic) UIImageView * userHeadView;
/**
 *  用户名
 */
@property (nonatomic) UILabel * nameLabel;
/**
 *  发布时间
 */
@property (nonatomic) UILabel * timeLabel;

@property (nonatomic) id<FMMediaShareProtocol> model;

/**
 *  通过model 生成headview
 */

+(FMShareHeadView *)fmHeadViewWithModel:(id<FMMediaShareProtocol>)model;

@end
