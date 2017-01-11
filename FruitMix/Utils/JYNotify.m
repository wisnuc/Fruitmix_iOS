//
//  JYNotify.m
//  FruitMix
//
//  Created by 杨勇 on 16/12/15.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYNotify.h"

@interface JYNotify (){
    UILabel *_label;
    UIImageView *_iv;
}

@property (nonatomic, strong) NSArray *imageNameArr;
@end

@implementation JYNotify

- (NSArray *)imageNameArr {
    if (!_imageNameArr) {
        _imageNameArr = @[@"pc_error", @"pc_success", @"pc_warning"];
    }
    return _imageNameArr;
}

+ (JYNotify *)shareRemindView{
    static JYNotify *rv = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        rv = [[JYNotify alloc]init];
    });
    return rv;
}

- (instancetype)init {
    if (self = [super init]) {
        UIWindow * window = [UIApplication sharedApplication].windows[0];
        [window addSubview:self];
        self.frame = CGRectMake(0, -80, __kWidth, 80);
        self.backgroundColor = [UIColor whiteColor];
        
        //        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        //        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        //        effectView.frame = CGRectMake(0, 0, SCREENWIDTH, 64);
        //        [self addSubview:effectView];
        
//        self.layer.shadowOffset =  CGSizeMake(1, 3);
//        self.layer.shadowOpacity = 0.8;
//        self.layer.shadowColor =  [UIColor blackColor].CGColor;
        _iv = [[UIImageView alloc]init];
        [self addSubview:_iv];
        [_iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.bottom.mas_equalTo(-10);
            make.size.mas_equalTo(CGSizeMake(25, 25));
        }];
        
        _label = [UILabel new];
        _label.textColor = [UIColor blackColor];
        _label.font = [UIFont systemFontOfSize:15];
        _label.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_label];
        _label.font = [UIFont italicSystemFontOfSize:15];
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_iv.mas_right).mas_offset(5);
            make.centerY.mas_equalTo(_iv);
        }];
    }
    return self;
}

- (void)setMessageType:(JYMessageType)messageType andMessage:(NSString *)message {
    _iv.image = [UIImage imageNamed:self.imageNameArr[messageType]];
    _label.text = message;
}

- (void)showViewWithMessagetype:(JYMessageType)messageType andMessage:(NSString *)message{
    [self setMessageType:messageType andMessage:message];
    [self showView];
}

- (JYNotify *)showView{
    __weak __typeof(self) weakSelf = self;
    self.frame = CGRectMake(0, -80, __kWidth, 80);
    [self.layer removeAllAnimations];
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:.5 initialSpringVelocity:.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [weakSelf setFrame:CGRectMake(0, -16, __kWidth, 80)];
    } completion:^(BOOL finished) {
        [weakSelf hiddenView];
    }];
    
    return self;
}

- (void)hiddenView {
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:.3 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [weakSelf setFrame:CGRectMake(0, -80, __kWidth, 80)];
    } completion:^(BOOL finished) {
        
    }];
}

@end
