//
//  BackgroundHelper.m
//
//  Created by Bobby Ren on 5/1/14.
//

#import "BackgroundHelper.h"

@implementation BackgroundHelper

+(BackgroundHelper *)sharedBackgroundHelper {
    static BackgroundHelper *sharedBackgroundHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBackgroundHelper = [[BackgroundHelper alloc] init];
    });
    return sharedBackgroundHelper;
}

#pragma mark Display
+(void)tick {
    // to test if app is still backgrounded
    NSLog(@"Tick %@ background time: %f", [NSDate date], [[NSDate date] timeIntervalSinceDate:self.sharedBackgroundHelper.backgroundEnterTime]);
    [self performSelector:@selector(tick) withObject:nil afterDelay:.25];
}

+(void)stopTick {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(tick) object:nil];
}

#pragma mark counting based background keepalive

+(void)resetBackgroundTask {
    self.sharedBackgroundHelper.backgroundTask = UIBackgroundTaskInvalid;
}

+(void)keepTaskInBackgroundForPhotoUpload     {
    self.sharedBackgroundHelper.previous = [NSDecimalNumber one];
    self.sharedBackgroundHelper.current  = [NSDecimalNumber one];
    self.sharedBackgroundHelper.position = 1;

    if (!self.sharedBackgroundHelper.updateTimer)
        self.sharedBackgroundHelper.updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                                   target:self
                                                                                 selector:@selector(calculateNextNumber)
                                                                                 userInfo:nil
                                                                                  repeats:YES];

    self.sharedBackgroundHelper.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"Background handler called. Not running background tasks anymore.");
        [[UIApplication sharedApplication] endBackgroundTask:self.sharedBackgroundHelper.backgroundTask];
        self.sharedBackgroundHelper.backgroundTask = UIBackgroundTaskInvalid;
    }];
}

+(void)stopTaskInBackgroundForPhotoUpload {
    [self.sharedBackgroundHelper.updateTimer invalidate];
    self.sharedBackgroundHelper.updateTimer = nil;
    if (self.sharedBackgroundHelper.backgroundTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:self.sharedBackgroundHelper.backgroundTask];
        self.sharedBackgroundHelper.backgroundTask = UIBackgroundTaskInvalid;
    }
}

+(void)calculateNextNumber
{
    NSDecimalNumber *result = [self.sharedBackgroundHelper.current decimalNumberByAdding:self.sharedBackgroundHelper.previous];

    if ([result compare:[NSDecimalNumber decimalNumberWithMantissa:1 exponent:40 isNegative:NO]] == NSOrderedAscending)
    {
        self.sharedBackgroundHelper.previous = self.sharedBackgroundHelper.current;
        self.sharedBackgroundHelper.current  = result;
        self.sharedBackgroundHelper.position++;
    }
    else
    {
        // This is just too much.... Let's start over.
        self.sharedBackgroundHelper.previous = [NSDecimalNumber one];
        self.sharedBackgroundHelper.current  = [NSDecimalNumber one];
        self.sharedBackgroundHelper.position = 1;
    }

    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive)
    {
        NSLog(@"Result: %@", [NSString stringWithFormat:@"Position %lu = %@", (unsigned long)self.sharedBackgroundHelper.position, self.sharedBackgroundHelper.current]);
    }

    else
    {
        NSString *stateString;
        if (UIApplication.sharedApplication.applicationState == UIApplicationStateInactive)
            stateString = @"Inactive";
        else if (UIApplication.sharedApplication.applicationState == UIApplicationStateBackground)
            stateString = @"Background";
        NSLog(@"App state is %@. Next number = %@", stateString, [NSString stringWithFormat:@"Position %lu = %@", (unsigned long)self.sharedBackgroundHelper.position, self.sharedBackgroundHelper.current]);
        NSLog(@"Background time remaining = %.1f seconds", [UIApplication sharedApplication].backgroundTimeRemaining);
    }
}

@end
