//
//  BackgroundRunner.m
//  BG
//
//  Created by Joe on 13-8-27.
//  Copyright (c) 2013年 Joe. All rights reserved.
//

#import "BackgroundRunner.h"
@interface BackgroundRunner(){
    UIBackgroundTaskIdentifier _background_task;
    NSTimer *_backTimer;
}

@end

@implementation BackgroundRunner

+ (BackgroundRunner *)shared
{
    static BackgroundRunner *sharedRunner;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRunner = [[BackgroundRunner alloc] init];
    });
    return sharedRunner;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    _backTimer = nil;
    [_backTimer invalidate];
}

#pragma mark - public method
- (void)hold
{
//    _holding = YES;
//    while (_holding) {
//        [NSThread sleepForTimeInterval:1];
//        /** clean the runloop for other source */
//        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE);
//    }
    
    _holding = YES;
    if (_holding) {
        _backTimer = [NSTimer scheduledTimerWithTimeInterval:25.0 target:self selector:@selector(applyForMoreTime) userInfo:nil repeats:YES];
        [_backTimer fire];
    }else{
        _backTimer = nil;
        [_backTimer invalidate];
    }
}

- (void)stop
{
    _holding = NO;
}

- (void)run
{
//    UIApplication *application = [UIApplication sharedApplication];
//    __block UIBackgroundTaskIdentifier background_task;
//    //Create a task object
//    background_task = [application beginBackgroundTaskWithExpirationHandler: ^ {
//        [self hold];
//        [application endBackgroundTask: background_task];
//        background_task = UIBackgroundTaskInvalid;
//    }];
//     __block UIBackgroundTaskIdentifier background_task;
    UIApplication*  app = [UIApplication sharedApplication];
    _background_task = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:_background_task];
        _background_task = UIBackgroundTaskInvalid;
    }];
    [self hold];
    //开启定时器 不断向系统请求后台任务执行的时间
    
}

-(void)applyForMoreTime {
    //如果系统给的剩余时间小于60秒 就终止当前的后台任务，再重新初始化一个后台任务，重新让系统分配时间，这样一直循环下去，保持APP在后台一直处于active状态。
    if ([UIApplication sharedApplication].backgroundTimeRemaining < 60) {
        [[UIApplication sharedApplication] endBackgroundTask:_background_task];
        _background_task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:_background_task];
            _background_task = UIBackgroundTaskInvalid;
        }];
    }
}

@end
