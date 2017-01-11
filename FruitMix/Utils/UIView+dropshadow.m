//
//  UIView+dropshadow.m
//  FruitMix
//
//  Created by 杨勇 on 16/11/16.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "UIView+dropshadow.h"

@implementation UIView (dropshadow)

- (void)dropShadowWithOffset:(CGSize)offset
                      radius:(CGFloat)radius
                       color:(UIColor *)color
                     opacity:(CGFloat)opacity {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    CGFloat cornerRadius = self.layer.cornerRadius;
    UIBezierPath *bezier;
    if (cornerRadius) {
        bezier = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:cornerRadius];
    } else {
        bezier = [UIBezierPath bezierPathWithRect:self.bounds];
    }
    CGPathAddPath(path, NULL, bezier.CGPath);
    [self.layer setShadowPath:path];
    CGPathCloseSubpath(path);
    self.layer.shadowPath = path;
    CGPathCloseSubpath(path);
    CGPathRelease(path);
    
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = opacity;
    // Default clipsToBounds is YES, will clip off the shadow, so we disable it.
    self.clipsToBounds = NO;
    
}

@end
