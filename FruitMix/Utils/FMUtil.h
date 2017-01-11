//
//  FMUtil.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/25.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMUtil : NSObject

+ (dispatch_queue_t)setterLowQueue;

+ (dispatch_queue_t)setterDefaultQueue;

+ (dispatch_queue_t)setterHighQueue;

+ (dispatch_queue_t)setterBackGroundQueue;

+ (dispatch_queue_t)setterCacheQueue;

+ (dispatch_queue_t)setterQuickUploadQueue;

+ (UIViewController *)getCurrentVC;

+ (UIViewController *)getTopViewController;
@end
