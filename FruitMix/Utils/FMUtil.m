//
//  FMUtil.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/25.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMUtil.h"
#import <YYDispatchQueuePool/YYDispatchQueuePool.h>
#import "NSOperationStack.h"

@implementation FMUtil

//- (NSString *)convertVideoReleaseTimeWithDate:(FMPhotoAsset *)model {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat: @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000+08:00'"];
//    NSTimeInterval timePublished = [[dateFormatter dateFromString:model.asset.creationDate] timeIntervalSince1970];
//    NSTimeInterval time1970 = [[NSDate date]timeIntervalSince1970];
//    
//    double timeSub = time1970 - timePublished;
//    if (timeSub < 0) {
//        return nil;
//    }
//    if (timeSub < 60) {
//        return @"刚刚";
//    }
//    if (timeSub < 60 * 60) {
//        return [NSString stringWithFormat:@"%d分前", (int)timeSub / 60];
//    }
//    if (timeSub < 60 * 60 * 24) {
//        return [NSString stringWithFormat:@"%d小时前", (int)timeSub / (60 * 60)];
//    }
//    if (timeSub < 60 * 60 * 24 * 7) {
//        return [NSString stringWithFormat:@"%d天前", (int)timeSub / (60 * 60 * 24)];
//    }
//    if (timeSub < 60 * 60 * 24 * 30) {
//        return [NSString stringWithFormat:@"%d周前", (int)timeSub / (60 * 60 * 24 * 7)];
//    }
//    if (timeSub < 60 * 60 * 24 * 365) {
//        return [NSString stringWithFormat:@"%d月前", (int)timeSub / (60 * 60 * 24 * 30)];
//    }
//    return [NSString stringWithFormat:@"%d年前", (int)timeSub / (60 * 60 * 24 * 365)];
//}

- (UIImage *)fixOrientation:(UIImage *)aImage {
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

//high- 线程
+ (dispatch_queue_t)setterDefaultQueue {
//    static dispatch_queue_t queue;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        queue = dispatch_queue_create("com.winsun.fruitmix.default", DISPATCH_QUEUE_SERIAL);
//        dispatch_set_target_queue(queue, dispatch_get_global_queue(0, 0));
//    });
    dispatch_queue_t queue = YYDispatchQueueGetForQOS(NSQualityOfServiceUserInitiated);
    return queue;
}

//后台线程
+ (dispatch_queue_t)setterBackGroundQueue {
    static YYDispatchQueuePool * pool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pool = [[YYDispatchQueuePool alloc]initWithName:@"com.winsun.fruitmix.backgroundUpload" queueCount:3 qos:NSQualityOfServiceUtility];
    });
    return [pool queue];
}

+(NSOperationQueue *)defaultOperationQueue{
    static NSOperationQueue * queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NSOperationQueue alloc]init];
        queue.maxConcurrentOperationCount = 1;
        queue.qualityOfService = NSQualityOfServiceBackground;
    });
    return queue;
}

//low等级线程
+ (dispatch_queue_t)setterLowQueue {
    dispatch_queue_t queue = YYDispatchQueueGetForQOS(NSQualityOfServiceBackground);
    
    return queue;
}

+ (dispatch_queue_t)setterHighQueue{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.winsun.fruitmix.hot", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(queue, dispatch_get_global_queue(1, 0));
    });
    return queue;
}

+ (dispatch_queue_t)setterCacheQueue{
    static YYDispatchQueuePool * pool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pool = [[YYDispatchQueuePool alloc]initWithName:@"com.winsun.fruitmix.makeCache" queueCount:1 qos:NSQualityOfServiceUtility];
    });
    return [pool queue];
}

+ (dispatch_queue_t)setterQuickUploadQueue{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.winsun.fruitmix.QuickUpload", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(queue, dispatch_get_global_queue(0, 0));
    });
    return queue;
}


+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

+ (UIViewController *)getTopViewController{
    UIViewController * rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController * topVC = rootVC;
    if (topVC.presentedViewController) {
        topVC =  topVC.presentedViewController;
    }
    return topVC;
}

@end
