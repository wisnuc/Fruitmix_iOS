//
//  UIButton+Universal.h
//  FruitMix
//
//  Created by wisnuc on 2017/8/15.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Universal)
+ (UIButton* _Nullable)buttionWithTitle:(NSString *_Nullable)title target:(nullable id)target action:(nonnull SEL)action;
@end
