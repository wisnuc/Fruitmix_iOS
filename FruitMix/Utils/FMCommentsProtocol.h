//
//  FMCommentsProtocol.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/28.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FMCommentsProtocol <NSObject>

@required
-(NSString *)shareid;
-(NSString *)text;
-(NSString *)creator;
-(long long)datatime;

@end
