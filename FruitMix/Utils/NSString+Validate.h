//
//  NSString+Validate.h
//  FruitMix
//
//  Created by wisnuc-imac on 2017/9/25.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Validate)
+ (BOOL)isPassword:(NSString *)password;
+ (BOOL)isUserName:(NSString *)usernName;
@end
