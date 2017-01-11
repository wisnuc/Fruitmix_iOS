//
//  FMShareLikeView.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMShareLikeView.h"

@implementation FMShareLikeView

+(FMShareLikeView *)fmShareLikeViewWithModel:(id<FMMediaShareProtocol>)model andFrame:(CGRect)rect{
    FMShareLikeView * view = [[FMShareLikeView alloc]initWithFrame:rect];
    
//    view.likeNumLb = [[UILabel alloc]initWithFrame:CGRectMake(view.jy_Width - 20 - 35/2, (view.jy_Height - 14)/2, 30, 14)];
//    view.likeNumLb.font = [UIFont fontWithName:DONGQING size:13];
//    view.likeNumLb.textColor = UICOLOR_RGB(0xe8643b);
//    view.likeNumLb.text = @"0";
//    [view addSubview:view.likeNumLb];
//    
//    view.likeBtn = [[UIButton alloc]initWithFrame:CGRectMake(view.likeNumLb.jy_Left - 54/2, (view.jy_Height - 14)/2 - 3, 45/2, 45/2)];
//    [view.likeBtn setImage:[UIImage imageNamed:@"praise_share"] forState:UIControlStateNormal];
//    [view addSubview:view.likeBtn];
    
//    UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(view.likeBtn.jy_Left - 53/2, view.likeBtn.jy_Top, 1, view.likeBtn.jy_Height)];
//    lineView.backgroundColor = [UIColor lightGrayColor];
//    [view addSubview:lineView];
    
//    view.talkNumLb = [[UILabel alloc]initWithFrame:CGRectMake(lineView.jy_Left-35/2-20, lineView.jy_Top, 30, lineView.jy_Height)];
//    view.talkNumLb.textColor = UICOLOR_RGB(0x999999);
//    view.talkNumLb.font = [UIFont fontWithName:DONGQING size:13];
//    view.talkNumLb.text = @"0";
//    [view  addSubview:view.talkNumLb];
//    
//    view.talkBtn = [[UIButton alloc]initWithFrame:CGRectMake(view.talkNumLb.jy_Left-23/2-45/2, (view.jy_Height - 14)/2 - 3, 45/2, 45/2)];
//    [view.talkBtn setImage:[UIImage imageNamed:@"comment_share"] forState:UIControlStateNormal];
//    [view addSubview:view.talkBtn];
    
    view.talkNumLb = [[UILabel alloc]initWithFrame:CGRectMake(view.jy_Width - 20 - 35/2, (view.jy_Height - 14)/2, 30, 14)];
    view.talkNumLb.textColor = UICOLOR_RGB(0x999999);
    view.talkNumLb.font = [UIFont fontWithName:DONGQING size:13];
    view.talkNumLb.text = @"0";
    [view  addSubview:view.talkNumLb];
    
    view.talkBtn = [[UIButton alloc]initWithFrame:CGRectMake(view.talkNumLb.jy_Left-23/2-45/2, (view.jy_Height - 14)/2 - 3, 45/2, 45/2)];
    [view.talkBtn setImage:[UIImage imageNamed:@"comment_share"] forState:UIControlStateNormal];
    [view addSubview:view.talkBtn];
    
    return view;
}

//+(CGFloat)getHeightWithModel:(FMShareModel *)model{
//    @autoreleasepool {
//        FMShareLikeView * likeView = [FMShareLikeView fmShareLikeViewWithModel:model andFrame:<#(CGRect)#>]
//    }
//    
//}

@end
