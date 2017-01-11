//
//  UIView+JYExtension.h
//  FruitMix
//
//  Created by 杨勇 on 16/3/31.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, JYGravity){
    JYGravityNone = 0,
    JYGravityTop = 1 << 0,
    JYGravityBottom = 1 << 1,
    JYGravityLeft = 1 << 2,
    JYGravityRight = 1 << 3,
    JYGravityCenterHorizontal = 1 << 4,
    JYGravityCenterVertical = 1 << 5,
};

@interface UIView (JYExtension)

@property(nonatomic) CGFloat jy_Width;
@property(nonatomic) CGFloat jy_Height;

@property(nonatomic) CGFloat jy_Top;
@property(nonatomic) CGFloat jy_Left;
@property(nonatomic) CGFloat jy_Bottom;
@property(nonatomic) CGFloat jy_Right;

@property(nonatomic) CGFloat jy_CenterX;
@property(nonatomic) CGFloat jy_CenterY;
@property(nonatomic) CGPoint jy_Center;

@property(nonatomic) CGSize jy_Size;

@end
