//
//  BackgroundHelper.h
//  GymPact
//
//  Created by Bobby Ren on 5/1/14.
//  Copyright (c) 2014 Harvard University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackgroundHelper : NSObject

// background tasking for uploads
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic, strong) NSDecimalNumber *previous;
@property (nonatomic, strong) NSDecimalNumber *current;
@property (nonatomic) NSUInteger position;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, strong) NSDate *backgroundEnterTime;

+(void)tick;
+(void)stopTick;
+(void)resetBackgroundTask;

+(void)keepTaskInBackgroundForPhotoUpload;
+(void)stopTaskInBackgroundForPhotoUpload;


@end
