//
//  FMShareTalkView.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FMShareScrollComment.h"

@interface FMShareTalkView : UIView

//喜欢按钮
@property (nonatomic) UIImageView * likeIV;
//点击喜欢的人
@property (nonatomic) UILabel * likePersonLb;

@property (nonatomic) FMShareScrollComment * commentView;

+(FMShareTalkView *)fmShareTalkViewWithModel:(id<FMMediaShareProtocol>)model andBeginPoint:(CGPoint)point;

+(CGFloat)getHeightWithModel:(id<FMMediaShareProtocol>)model;

@end
