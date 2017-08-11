//
//  UIButton+EnlargeEdge.h
//  FruitMix
//
//  Created by wisnuc on 2017/8/7.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>



@interface UIButton (EnlargeEdge)

- (void)setEnlargeEdge:(CGFloat) size;

- (void)setEnlargeEdgeWithTop:(CGFloat) top right:(CGFloat) right bottom:(CGFloat) bottom left:(CGFloat) left;

@end
