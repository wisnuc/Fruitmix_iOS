//
//  UIImage+ScrollIndicatorExt.m
//  ScrollIndicatorView
//
//  Created by hupeng on 15/3/11.
//  Copyright (c) 2015年 hupeng. All rights reserved.
//

#import "UIScrollView+IndicatorExt.h"
#import <objc/runtime.h>
#import "UIView+JY_ExtendTouchRect.h"

@interface ILSSlider ()
{
    CGPoint _startCenter;
    UIImageView * _timeBgView;
}
@end

@implementation ILSSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.sliderState = UIControlStateNormal;
//        _sliderIcon.userInteractionEnabled = YES;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self addGestureRecognizer:pan];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tap];
        
        _sliderIcon = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_sliderIcon];
        
        //jy
        _timeBgView = [[UIImageView alloc]initWithFrame:CGRectMake(-124-24, kILSDefaultSliderHeight/2-39/2, 124, 39)];
        _timeBgView.image = [UIImage imageNamed:@"date_bg"];
        _timeLabel = [[UILabel alloc]initWithFrame:_timeBgView.bounds];
        _timeLabel.font = [UIFont fontWithName:DONGQING size:17];
        _timeLabel.text = @"今天";
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeBgView.hidden = YES;
        _timeLabel.backgroundColor = [UIColor clearColor];
        [_timeBgView addSubview:_timeLabel];
        [self addSubview:_timeBgView];
    }
    return self;
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.sliderState = UIControlStateSelected;
        _startCenter = self.center;
        _timeBgView.hidden = NO;
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [gesture translationInView:self];
        self.center = CGPointMake(self.center.x, _startCenter.y + point.y);
        
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    if (gesture.state == UIGestureRecognizerStateEnded){
        _timeBgView.hidden = YES;
        self.sliderState = UIControlStateNormal;
    }
}

- (void)tap:(UITapGestureRecognizer *)gesture
{
    if (_status != ILSSliderStatusBottom) {
        return;
    }
    
    self.center = CGPointMake(self.center.x, kILSDefaultSliderHeight * 0.5);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
}

- (void)setStatus:(ILSSliderStatus)status
{
    _status = status;
    
    switch (status) {
        case ILSSliderStatusTop:
            _sliderIcon.image = [UIImage imageNamed:@"handrail"];
            break;
        case ILSSliderStatusCenter:
            _sliderIcon.image = [UIImage imageNamed:@"handrail"];
            break;
        case ILSSliderStatusBottom:
            _sliderIcon.image = [UIImage imageNamed:@"handrail"];
            break;
        default:
            break;
    }
}

@end


@implementation ILSIndicatorView

- (void)dealloc
{
    if (_scrollView) {
        [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _slider = [[ILSSlider alloc] initWithFrame:CGRectMake(0, 0, kILSDefaultSliderWidth, kILSDefaultSliderHeight)];
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        _slider.status = ILSSliderStatusTop;
        [self addSubview:_slider];
//        self.clipsToBounds = TRUE;
    }
    return self;
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    CGPoint buttonPoint = [_slider convertPoint:point fromView:self];
    if ([_slider pointInside:buttonPoint withEvent:event]) {
        return _slider;
    }
    return result;
}


- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:0x01 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        float sliderOffsetY = _scrollView.contentOffset.y/(_scrollView.contentSize.height - _scrollView.frame.size.height) * (self.frame.size.height - kILSDefaultSliderHeight);
        
        float centerY = sliderOffsetY + kILSDefaultSliderHeight * 0.5;
        
        if (centerY <= kILSDefaultSliderHeight * 0.5) {
            centerY = kILSDefaultSliderHeight * 0.5;
            _slider.status = ILSSliderStatusTop;
            
        } else if (centerY >= self.frame.size.height - kILSDefaultSliderHeight * 0.5) {
        
            centerY = self.frame.size.height - kILSDefaultSliderHeight * 0.5;
            _slider.status = ILSSliderStatusBottom;
        } else {
            _slider.status = ILSSliderStatusCenter;
        }

        _slider.center = CGPointMake(kILSDefaultSliderWidth * 0.5, centerY);
    }
}

- (void)sliderValueChanged:(UISlider *)slider
{
    self.value = (slider.center.y - 0.5 * kILSDefaultSliderHeight)/(self.frame.size.height - kILSDefaultSliderHeight);
    
    self.value = MAX(self.value, 0.0);
    self.value = MIN(self.value, 1.0);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end

@implementation UIScrollView (IndicatorExt)

const char kIndicatorKey;

- (void)setIndicator:(ILSIndicatorView *)indicator
{
    objc_setAssociatedObject(self, &kIndicatorKey, indicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ILSIndicatorView *)indicator
{
    return objc_getAssociatedObject(self, &kIndicatorKey);
}

- (void)registerILSIndicator
{
    if (!self.scrollEnabled || self.contentSize.height <= self.frame.size.height || self.indicator) {
        return;
    }
    
    
    self.showsVerticalScrollIndicator = FALSE;
    
    ILSIndicatorView *indicator = [[ILSIndicatorView alloc] initWithFrame:CGRectMake(self.frame.origin.x + self.frame.size.width - kILSDefaultSliderWidth, self.frame.origin.y + kILSDefaultSliderMargin, 1, CGRectGetHeight(self.bounds) - 2 * kILSDefaultSliderMargin)];
    [indicator addTarget:self action:@selector(indicatorValueChanged:) forControlEvents:UIControlEventValueChanged];
    indicator.scrollView = self;
    self.indicator = indicator;
    [self.superview addSubview:indicator];
}


- (void)indicatorValueChanged:(ILSIndicatorView *)indicator
{
    float contentOffset = indicator.value * (self.contentSize.height - self.frame.size.height);
    
    if (contentOffset == 0) {
        [self setContentOffset:CGPointMake(0, contentOffset) animated:YES];
    }else{
        self.contentOffset = CGPointMake(0, contentOffset);
    }
    
    
}

@end
