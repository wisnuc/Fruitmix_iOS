//
//  FMUploadFileAPI.h
//  FruitMix
//
//  Created by 杨勇 on 16/10/25.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMUploadFileAPI : NSObject

+(void)uploadAddressFileWithFilePath:(NSString *)filePath andCompleteBlock:(void(^)(BOOL success))completeBlock;
+ (void)getDriveInfo;
+ (void)getDirectories;
+ (void)getDir;
+ (void)getDirEntry;
@end
