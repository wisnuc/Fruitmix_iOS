//
//  FMLeftUserFooterView.m
//  FruitMix
//
//  Created by JackYang on 2017/2/20.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMLeftUserFooterView.h"

@implementation FMLeftUserFooterView{
    UILabel * _label;
}

+(FMLeftUserFooterView *)footerViewWithTouchBlock:(void(^)())block{
    FMLeftUserFooterView * view = [[FMLeftUserFooterView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, 64)];
    
    view.touchBlock = block;
    return view;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _label = [[UILabel alloc]initWithFrame:CGRectMake(72, 20, 200, 20)];
    [self addSubview:_label];
    _label.text = @"用户登录设置";
    _label.font = [UIFont systemFontOfSize:14];
    _label.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.54];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_touchBlock) {
        _touchBlock();
    }
}

@end
