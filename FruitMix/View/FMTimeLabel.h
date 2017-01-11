//
//  FMTimeLabel.h
//  FruitMix
//
//  Created by 杨勇 on 16/7/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMTimeLabel : UILabel
@property (nonatomic, strong) NSDate* date;

+ (FMTimeLabel *)autoLayoutRefreshTimeLabel;
+ (void)startRefreshTime;
+ (void)stopRefreshTime;

@end


// 更新时间显示通知

extern NSString * const FMTimeLabelAutoRefreshNotification;