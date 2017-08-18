//
//  UIButton+Universal.m
//  FruitMix
//
//  Created by wisnuc on 2017/8/15.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "UIButton+Universal.h"

@implementation UIButton (Universal)
+ (UIButton* _Nullable)buttionWithTitle:(NSString *_Nullable)title target:(nullable id)target action:(nonnull SEL)action{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, JYSCREEN_HEIGHT - 16 - 36,JYSCREEN_WIDTH - 16*2 , 36)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = COR1;
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 2;
    button.layer.shadowOffset =  CGSizeMake(1, 1);
    button.layer.shadowOpacity = 0.8;
    button.layer.shadowColor =  [UIColor blackColor].CGColor;
    return button;
}
@end
