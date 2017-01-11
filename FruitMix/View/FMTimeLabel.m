//
//  FMTimeLabel.m
//  FruitMix
//
//  Created by 杨勇 on 16/7/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMTimeLabel.h"

static const float kMFSecondsPerMinute              = 60.0f;
static const float kMFSecondsPerHour                = 60.0f * 60.0f;
static const float kMFSecondsPerDay                 = 60.0f * 60.0f * 24.0f;
static const float kMFSecondsPerYear                = 60.0f * 60.0f * 24.0f * 365.0f;

static NSTimer *refreshTimer                         = nil;
static NSDateFormatter *dateFormatter                = nil;

@interface FMTimeLabel ()

- (void)addAutoRefreshNotification;
- (void)remvoeAutoRefreshNotification;

@end
@implementation FMTimeLabel


#pragma mark - Life Cycle

+ (void)initialize {
    if (self == [FMTimeLabel class]) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addAutoRefreshNotification];
    }
    return self;
}

- (id)init{
    return [self initWithFrame:CGRectZero];
}

- (void)dealloc{
    [self remvoeAutoRefreshNotification];
}

#pragma mark - Class Methods


+ (FMTimeLabel *)autoLayoutRefreshTimeLabel {
    FMTimeLabel* timeLabel = [[FMTimeLabel alloc] init];
    timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    return timeLabel;
}

+ (void)startRefreshTime {
    if (refreshTimer.isValid) {
        return;
    }
    
    [FMTimeLabel stopRefreshTime];
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                    target:self
                                                  selector:@selector(postUpdateNotify)
                                                  userInfo:nil
                                                   repeats:YES];
}

+ (void)stopRefreshTime {
    if (refreshTimer != nil) {
        [refreshTimer invalidate];
        refreshTimer = nil;
    }
}


+ (void)postUpdateNotify {
    [[NSNotificationCenter defaultCenter] postNotificationName:FMTimeLabelAutoRefreshNotification
                                                        object:nil];
}


#pragma mark - Public Methods

- (void)setDate:(NSDate *)date {
    if (_date != date) {
        _date = date;
        
        //更新内容
        [self initTimeText];
        
        //启动timer
        [FMTimeLabel startRefreshTime];
    }
}


#pragma mark - Private Methods

- (void)addAutoRefreshNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTimeDisplay)
                                                 name:FMTimeLabelAutoRefreshNotification
                                               object:nil];
}

- (void)remvoeAutoRefreshNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)initTimeText {
    NSDate* now = [NSDate date];
    NSTimeInterval since = [now timeIntervalSinceDate:self.date];
    BOOL isFurture = since < 0;
    
    since = fabs(since);
    
    int hours     = (int)round(since / kMFSecondsPerHour);
    int days      = (int)round(since / kMFSecondsPerDay);
    int years     = (int)floor(since / kMFSecondsPerYear);
    
    if (isFurture) {
        dateFormatter.dateFormat = @"MM-dd";
        self.text = [dateFormatter stringFromDate:self.date]; 	     //未来时间
    } else if (years > 0) {
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        self.text = [dateFormatter stringFromDate:self.date];        //一年之前
    } else if (days > 2) {
        dateFormatter.dateFormat = @"MM-dd HH:mm";
        self.text = [dateFormatter stringFromDate:self.date];        //2天前
    } else if (days == 2) {
        dateFormatter.dateFormat = @"前天 HH:mm";
        self.text = [dateFormatter stringFromDate:self.date];        //前天
    } else if (days == 1) {
        dateFormatter.dateFormat = @"昨天 HH:mm";
        self.text = [dateFormatter stringFromDate:self.date];        //昨天
    } else if (hours > 4) {
        dateFormatter.dateFormat = @"HH:mm";
        self.text = [dateFormatter stringFromDate:self.date];        //5小时到今天
    } else {
        [self updateTimeDisplay];  //短时差的要即时更新
    }
}

- (void)updateTimeDisplay {
    NSDate* now = [NSDate date];
    NSTimeInterval since = [now timeIntervalSinceDate:self.date];
    since = fabs(since);
    
    int minutes   = (int)round(since / kMFSecondsPerMinute);
    int hours     = (int)round(since / kMFSecondsPerHour);
    
    //超出5小时的，不自动更新
    if (hours > 4) {
        return;
    }
    
    if (hours > 0) {
        self.text = [NSString stringWithFormat:@"%d小时前", hours];    //1～5小时之间
    } else if (minutes > 0) {
        self.text = [NSString stringWithFormat:@"%d分钟前", minutes];  //1分钟～1小时
    } else {
        self.text = @"刚刚";                                           //1分钟内
    }
}

@end

NSString * const FMTimeLabelAutoRefreshNotification = @"MFTimeLabelAutoRefreshNotification";
