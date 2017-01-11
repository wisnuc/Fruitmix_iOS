//
//  UIView+dropshadow.h
//  FruitMix
//
//  Created by 杨勇 on 16/11/16.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (dropshadow)


- (void)dropShadowWithOffset:(CGSize)offset
                      radius:(CGFloat)radius
                       color:(UIColor *)color
                     opacity:(CGFloat)opacity;

@end
