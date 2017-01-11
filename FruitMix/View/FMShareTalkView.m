//
//  FMShareTalkView.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMShareTalkView.h"

@implementation FMShareTalkView

+(FMShareTalkView *)fmShareTalkViewWithModel:(id<FMMediaShareProtocol>)model andBeginPoint:(CGPoint)point{
    FMShareTalkView * talkView = [[FMShareTalkView alloc]initWithFrame:CGRectMake(point.x, point.y, __kWidth - FMPadding, 40)];
    
    talkView.clipsToBounds = YES;
    
    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 1, talkView.jy_Width, 0.5)];
    lineView.backgroundColor = UICOLOR_RGB(0xe0e0e0);
    [talkView addSubview:lineView];
    
//    talkView.likeIV = [[UIImageView alloc]initWithFrame:CGRectMake(33/2, 15, 15, 14)];
//    talkView.likeIV.image = [UIImage imageNamed:@"good_red"];
//    [talkView addSubview:talkView.likeIV];
    
//    talkView.likePersonLb = [[UILabel alloc]initWithFrame:CGRectMake(talkView.likeIV.jy_Right+25/2, 15, talkView.jy_Width - 44, 14)];
//    talkView.likePersonLb.font = [UIFont fontWithName:DONGQING size:15];
//    talkView.likePersonLb.textColor = UICOLOR_RGB(0xe8643b);
//    talkView.likePersonLb.text = @"";
//    [talkView addSubview:talkView.likePersonLb];
    
//    UIView * lineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, talkView.likePersonLb.jy_Bottom + 13, talkView.jy_Width, 0.5)];
//    lineView2.backgroundColor = UICOLOR_RGB(0xe0e0e0);
//    [talkView addSubview:lineView2];
    talkView.commentView = [[FMShareScrollComment alloc]initWithFrame:CGRectMake(33/2, 5, talkView.jy_Width - 33/2, 20)];
    [talkView addSubview:talkView.commentView];
       
//    UIButton * more = [[UIButton alloc]initWithFrame:CGRectMake(talkView.likeIV.jy_Left, talkView.commentView.jy_Bottom+13, 80, 20)];
//    [more setTitle:@"共105条评论 ^" forState:UIControlStateNormal];
//    [more setTitleColor:UICOLOR_RGB(0x999999) forState:UIControlStateNormal];
//    more.titleLabel.font = [UIFont fontWithName:DONGQING size:11];
//    more.titleLabel.textAlignment = NSTextAlignmentLeft;
//    [talkView addSubview:more];
    return talkView;
}

+(CGFloat)getHeightWithModel:(id<FMMediaShareProtocol>)model{
    return 40;
}
@end
