//
//  FMShareScrollComment.h
//  FruitMix
//
//  Created by 杨勇 on 16/5/4.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"
#import "YYGestureRecognizer.h"

#define TIMER_NOTIFY @"timer_notify"

@interface FMShareScrollComment : UIView

@property (nonatomic ,strong) UILabel *notice;
//@property (nonatomic ,strong) MarqueeLabel *award;

@property (nonatomic ,strong) NSArray<FMComment *> *noticeList;

//@property (nonatomic) MSWeakTimer * timer;

-(void)displayNews;

@property (nonatomic, copy) void (^touchBlock)(FMShareScrollComment *view, YYGestureRecognizerState state, NSSet *touches, UIEvent *event);
@property (nonatomic, copy) void (^longPressBlock)(FMShareScrollComment *view, CGPoint point);
@end
