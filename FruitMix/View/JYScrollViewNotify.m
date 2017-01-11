//
//  JYScrollViewNotify.m
//  FruitMix
//
//  Created by 杨勇 on 16/12/21.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYScrollViewNotify.h"
#define kTopHeight 20
#define kFont(n) [UIFont systemFontOfSize:(n)]

@interface JYScrollViewNotify ()
@property (nonatomic, weak) UIScrollView *scrollView;
@end

@implementation JYScrollViewNotify


- (instancetype)initWithFrame:(CGRect)frame scrollView:(UIScrollView *)scrollView content:(NSString *)content {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.scrollView = scrollView;
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [self addSubview:titleLabel];
        titleLabel.frame = self.bounds;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = kFont(10);
        titleLabel.text = content;
    }
    return self;
}

+ (void)showInView:(UIScrollView *)scrollView content:(NSString *)content {
    JYScrollViewNotify *topNewView = [[self alloc] initWithFrame:CGRectMake(scrollView.frame.origin.x,
                                                                    scrollView.frame.origin.y,
                                                                    __kWidth,
                                                                    kTopHeight)
                                              scrollView:scrollView
                                                 content:content];
    [scrollView.superview addSubview:topNewView];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) return;
    
    [self.scrollView setContentOffset:CGPointMake(0, -kTopHeight) animated:YES];
    
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:2.0f];
}

- (void)dismiss {
    [UIView animateWithDuration:3.0f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self.scrollView setContentOffset:CGPointZero animated:YES];
        [self removeFromSuperview];
    }];
}


@end
