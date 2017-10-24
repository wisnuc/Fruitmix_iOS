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

@property (nonatomic) UIButton * cancelBtn;

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
    
    [_backView addSubview:self.cancelBtn];
    [_backView addSubview:self.processView];
    [self setContentFrame];

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
    [[UIApplication sharedApplication].keyWindow willRemoveSubview:_backWindow];
    [self.backWindow removeFromSuperview];
}

- (void)setContentFrame{
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_backView).offset(-25);
        make.bottom.equalTo(_backView).offset(-16);
        make.size.mas_equalTo(CGSizeMake(44, 20));
    }];
    [_processView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_backView).offset(25);
        make.bottom.equalTo(_backView).offset(-25);
        make.right.equalTo(_cancelBtn.mas_left).offset(-3);
        make.height.equalTo(@2);
    }];
    [_cancelBtn setEnlargeEdgeWithTop:5 right:10 bottom:5 left:5];
}

- (UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn addTarget:self  action:@selector(cancleBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//        _cancelBtn.frame = CGRectMake(_backView.frame.size.width - 70, _backView.frame.size.height  - 30, 50, 15);
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancelBtn setTitleColor:UICOLOR_RGB(0x03a9f4) forState:UIControlStateNormal];
    }
    return _cancelBtn;
}

- (UIProgressView *)processView{
    if (!_processView) {
        _processView = [[UIProgressView alloc]init];
//                        WithFrame:CGRectMake(25, 110, _backView.bounds.size.width-50, 2)];
        _processView.progressViewStyle= UIProgressViewStyleDefault;
//        _processView.trackTintColor = UICOLOR_RGB(0x03a9f4);
        _processView.progressTintColor = UICOLOR_RGB(0x03a9f4);
    }
    return _processView;
}

@end
