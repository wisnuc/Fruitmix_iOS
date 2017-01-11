//
//  FMShareHeadView.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMShareHeadView.h"

@implementation FMShareHeadView

+(FMShareHeadView *)fmHeadViewWithModel:(id<FMMediaShareProtocol>)model{
    FMShareHeadView * headView = [[FMShareHeadView alloc]initWithFrame:CGRectMake(FMPadding/2, 25/2, __kWidth - FMPadding, 97/2)];
    headView.userHeadView = [[UIImageView alloc]initWithFrame:CGRectMake(15/2, 27/4, 35, 35)];
    headView.userHeadView.image = [UIImage imageNamed:@"head-portrait"];
    [headView addSubview:headView.userHeadView];
    
    headView.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 10, 100, 18)];
    headView.nameLabel.font = [UIFont fontWithName:Helvetica size:15];
    headView.nameLabel.textColor = UICOLOR_RGB(0x2a3442);
    headView.nameLabel.text = @"未知";
    [headView addSubview:headView.nameLabel];
    
    headView.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, headView.nameLabel.jy_Bottom, __kWidth - 50, 15)];
    headView.timeLabel.font = [UIFont fontWithName:DONGQING size:10];
    headView.timeLabel.textColor = UICOLOR_RGB(0x999999);
    headView.timeLabel.text = @"未知";
    [headView addSubview:headView.timeLabel];
    
    return headView;
}

@end
