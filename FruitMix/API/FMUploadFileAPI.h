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
+ (void)getDriveInfoCompleteBlock:(void(^)(BOOL success))completeBlock;
+ (void)getDirectoriesCompleteBlock:(void(^)(BOOL success))completeBlock;
+ (void)getDirUploadDirEntryWithFilePath:(NSString *)filePath;
//+ (void)getDirEntry;
+ (long long)fileSizeAtPath:(NSString*) filePath;
+ (void)uploadDirEntryWithFilePath:(NSString *)filePath  completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler ;
+ (void)getDirEntryCompleteBlock:(void(^)(BOOL success))completeBlock;
+(NSString *)JSONString:(NSString *)aString;
@end
