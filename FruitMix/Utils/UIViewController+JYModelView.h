//
//  UIViewController+JYModelView.h
//  FruitMix
//
//  Created by JackYang on 16/3/22.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kJYModelAnimationDuration 0.5

typedef void(^CompleteBlock)(void);

@interface UIViewController (JYModelView)
-(void)present_JYViewController:(UIViewController*)vc;
-(void)present_JYView:(UIView *)view;
-(void)dismiss_JYView;
-(void)dismiss_JYViewWithCompleteBlock:(CompleteBlock)block;
@end