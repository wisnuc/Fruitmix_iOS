//
//  FMFileManager.h
//  FruitMix
//
//  Created by 杨勇 on 16/11/3.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FMFileManagerInstance [FMFileManager shareManager]

@interface FMFileManager : NSObject

+(instancetype)shareManager;

-(void)removeFileWithFileName:(NSString *)fileName andCompleteBlock:(void(^)(BOOL isSuccess))block;

-(void)removeFileAtPath:(NSString *)filePath;

@end
