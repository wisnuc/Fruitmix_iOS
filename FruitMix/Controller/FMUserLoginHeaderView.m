
//
//  FMUserLoginHeaderView.m
//  FruitMix
//
//  Created by JackYang on 2017/2/24.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMUserLoginHeaderView.h"

@implementation FMUserLoginHeaderView{
    UILabel * _NameLb;
    UILabel * _SNLb;
}

+(FMUserLoginHeaderView *)headerViewWithDeviceName:(NSString *)name DeviceSN:(NSString *)sn{
    FMUserLoginHeaderView * view = [[FMUserLoginHeaderView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, 64)];
    [view setUpViewsWithName:name DeviceSN:sn];
    return view;
}

-(void)setUpViewsWithName:(NSString *)name DeviceSN:(NSString *)sn{
    _NameLb = [[UILabel alloc]initWithFrame:CGRectMake(16, 17, __kWidth - 32, 15)];
    _NameLb.font = [UIFont systemFontOfSize:14];
    _NameLb.textColor = UICOLOR_RGB(0x000);
    _NameLb.alpha = 0.54;
    _NameLb.text = name;
    [self addSubview:_NameLb];
    
    
    _SNLb = [[UILabel alloc]initWithFrame:CGRectMake(16, 40, __kWidth-32, 15)];
    _SNLb.font = [UIFont systemFontOfSize:14];
    _SNLb.textColor = UICOLOR_RGB(0x000);
    _SNLb.alpha = 0.54;
    _SNLb.text = sn;
    [self addSubview:_SNLb];
    
    
}

@end
