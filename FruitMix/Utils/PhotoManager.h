//
//  PhotoManager.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/20.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef enum : NSUInteger {
    FMNetStatusNoNet,
    FMNetStatusWIFI,
    FMNetStatusWWAN,
} FMNetStatus;

typedef void(^ImageAssetsBlock)(PHFetchResult<PHAsset *> * result);

typedef void(^AssetsArrayBlock)(NSArray<PHAsset *> * result);

typedef void(^Result)(NSData *fileData, NSString *fileName);

typedef void(^ResultPath)(NSString *filePath, NSString *fileName);

@interface PhotoManager : NSObject

@property (nonatomic, copy) void (^backgroundSessionCompletionHandler)(void);

@property (nonatomic) FMNetStatus netStatus;

@property (nonatomic) BOOL isUploading;

@property (nonatomic) BOOL canUpload;

@property (nonatomic) NSOperationQueue * getImageQueue;

@property (nonatomic) AFURLSessionManager * afManager;
@property (nonatomic,strong) NSMutableArray *uploadarray;

+(__kindof PhotoManager *)shareManager;

+(void)reStartUploader;

+(PHFetchResult *)photoAssetWithLocalIds:(NSArray *)localids;

-(void)getAllPhotoWithType:(PHAssetCollectionType)type andImageAssetsBlock:(ImageAssetsBlock)block;
//getAll Image Assets
-(void)getAllPHAssetAndCompleteBlock:(AssetsArrayBlock)block;

-(void)saveImage:(UIImage *)image andCompleteBlock:(void(^)(BOOL isSuccess))block;
+ (void)getImageFromPHAsset:(PHAsset *)asset Complete:(Result)result;
+ (void)getVideoFromPHAsset:(PHAsset *)asset Complete:(Result)result;

+ (void)getImageDataWithPHAsset:(PHAsset *)asset andCompleteBlock:(void(^)(NSString * filePath))block;

+ (void)_getImageDataWithPHAsset:(PHAsset *)asset andCompleteBlock:(void(^)(NSString * filePath))block;

//检查网络 判断是否上传
+(void)checkNetwork;
/**
 *  判断是否为本地图片
 */
+(void)managerCheckPhotoIsLocalWithPhotohash:(NSString *)degist
                            andCompleteBlock:(void(^)(NSString * localId,NSString * photoHash,BOOL isLocal))block;

//+(void)managerCheckIfIsLocalPhoto:(NSString *)degist CompleteBlock:(void(^)(BOOL isLocal))block;
/**
 *  检测DeviceUUID 状态
 */
+(NSString *)getUUID;
/**
 *  后台计算 本地新增图片 的 degist
 */
+(void)calculateDigestWhenPhotoHaveNotCompleteBlock:(void(^)(NSArray * arr))block;
/*
 *  计算单张 本地照片 的 digest
 *
 */
//+(void)calculateDigestWithLocalId:(NSString *)localId andCompleteBlock:(void(^)(BOOL success,NSString * digest))block;


+(NSString *) getSha256WithAsset:(PHAsset *)asset;

//begin  background 
- (void)startBackgroundSession;

// upload complete do something

-(void)uploadComplete:(BOOL)isSuccess andSha256:(NSString *)sha256Str withFilePath:(NSString *)filePath  andAsset:(PHAsset *)asset andSuccessBlock:(void (^)(NSString *url))success Failure:(void (^)())failure;

-(void)cleanUploadTask;
@end
