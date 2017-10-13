//
//  FMUploadFileAPI.h
//  FruitMix
//
//  Created by 杨勇 on 16/10/25.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMUploadFileAPI : NSObject
//+(instancetype)shareManager;

+(void)uploadAddressFileWithFilePath:(NSString *)filePath andCompleteBlock:(void(^)(BOOL success))completeBlock;
+ (void)getDriveInfoCompleteBlock:(void(^)(BOOL successful))completeBlock;
+ (void)getDirectoriesForPhotoCompleteBlock:(void(^)(BOOL successful))completeBlock;
//+ (void)getDirectoriesForFilesCompleteBlock:(void(^)(BOOL successful))completeBlock;
+ (void)getDirEntrySuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                   failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

+ (void)getDirEntryWithUUId:(NSString *)uuid
    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

+ (long long)fileSizeAtPath:(NSString*) filePath;
+ (void)uploadDirEntryWithFilePath:(NSString *)filePath
                           success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure otherFailure:(void (^)(NSString *null))otherFailure;
+ (void)creatPhotoMainFatherDirEntryCompleteBlock:(void(^)(BOOL successful))completeBlock;
+ (NSString *)JSONString:(NSString *)aString;
+ (void)creatPhotoDirEntryCompleteBlock:(void(^)(BOOL successful))completeBlock;
//+ (void)uploadsSiftWithDataSouce:(NSArray *)dataSouce Asset:(PHAsset *)asset LocalPhotoHash:(NSString*)localPhotoHash filePath:(NSString *)filePath SuccessBlock:(void (^)(NSString *url))success Failure:(void (^)())failure CopmleteBlock:(void(^)(BOOL upload))completeBlock;
+ (NSString *)getDeviceName;

+ (void)getPhotoUUIDWithBlock:(void(^)(BOOL successful))completeBlock;
@end
