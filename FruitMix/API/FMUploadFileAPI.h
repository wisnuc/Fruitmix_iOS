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
+ (void)getDriveInfoCompleteBlock:(void(^)(BOOL successful))completeBlock;
+ (void)getDirectoriesCompleteBlock:(void(^)(BOOL successful))completeBlock;
+ (void)getDirEntrySuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                   failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

+ (void)getDirEntryWithUUId:(NSString *)uuid
    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

//+ (void)getDirEntry;
+ (long long)fileSizeAtPath:(NSString*) filePath;
+ (void)uploadDirEntryWithFilePath:(NSString *)filePath
                        success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
+ (void)creatPhotoDirEntryCompleteBlock:(void(^)(BOOL successful))completeBlock;
+ (NSString *)JSONString:(NSString *)aString;


+ (void)uploadsSiftWithDataSouce:(NSArray *)dataSouce Asset:(PHAsset *)asset LocalPhotoHash:(NSString*)localPhotoHash filePath:(NSString *)filePath SuccessBlock:(void (^)(NSString *url))success Failure:(void (^)())failure CopmleteBlock:(void(^)(BOOL upload))completeBlock;
@end
