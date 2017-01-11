//
//  AutoHeightTextView.h
//  AutoHeightTextView
//
//  Created by adan on 16/8/28.
//  Copyright © 2016年 adan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoHeightTextView : UITextView
/**
 *	允许最大高度
 */
@property (nonatomic, assign) CGFloat maxHeight;
/**
 *	边框宽度
 */
@property (nonatomic, assign) CGFloat borderWidth;
/**
 *	圆角半径
 */
@property (nonatomic, assign) CGFloat cornerWidth;
/**
 *	边框颜色
 */
@property (nonatomic, strong) UIColor *borderColor;

@end
