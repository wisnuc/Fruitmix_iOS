//
//  FMUploadHelper.h
//  FruitMix
//
//  Created by 杨勇 on 16/5/18.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMUploadHelper : NSObject
@property (copy, nonatomic) void (^singleSuccessBlock)(NSString *);
@property (copy, nonatomic)  void (^singleFailureBlock)();

+ (instancetype)sharedInstance;
@end
