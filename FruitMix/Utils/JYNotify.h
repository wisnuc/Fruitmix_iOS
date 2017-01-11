//
//  JYNotify.h
//  FruitMix
//
//  Created by 杨勇 on 16/12/15.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JYMessageType) {
    MessageTypeError,   // 错误
    MessageTypeSuccess, // 成功
    MessageTypeWarning  // 警告
};


@interface JYNotify : UIView

+ (JYNotify *)shareRemindView;
- (JYNotify *)showView;
- (void)setMessageType:(JYMessageType)messageType andMessage:(NSString *)message;

- (void)showViewWithMessagetype:(JYMessageType)messageType andMessage:(NSString *)message;

@end
