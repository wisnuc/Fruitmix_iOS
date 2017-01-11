//
//  AutoHeightTextView.m
//  AutoHeightTextView
//
//  Created by adan on 16/8/28.
//  Copyright © 2016年 adan. All rights reserved.
//

#import "AutoHeightTextView.h"

@implementation AutoHeightTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //添加内容变化的监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFrame) name:UITextViewTextDidChangeNotification object:nil];
        [self setStyleWithFrame:frame];
    }
    return self;
}

#pragma mark 设置显示效果(如果重新设置,会覆盖此处的样式)
- (void)setStyleWithFrame:(CGRect )frame {
    
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.font = [UIFont systemFontOfSize:frame.size.height * 0.5];
    self.layer.borderWidth = (frame.size.width < frame.size.height ? frame.size.width : frame.size.height) * 0.1;
    self.layer.cornerRadius = (frame.size.width < frame.size.height ? frame.size.width : frame.size.height) * 0.2;
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}
- (void)setBorderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}
- (void)setCornerWidth:(CGFloat)cornerWidth {
    self.layer.cornerRadius = cornerWidth;
}

#pragma mark 通过内容计算高度,重新设置frame
- (void)changeFrame {
    
    CGFloat maxH = self.maxHeight;
    CGRect frame = self.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [self sizeThatFits:constraintSize];
    if (size.height <= frame.size.height) {
        size.height = frame.size.height;
    } else {
        if (size.height >= maxH) {
            size.height = maxH ;
            self.scrollEnabled = YES;
        } else {
            self.scrollEnabled = NO;
        }
    }
    self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
