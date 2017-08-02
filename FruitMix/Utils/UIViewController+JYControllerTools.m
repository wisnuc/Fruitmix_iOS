//
//  UIViewController+JYControllerTools.m
//  FruitMix
//
//  Created by 杨勇 on 16/7/4.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "UIViewController+JYControllerTools.h"

@implementation UIViewController (JYControllerTools)

-(void)addLeftBarButtonWithImage:(UIImage *)buttonImage andHighlightButtonImage:(UIImage *)image  andSEL:(SEL)sel{
    UIButton * left = [[UIButton alloc]initWithFrame:CGRectMake(0, 10, 40, 20)];
    [left setImage:buttonImage forState:UIControlStateNormal];
    if (image) {
        [left setImage:image forState:UIControlStateHighlighted];
    }
    [left addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:left];
    self.navigationItem.leftBarButtonItem = leftButton;
}

@end
