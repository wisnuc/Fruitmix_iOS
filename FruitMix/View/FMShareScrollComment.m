//
//  FMShareScrollComment.m
//  FruitMix
//
//  Created by 杨勇 on 16/5/4.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMShareScrollComment.h"
#import "Masonry.h"



@implementation FMShareScrollComment{
    CGPoint _point;
    NSTimer *_timer;
    BOOL _longPressDetected;
    
    int _countInt;
}
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        _countInt = 0;
        self.backgroundColor = [UIColor whiteColor];
        self.noticeList = [NSArray array];
        [self initContentView];
    }
    
    return self;
}

- (void)initContentView{
//    self.notice = [[MarqueeLabel alloc]initWithFrame:CGRectZero];
    self.notice = [[UILabel alloc]initWithFrame:CGRectZero];
    self.notice.font = [UIFont systemFontOfSize:15.0];
    self.notice.text = @"";
    self.notice.backgroundColor = UICOLOR_RGB(0xF0F0EB);
    self.notice.textColor = [UIColor lightGrayColor];
//    self.notice.marqueeType = MLLeftRight;
//    self.notice.rate = 60.f;
//    self.notice.trailingBuffer = 20.0f;
    //    self.notice.fadeLength = 10.0f;
    //    self.notice.leadingBuffer = 30.0f;
    [self addSubview:self.notice];
    
//    self.award = [[MarqueeLabel alloc]initWithFrame:CGRectZero];
//    self.award.font = [UIFont systemFontOfSize:15.0];
//    self.award.text = @"...";
//    self.award.textColor = [UIColor lightGrayColor];
//    self.award.marqueeType = MLLeftRight;
//    self.award.rate = 60.f;
//    self.award.fadeLength = 10.0f;
//    self.award.leadingBuffer = 30.0f;
//    self.award.trailingBuffer = 20.0f;
//    [self addSubview:self.award];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayNews) name:TIMER_NOTIFY object:nil];
//    _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(displayNews) userInfo:nil repeats:YES];
//    _timer = [[MSWeakTimer alloc]initWithTimeInterval:2 target:self selector:@selector(displayNews) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
//    [_timer schedule];
//    [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)layoutSubviews{
    [self.notice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).with.offset(-10);
        make.left.mas_equalTo(self.mas_left);
        make.top.mas_equalTo(self.mas_top).with.offset(5);
        make.height.equalTo(@25);
    }];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)displayNews{
    if (self.noticeList.count<=1) {
        if(self.noticeList.count == 0 )
            self.notice.text =@"";
        else{
            FMComment * comment = self.noticeList[0];
            NSString * text = [NSString stringWithFormat:@"%@:%@",[FMConfigInstance getUserNameWithUUID:comment.creator],comment.text];
            self.notice.text = text;
        }
        return;
    }
    _countInt++;
    
    if (_countInt >= [self.noticeList count])
        _countInt=0;
    FMComment * comment1 = self.noticeList[_countInt];
    NSString * text = [NSString stringWithFormat:@"%@:%@",[FMConfigInstance getUserNameWithUUID:comment1.creator],comment1.text];
    
    CATransition *animation = [CATransition animation];
//    animation.delegate = self;
    animation.duration = 0.5f ;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    animation.type = @"push";
    animation.subtype = @"fromTop";
    
    [self.notice.layer addAnimation:animation forKey:nil];
    self.notice.text = text;
}

- (void)startTimer {
    [_timer invalidate];
    _timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(timerFire) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)endTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)timerFire {
    [self touchesCancelled:[NSSet set] withEvent:nil];
    _longPressDetected = YES;
    if (_longPressBlock) _longPressBlock(self, _point);
    [self endTimer];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _longPressDetected = NO;
    if (_touchBlock) {
        _touchBlock(self, YYGestureRecognizerStateBegan, touches, event);
    }
    if (_longPressBlock) {
        UITouch *touch = touches.anyObject;
        _point = [touch locationInView:self];
        [self startTimer];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_longPressDetected) return;
    if (_touchBlock) {
        _touchBlock(self, YYGestureRecognizerStateMoved, touches, event);
    }
    [self endTimer];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_longPressDetected) return;
    if (_touchBlock) {
        _touchBlock(self, YYGestureRecognizerStateEnded, touches, event);
    }
    [self endTimer];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_longPressDetected) return;
    if (_touchBlock) {
        _touchBlock(self, YYGestureRecognizerStateCancelled, touches, event);
    }
    [self endTimer];
}


@end
