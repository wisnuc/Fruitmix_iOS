//
//  UIView+JYExtension.m
//  FruitMix
//
//  Created by 杨勇 on 16/3/31.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "UIView+JYExtension.h"

@implementation UIView (JYExtension)

//Width
- (CGFloat)jy_Width{
    return CGRectGetWidth(self.frame);
}

- (void)setJy_Width:(CGFloat)jy_Width{
    self.frame = CGRectMake(self.jy_Left, self.jy_Top,jy_Width, self.jy_Height);
}

//Height
- (CGFloat)jy_Height{
    return CGRectGetHeight(self.frame);
}
- (void)setJy_Height:(CGFloat)jy_Height{
    self.frame = CGRectMake(self.jy_Left, self.jy_Top,self.jy_Width, jy_Height);
}

//Top
- (CGFloat)jy_Top{
    return CGRectGetMinY(self.frame);
}

- (void)setJy_Top:(CGFloat)jy_Top{
    self.frame = CGRectMake(self.jy_Left,jy_Top , self.jy_Width, self.jy_Height);
}

//Left
- (CGFloat)jy_Left{
   return CGRectGetMinX(self.frame);
}

- (void)setJy_Left:(CGFloat)jy_Left{
    self.frame = CGRectMake(jy_Left, self.jy_Top, self.jy_Width, self.jy_Height);
}

// Right
- (CGFloat)jy_Right{
    return CGRectGetMaxX(self.frame);
}

- (void)setJy_Right:(CGFloat)jy_Right{
    self.jy_Left = jy_Right - self.jy_Width;
}

//Bottom
- (CGFloat)jy_Bottom{
    return CGRectGetMaxY(self.frame);
}

- (void)setJy_Bottom:(CGFloat)jy_Bottom{
    self.jy_Top = jy_Bottom - self.jy_Height;
}

//CenterX
- (CGFloat)jy_CenterX{
    return self.jy_Left + self.jy_Width/2;
}

-(void)setJy_CenterX:(CGFloat)jy_CenterX{
    self.jy_Left = jy_CenterX - self.jy_Width/2;
}

//CenterY
- (CGFloat)jy_CenterY{
    return self.jy_Top + self.jy_Height/2;
}

- (void)setJy_CenterY:(CGFloat)jy_CenterY{
    self.jy_Top = jy_CenterY - self.jy_Height/2;
}

-(void)setJy_Center:(CGPoint)jy_Center{
    self.jy_CenterX = jy_Center.x;
    self.jy_CenterY = jy_Center.y;
}

-(CGPoint)jy_Center{
    return CGPointMake(self.jy_CenterX, self.jy_CenterY);
}

- (CGSize)jy_Size {
    return self.frame.size;
}

- (void)setJy_Size:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}
@end
