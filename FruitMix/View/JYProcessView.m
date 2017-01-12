//
//  JYProcessView.m
//  ProcessView
//
//  Created by JackYang on 2017/1/10.
//  Copyright © 2017年 JackYang. All rights reserved.
//



#define kWindowW  [UIScreen mainScreen].bounds.size.width
#define kWindowH  [UIScreen mainScreen].bounds.size.height
#define processViewW  kWindowW*0.77
#define processViewH  processViewW*0.55

#import "JYProcessView.h"

@interface JYProcessView ()

@property (nonatomic) UIView * backWindow;

@property (nonatomic) UIView * backView;

@property (nonatomic) UIProgressView * processView;

@end

@implementation JYProcessView


+(JYProcessView *)processViewWithType:(ProcessType)type{
    
    JYProcessView * pv  = [[JYProcessView alloc]init];
    [pv setUp];
    return pv;
}

-(void)setValueForProcess:(CGFloat)process{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.processView setProgress:process animated:NO];
    });
}

-(void)setUp{
    _backWindow = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _backWindow.backgroundColor = [UIColor clearColor];
    
    UIView * black = [[UIView alloc] initWithFrame:_backWindow.bounds];
    black.backgroundColor = [UIColor blackColor];
    black.alpha = 0.5;
    [_backWindow addSubview:black];
    
    _backView = [[UIView alloc] initWithFrame:CGRectMake((kWindowW - processViewW)/2, (kWindowH - processViewH)/2, processViewW, processViewH)];
    _backView.backgroundColor = [UIColor whiteColor];
    [_backWindow addSubview:_backView];
    _backView.layer.cornerRadius = 4;
    
    _descLb = [[UILabel alloc]initWithFrame:CGRectMake(25, 25, _backView.bounds.size.width-50, 20)];
    _descLb.font = [UIFont systemFontOfSize:20];
    _descLb.textColor = [UIColor blackColor];
    [_backView addSubview:_descLb];
    
    _subDescLb = [[UILabel alloc]initWithFrame:CGRectMake(25, 70, _backView.bounds.size.width-50, 15)];
    _subDescLb.font = [UIFont systemFontOfSize:14];
    _subDescLb.textColor = [UIColor lightGrayColor];
    [_backView addSubview:_subDescLb];
    
    _processView = [[UIProgressView alloc]initWithFrame:CGRectMake(25, 110, _backView.bounds.size.width-50, 2)];
    _processView.progressViewStyle= UIProgressViewStyleDefault;
    _processView.trackTintColor = [UIColor colorWithRed:199/255.0 green:217/255.0 blue:251/255.0 alpha:1];
    _processView.progressTintColor = UICOLOR_RGB(0x3f51b5);
    [_backView addSubview:_processView];
    
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self  action:@selector(cancleBtnClick) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = CGRectMake(_backView.frame.size.width - 70, _backView.frame.size.height  - 30, 50, 15);
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancelBtn setTitleColor:UICOLOR_RGB(0x3f51b5) forState:UIControlStateNormal];
    [_backView addSubview:cancelBtn];
}

-(void)cancleBtnClick{
    if (_cancleBlock)
        _cancleBlock();
    [self dismiss];
}

-(void)show{
    [[UIApplication sharedApplication].keyWindow addSubview:_backWindow];
}

-(void)dismiss{
    [self.backWindow removeFromSuperview];
}
@end
