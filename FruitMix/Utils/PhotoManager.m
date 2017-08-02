//
//  PhotoManager.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/20.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "PhotoManager.h"
#import "CocoaSecurity.h"

#import "FMUploadHelper.h"
#import "FMCalculateHelper.h"

#import "FMQuickMSManager.h"

#import "UploadSessionBackgound.h"

#import "BackgroundHelper.h"

#import "FLGetDrivesAPI.h"

#import "FMFileManager.h"

#import "JYNotify.h"

#import "NSOperationStack.h"

#import "FMFileUploadInfo.h"

NSString * const UploadFinishNotifi = @"uploadfinish";

static NSString * const kBackgroundSessionIdentifier = @"com.fruitmix.backgroundsession";

NSString * JY_UUID() {
    CFUUIDRef   uuid_ref        = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref = CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    CFRelease(uuid_string_ref);
    return [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

@interface PhotoManager  ()<PHPhotoLibraryChangeObserver,NSURLSessionDelegate>{
    PHFetchResult * _lastResult;
    FMFileUploadInfo * _currentUploadInfo;
}

@end

@implementation PhotoManager

+(__kindof PhotoManager *)shareManager{
    static PhotoManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

-(instancetype)init{
    if(self = [super init]){
        _canUpload = YES;
//        _afManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[self defaultConfig]];
//        _afManager.attemptsToRecreateUploadTasksForBackgroundSessions = YES;
//        _afManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        _afManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        _getImageQueue = [[NSOperationQueue alloc]init];
        _getImageQueue.maxConcurrentOperationCount = 1;
        _getImageQueue.qualityOfService = NSQualityOfServiceUserInitiated;
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
    return self;
}

+(PHFetchResult *)photoAssetWithLocalIds:(NSArray *)localids{
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    PHFetchResult * result = [PHAsset fetchAssetsWithLocalIdentifiers:localids options:option];
    return result;
}

-(void)saveImage:(UIImage *)image andCompleteBlock:(void(^)(BOOL isSuccess))block{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //写入 相册
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        block(success);
    }];
}

//- (void)saveResult:(PHFetchResult *)result {
//
//    // 2.归档模型对象
//    // 2.1.获得Documents的全路径
//    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    // 2.2.获得文件的全路径
//    NSString *path = [doc stringByAppendingPathComponent:@"fetchResult.data"];
//    // 2.3.将对象归档
//    [NSKeyedArchiver archiveRootObject:_lastResult toFile:path];
//}
//
//
//- (PHFetchResult * )read {
//    // 1.获得Documents的全路径
//    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    // 2.获得文件的全路径
//    NSString *path = [doc stringByAppendingPathComponent:@"fetchResult.data"];
//    
//    PHFetchResult * result =  [NSKeyedUnarchiver unarchiveObjectWithFile:path];
//    return result;
//}

#pragma mark - delegate

- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    PHFetchResultChangeDetails * detail = [changeInstance changeDetailsForFetchResult:_lastResult];
    if(detail){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            NSLog(@"删除%ld张照片，增加%ld张照片",(unsigned long)detail.removedObjects.count,(unsigned long)detail.insertedObjects.count);
            if (detail.removedObjects.count || detail.insertedObjects.count) {
                FMDBSet * dbSet = [FMDBSet shared];
                if(detail.removedObjects.count){
                    NSMutableArray * removeArr = [NSMutableArray arrayWithCapacity:0];
                    for (PHObject * obj in detail.removedObjects) {
                        [removeArr addObject:obj.localIdentifier];
                    }
                    FMDTDeleteCommand * dcmd = FMDT_DELETE(dbSet.photo);
                    [dcmd where:@"localIdentifier" containedIn:removeArr];
                    [dcmd saveChangesInBackground:nil];
                }
                [FMDBControl asyncLoadPhotoToDBWithCompleteBlock:^(NSArray *addArr) {
                    if (detail.removedObjects.count || detail.insertedObjects.count) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter]postNotificationName:PHOTO_LIBRUARY_CHANGE_NOTIFY object:nil];
                        });
                    }
                }];
            }
        });
    }
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}
/****************************************************************************************************************************************************************/
/***********************************************************    Utils   *****************************************************************************************/
/***********************************************************            *****************************************************************************************/
/****************************************************************************************************************************************************************/

-(void)getAllPHAssetAndCompleteBlock:(AssetsArrayBlock)block{
    // 判断授权状态
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized){
            block(nil);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary * tempDic = [NSMutableDictionary dictionaryWithCapacity:0];
            PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
            for (PHAssetCollection * c in collectionResult) {
                if(IsEquallString(c.localizedTitle, @"我的照片流") || IsEquallString(@"My Photo Stream",c.localizedTitle))//屏蔽 我的照片流
                    continue;
                for (PHAsset * asset in [self searchAllImagesInCollection:c]) {
                    [tempDic setObject:asset forKey:asset.localIdentifier];
                }
            }
            PHFetchOptions * opt = [[PHFetchOptions alloc]init];
            PHFetchResult<PHAsset *> * result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:opt];
            _lastResult = result;
            for (PHAsset * asset in result) {
                [tempDic setObject:asset forKey:asset.localIdentifier];
            }
            if(block)
                block([tempDic allValues]);
            
//
//            NSMutableArray * assets = [NSMutableArray arrayWithCapacity:0];
//            for (PHAssetCollection * coll in collectionResult1) {
//                PHFetchResult * result =   [self searchAllImagesInCollection:coll];
//                for (PHAsset * asset in result) {
//                    if (asset.mediaType != PHAssetMediaTypeImage)//不是图片不入库 直接跳过
//                        continue;
//                    [assets addObject:asset];
//                }
//                
//            }
        });
    }];
}



-(void)getAllPhotoWithType:(PHAssetCollectionType)type andImageAssetsBlock:(ImageAssetsBlock)block{
    // 判断授权状态
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized){
            block(nil);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            PHFetchResult<PHAssetCollection *> *collectionResult1 = [PHAssetCollection fetchAssetCollectionsWithType:type subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
            PHAssetCollection * cameraColl = collectionResult1.lastObject;
            if (cameraColl) {
                PHFetchResult * result =   [self searchAllImagesInCollection:cameraColl];
                _lastResult = result;
                if(block){
                    block(result);
                    result = nil;
                }
            }else{
                if (block) {
                    block(nil);
                }
            }
        });
    }];
}

/**
 * 查询某个相册里面的所有图片
 */
- (PHFetchResult<PHAsset *> *)searchAllImagesInCollection:(PHAssetCollection *)collection
{
    // 采取同步获取图片（只获得一次图片）
//    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
//    imageOptions.synchronous = YES;
    
    //排序规则
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    // 遍历这个相册中的所有图片
    PHFetchResult<PHAsset *> *assetResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    
    
//    for (PHAsset *asset in assetResult) {
//        // 过滤非图片
//        if (asset.mediaType != PHAssetMediaTypeImage) continue;
//        
//        // 图片原尺寸
//        CGSize targetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
//        // 请求图片
//        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeDefault options:imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//            NSLog(@"图片：%@ %@", result, [NSThread currentThread]);
//        }];
//    }
    return assetResult;
}

//获取视频路径
+ (void)getVideoPathFromPHAsset:(PHAsset *)asset Complete:(ResultPath)result {
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *resource;
    
    for (PHAssetResource *assetRes in assetResources) {
        if (assetRes.type == PHAssetResourceTypePairedVideo ||
            assetRes.type == PHAssetResourceTypeVideo) {
            resource = assetRes;
        }
    }
    NSString *fileName = @"tempAssetVideo.mov";
    if (resource.originalFilename) {
        fileName = resource.originalFilename;
    }
    
    if (asset.mediaType == PHAssetMediaTypeVideo || asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        NSString *PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource
                                                                    toFile:[NSURL fileURLWithPath:PATH_MOVIE_FILE]
                                                                   options:nil
                                                         completionHandler:^(NSError * _Nullable error) {
                                                             if (error) {
                                                                 result(nil, nil);
                                                             } else {
                                                                 result(PATH_MOVIE_FILE, fileName);
                                                             }
                                                         }];
    } else {
        result(nil, nil);
    }
}

//获取image
+ (void)getImageFromPHAsset:(PHAsset *)asset Complete:(Result)result {
//    __block NSData *data;
    
    PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
    if (asset.mediaType == PHAssetMediaTypeImage) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        options.networkAccessAllowed = YES;
        @autoreleasepool {
            [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                              options:options
                                                        resultHandler:
             ^(NSData *imageData,
               NSString *dataUTI,
               UIImageOrientation orientation,
               NSDictionary *info) {
                 if (result) {
                         if (imageData.length <= 0) {
                             result(nil, nil);
                         } else {
                             result(imageData, resource.originalFilename);
                         }
                 }
             }];
        }
    }else{
        //非图片
        result(nil,nil);
    }
}

- (void) getImageFromPHAsset: (PHAsset * ) asset Complete: (Result) result {
    
    __block NSData * data;
    
    PHAssetResource * resource = [[PHAssetResource assetResourcesForAsset: asset] firstObject];
    
    if (asset.mediaType == PHAssetMediaTypeImage) {
        
        PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
        
        options.version = PHImageRequestOptionsVersionCurrent;
        
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        options.synchronous = YES;
        [[PHImageManager defaultManager] requestImageDataForAsset: asset options: options resultHandler: ^(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info) {
            
            data = [NSData dataWithData: imageData];
            
        }];
        
    }
    
    if (result) {
        
        if (data.length <= 0) {
            
            result(nil, nil);
            
        } else {
            
            result(data, resource.originalFilename);
            
        }
        
    }
    
}


+ (void)getImageDataWithPHAsset:(PHAsset *)asset andCompleteBlock:(void(^)(NSString * filePath))block{
    PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
    NSString *fileName = @"tempUploadImage.jpg";
    if (resource.originalFilename) {
        fileName = resource.originalFilename;
    }
    if (asset.mediaType == PHAssetMediaTypeImage) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        options.networkAccessAllowed = YES;
        //[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]
        NSString *PATH_IMAGE_FILE = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"FMUpload"];
        NSFileManager * mgr = [NSFileManager defaultManager];
        if (![mgr fileExistsAtPath:PATH_IMAGE_FILE])
            [mgr createDirectoryAtPath:PATH_IMAGE_FILE withIntermediateDirectories:YES attributes:nil error:NULL];
        PATH_IMAGE_FILE = [PATH_IMAGE_FILE stringByAppendingPathComponent:fileName];
        [mgr removeItemAtPath:PATH_IMAGE_FILE error:nil];
        if (IOS9) {
            PHAssetResourceRequestOptions * opt =  [PHAssetResourceRequestOptions new];
            opt.networkAccessAllowed = YES;
            [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource toFile:[NSURL fileURLWithPath:PATH_IMAGE_FILE] options:opt completionHandler:^(NSError * _Nullable error) {
                if (error) {
                    block(nil);
                }else{
                    if([mgr fileExistsAtPath:PATH_IMAGE_FILE])
//                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(PATH_IMAGE_FILE);
//                        });
                    else
                        block(nil);
                }
            }];
        }
        else{
            NSLog(@"iOS 8.0 - iOS 9.0");
            [[PHImageManager defaultManager] requestImageDataForAsset: asset options: options resultHandler: ^(NSData * imageData, NSString * dataUTI, UIImageOrientation orientation, NSDictionary * info) {
                if (imageData) {
                    [imageData writeToFile:PATH_IMAGE_FILE atomically:YES];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(PATH_IMAGE_FILE);
                    });
                }else{
                    block(nil);
                }
            }];
        }
    }else{
        block(nil);
    }
}

////  创建缓存目录文件
//- (void)createDirectory:(NSString *)directory
//{
//    if (![self.fileManager fileExistsAtPath:directory]) {
//        [self.fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
//    }
//}

//获取视频
+ (void)getVideoFromPHAsset:(PHAsset *)asset Complete:(Result)result {
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *resource;
    
    for (PHAssetResource *assetRes in assetResources) {
        if (assetRes.type == PHAssetResourceTypePairedVideo ||
            assetRes.type == PHAssetResourceTypeVideo) {
            resource = assetRes;
        }
    }
    NSString *fileName = @"tempAssetVideo.mov";
    if (resource.originalFilename) {
        fileName = resource.originalFilename;
    }
    
    if (asset.mediaType == PHAssetMediaTypeVideo || asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        NSString *PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource
                                                                    toFile:[NSURL fileURLWithPath:PATH_MOVIE_FILE]
                                                                   options:nil
                                                         completionHandler:^(NSError * _Nullable error) {
                                                             if (error) {
                                                                 result(nil, nil);
                                                             } else {
                                                                 
                                                                 NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:PATH_MOVIE_FILE]];
                                                                 result(data, fileName);
                                                             }
                                                             [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE  error:nil];
                                                         }];
    } else {
        result(nil, nil);
    }
}


+(void)checkNetwork

{
    // 如果要检测网络状态的变化,必须用检测管理器的单例的startMonitoring
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    __block   BOOL network =  network ;  //
    __block   BOOL change =  change ;  //
    change = NO;
    network = NO;
    // 检测网络连接的单例,网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         switch (status) {
             case AFNetworkReachabilityStatusNotReachable:
             {
                 [MyAppDelegate.notification displayNotificationWithMessage:@"无网络" forDuration:1];
                 [PhotoManager shareManager].netStatus = FMNetStatusNoNet;
                [[NSNotificationCenter defaultCenter] postNotificationName:FM_NET_STATUS_NOT_WIFI_NOTIFY object:nil];
                 NSLog(@"无网络");
                 network = NO;
                 change = YES;
                 shouldUpload = NO;
                 break;
             }
             case AFNetworkReachabilityStatusReachableViaWiFi:
                 
             {
                 [MyAppDelegate.notification displayNotificationWithView:[FMNotifyView notifyViewWithMessage:@"无线网络"] forDuration:1];
//                [[JYNotify shareRemindView] showViewWithMessagetype:MessageTypeSuccess andMessage:@"无线网络"];
                [PhotoManager shareManager].netStatus = FMNetStatusWIFI;
                 [[NSNotificationCenter defaultCenter] postNotificationName:FM_NET_STATUS_WIFI_NOTIFY object:nil];
                 NSLog(@"WiFi网络");
                 network = YES;
                 change = YES;
                 shouldUpload = YES;
                 if (![PhotoManager shareManager].isUploading) {
                    if(IsEquallString(USER_SHOULD_SYNC_PHOTO, DEF_UUID))
                        [PhotoManager shareManager].canUpload = YES;
                 }
                 break;
             }
             case AFNetworkReachabilityStatusReachableViaWWAN:
             {
                 [MyAppDelegate.notification displayNotificationWithMessage:@"当前为移动网络" forDuration:1];
                  [PhotoManager shareManager].netStatus = FMNetStatusWWAN;
                 [[NSNotificationCenter defaultCenter] postNotificationName:FM_NET_STATUS_NOT_WIFI_NOTIFY object:nil];
                 network = YES;
                 change = YES;
                 shouldUpload = SHOULD_WLNN_UPLOAD;
                 break;
             }
             default:
                 break;
         }
     }];
    
}

-(void)setCanUpload:(BOOL)canUpload{
    _canUpload = canUpload;
    if (canUpload)
        [PhotoManager reStartUploader];
    else
        self.isUploading = NO;
    
}

+(void)reStartUploader{
    [[PhotoManager shareManager] startUploadPhotos];//上传照片
}


//标注是否可以上传（wifi）
BOOL shouldUpload = NO;
-(void)startUploadPhotos{
    @autoreleasepool {
        __weak typeof(self) weakSelf = self;
        [FMDBControl getDBPhotosWithCompleteBlock:^(NSArray<FMLocalPhoto *> *result) {
            if (result.count>0) {
                NSLog(@"%ld 张照片等待上传",(unsigned long)result.count);
                [weakSelf uploadImages:result success:^(NSArray *arr) {
                    NSLog(@"%@",arr);
                } failure:^{
                    
                }];
            }
            result = nil;
        }];
    }
}

-(void)uploadImages:(NSArray *)imageArr success:(void (^)(NSArray *))success failure:(void (^)())failure{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    __block NSUInteger currentIndex = 0;
    FMUploadHelper *uploadHelper = [FMUploadHelper sharedInstance];
    __weak typeof(uploadHelper) weakHelper = uploadHelper;
    __weak typeof(self) weakSelf = self;
    [PhotoManager shareManager].isUploading = YES;
    uploadHelper.singleFailureBlock = ^() {
        NSLog(@"上传失败");
        failure();
        [PhotoManager shareManager].isUploading = NO;
        return;
    };
    uploadHelper.singleSuccessBlock  = ^(NSString *url) {
        [array addObject:url];
        currentIndex++;
                NSLog(@"已上传%ld张,还需需要上传上传%ld张",(unsigned long)currentIndex,(unsigned long)imageArr.count-currentIndex);
//        NSString *currentIndexString = [NSString stringWithFormat:@"%ld",currentIndex];
//        NSString *allImageString = [NSString stringWithFormat:@"%ld",[imageArr count]];
//        NSDictionary *dict =[NSDictionary  dictionaryWithObjectsAndKeys:currentIndexString,@"currentImage",allImageString,@"allImage", nil];
        // 创建一个通知中心
//        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//        
//        [center postNotificationName:@"currentImage" object:nil userInfo:dict];
//        

        if ([array count] >= [imageArr count]) {
            success([array copy]);
            [PhotoManager shareManager].isUploading = NO;
            return;
        }
        else {
            if(_canUpload && shouldUpload){
                [weakSelf uploadImage:imageArr[currentIndex] success:weakHelper.singleSuccessBlock failure:weakHelper.singleFailureBlock];
            }else
                [PhotoManager shareManager].isUploading = NO;
        }
    };
    [self uploadImage:imageArr[0] success:weakHelper.singleSuccessBlock failure:weakHelper.singleFailureBlock];
}


- (void)startBackgroundSession
{
    __block UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"BackGround Session");
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    }];
}


- (void)uploadImage:(FMLocalPhoto *)photo success:(void (^)(NSString *url))success failure:(void (^)())failure{
    @autoreleasepool {
        if (shouldUpload && _canUpload) {
            PHAsset * asset = [[FMLocalPhotoStore shareStore] checkPhotoIsLocalWithLocalId:photo.localIdentifier];
            if(!asset){
                [self _uploadFailedWithNotFoundAsset:YES andLocalId:photo.localIdentifier];
                if (success) success(@"233");
                return ;
            }
            //检查是否为已上传
            @weakify(self);
            FMDTSelectCommand * scmd = [[FMDBSet shared].photo createSelectCommand];
            [scmd where:@"localIdentifier" equalTo:photo.localIdentifier];
            [scmd fetchArrayInBackground:^(NSArray *result) {
                if (result.count) {
                    FMLocalPhoto * p = result[0];
                    if (!p.uploadTime) {
                        [weak_self _uploadPhotoWithAsset:asset success:success failure:failure];
                    }else{
                        NSLog(@"********早就已上传*******");
                        if (success) success(@"233");
                    }
                }else
                    if (success) success(@"233");
            }];
        }else{
            NSLog(@"停止上传");
            if (failure) {
                failure();
            }
        }
    }
}

-(NSURLSessionConfiguration *)defaultConfig{
    static NSURLSessionConfiguration * config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [NSURLSessionConfiguration  backgroundSessionConfigurationWithIdentifier:@"com.wisnuc.background"];
    });
    return config;
}


-(void)_uploadPhotoWithAsset:(PHAsset *)asset success:(void (^)(NSString *url))success failure:(void (^)())failure{
    @weakify(self);
    dispatch_async([FMUtil setterBackGroundQueue], ^{
        [PhotoManager getImageDataWithPHAsset:asset andCompleteBlock:^(NSString *filePath) {
            if (filePath) {
                NSString * str = [FileHash sha256HashOfFileAtPath:filePath];
                if (!str) {
                    if (success)
                        success(@"123");
                    return ;
                }
                
//                 NSDictionary * dic = [NSDictionary dictionaryWithObject:str forKey:@"sha256"];
                NSString * url = [NSString stringWithFormat:@"%@media/%@",[JYRequestConfig sharedConfig].baseURL,str];
                NSDictionary * dic = [NSDictionary dictionaryWithObject:str forKey:@"sha256"];
                
                // 前台上传
                NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                    [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" fileName:@"file" mimeType:@"image/jpeg" error:nil];
                } error:nil];
                [request setValue:[NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
                _afManager.responseSerializer = [AFHTTPResponseSerializer serializer];
                NSURLSessionUploadTask *uploadTask;
                uploadTask = [_afManager
                              uploadTaskWithStreamedRequest:request
                              progress:^(NSProgress *uploadProgress){
                                  
                              }
                              completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                  NSLog(@"%@",responseObject);
                                  NSData *responseData = [NSData dataWithData:responseObject];
                                
                                
                                  NSString *result = [[NSString alloc] initWithData:responseData  encoding:NSUTF8StringEncoding];
                                  
                                    NSLog(@"%@",result);
//                                  NSDictionary *dicFromResponseData = [NSDictionary ]
                                  NSHTTPURLResponse * rep = (NSHTTPURLResponse *)response;
                                  NSLog(@"%ld",(long)rep.statusCode);
                                  [weak_self uploadComplete:(rep.statusCode == 200 || rep.statusCode == 500)
                                             andSha256:str
                                          withFilePath:filePath
                                              andAsset:asset
                                       andSuccessBlock:success
                                               Failure:failure];
                              }];
                [uploadTask resume];
            }
            else{
//                [weak_self _uploadFailedWithNotFoundAsset:NO andLocalId:asset.localIdentifier];
                if (success)
                    success(@"123");
            }
            
        }];
    });
}

-(void)_uploadFailedWithNotFoundAsset:(BOOL)notfound andLocalId:(NSString * )localId{
    if (notfound) {
        NSLog(@"本机未找到相关文件,跳过上传");
        FMDTUpdateCommand * ucmd = [[FMDBSet shared].photo createUpdateCommand];
        [ucmd fieldWithKey:@"degist" val:@"notfound"];
        [ucmd fieldWithKey:@"uploadTime" val:[NSDate getFormatDateWithDate:[NSDate date]]];
        [ucmd where:@"localIdentifier" equalTo:localId];
        [ucmd saveChangesInBackground:nil];
    }else{
        NSLog(@"跳过一个视频文件");
        FMDTUpdateCommand * ucmd = [[FMDBSet shared].photo createUpdateCommand];
        [ucmd fieldWithKey:@"degist" val:@"video"];
        [ucmd where:@"localIdentifier" equalTo:localId];
        [ucmd saveChangesInBackground:^{
            [ucmd fieldWithKey:@"uploadTime" val:[NSDate getFormatDateWithDate:[NSDate date]]];
            [ucmd where:@"localIdentifier" equalTo:localId];
            [ucmd saveChangesInBackground:nil];
        }];
    }
    
}


-(void)uploadComplete:(BOOL)isSuccess andSha256:(NSString *)sha256Str withFilePath:(NSString *)filePath  andAsset:(PHAsset *)asset andSuccessBlock:(void (^)(NSString *url))success Failure:(void (^)())failure{
    NSString * str = sha256Str;
    
    [[FMFileManager shareManager] removeFileAtPath:filePath];
    
    if (isSuccess) {
        dispatch_async([FMUtil setterCacheQueue], ^{
            FMDTUpdateCommand * ucmd = [[FMDBSet shared].photo createUpdateCommand];
            [ucmd fieldWithKey:@"degist" val:str];
            [ucmd where:@"localIdentifier" equalTo:asset.localIdentifier];
            [ucmd saveChangesInBackground:^{
//                [ucmd fieldWithKey:@"uploadTime" val:[NSDate getFormatDateWithDate:[NSDate date]]];
//                [ucmd where:@"localIdentifier" equalTo:asset.localIdentifier];
//                [ucmd saveChangesInBackground:^{
//                    
//                }];
                //添加上传记录
                NSLog(@"上传的LocalID: ---> %@", asset.localIdentifier);
                FMDTInsertCommand * icmd = FMDT_INSERT([FMDBSet shared].syncLogs);
                FMSyncLogs * log = [FMSyncLogs new];
                log.userId =DEF_UUID;
                log.photoHash = str;
                log.localId = asset.localIdentifier;
                [icmd add:log];
                [icmd saveChangesInBackground:^{
                    
                }];
                NSLog(@"上传成功！%@",str);
            }];
            if (success) success(str);
        });
    }else{ //失败
        NSLog(@"上传请求 链接 失败");
        if (failure) failure();
    }
}

+(NSString *)getUUID{
    __block NSString * uuid = DEVICE_UUID;
    if (uuid.length<=0) {
        __block BOOL completed = NO;
        NSCondition *condition = [[NSCondition alloc] init];
        AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
        [manager POST:[NSString stringWithFormat:@"%@libraries",[JYRequestConfig sharedConfig].baseURL] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSString * str = responseObject[@"uuid"];
            FMConfigInstance.deviceUUID = str;
            uuid = str;
            completed = YES;
            [condition signal];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"获取DeviceUUID失败,%@",error);
            completed = YES;
            [condition signal];
        }];
        [condition lock];
        while (!completed) {
            [condition wait];
        }
        [condition unlock];
    }
    return uuid;
}


+(void)managerCheckPhotoIsLocalWithPhotohash:(NSString *)degist
                            andCompleteBlock:(void(^)(NSString * localId,NSString * photoHash,BOOL isLocal))block{
    NSAssert(degist != nil, @"degist 不能为空");
    FMLocalPhotoStore * store = [FMLocalPhotoStore shareStore];
    NSString * localId = [store checkPhotoIsLocalWithDigest:degist];
    if (localId)
        block(localId,degist,YES);
    else
        block(nil,degist,NO);
}

+(void)calculateDigestWhenPhotoHaveNot{
    dispatch_async([FMUtil setterLowQueue], ^{
        FMDBSet * set = [FMDBSet shared];
        FMDTSelectCommand * scmd = FMDT_SELECT(set.photo);
        [scmd whereIsNull:@"degist"];
        NSArray * photosArr = [scmd fetchArray];
        NSLog(@"共%ld需要计算hash",(unsigned long)photosArr.count);
        if (photosArr.count) { //计算digest
            NSMutableArray *array = [[NSMutableArray alloc] init];
            __block NSUInteger currentIndex = 0;
            FMCalculateHelper * helper = [FMCalculateHelper sharedInstance];
            __weak typeof(helper) weakHelper = helper;
            __weak typeof(self) weakSelf = self;
            weakHelper.singleSuccessBlock  = ^(BOOL success,NSString * digest) {
                if (success) {
                    [array addObject:digest];
                }
                currentIndex++;
//                NSLog(@"已计算%ld张,还需要计算%ld张",(unsigned long)currentIndex,(unsigned long)photosArr.count-currentIndex);
                if (currentIndex >= [photosArr count] ) {
//                    NSLog(@"计算完成");
                    return;
                }
                else {
                    [weakSelf calculateDigestWithLocalId:((FMLocalPhoto *)photosArr[currentIndex]).localIdentifier andCompleteBlock:weakHelper.singleSuccessBlock];
                }
            };
            [self calculateDigestWithLocalId:((FMLocalPhoto *)photosArr[0]).localIdentifier andCompleteBlock:weakHelper.singleSuccessBlock];
        }
    });
}


+(void)calculateDigestWithLocalId:(NSString *)localId andCompleteBlock:(void(^)(BOOL success,NSString * digest))block{
    NSAssert(!IsNilString(localId), @"localId can not be nil when calculate digest");
    PHAsset * asset = [[FMLocalPhotoStore shareStore] checkPhotoIsLocalWithLocalId:localId];
    if (asset) {
        [self getImageDataWithPHAsset:asset andCompleteBlock:^(NSString *filePath) {
            if (filePath) {
                dispatch_async([FMUtil setterLowQueue], ^{
                    NSString * localDegist = [FileHash sha256HashOfFileAtPath:filePath];
                    [FMFileManagerInstance removeFileAtPath:filePath];
                    if (localDegist) {
                        FMDTUpdateCommand * ucmd = [[FMDBSet shared].photo createUpdateCommand];
                        [ucmd fieldWithKey:@"degist" val:localDegist];
                        [ucmd where:@"localIdentifier" equalTo:asset.localIdentifier];
                        [ucmd saveChangesInBackground:^{
                            [[FMLocalPhotoStore shareStore] addDigestToStore:localDegist andLocalId:localId];
                            //                        [[NSNotificationCenter defaultCenter]postNotificationName:FM_CALCULATE_HASH_SUCCESS_NOTIFY object:@{asset.localIdentifier:localDegist}];
                            if (block) block(YES,localDegist);
                            
                        }];
                    }else
                        if (block) block(NO,nil);
                });
                
            }else
                if (block) block(NO,nil);
        }];
    }else
        if (block) block(NO,nil);
}



+(NSString *) getSha256WithAsset:(PHAsset *)asset{
    __block NSString * localDegist = @"";
    [PhotoManager getImageFromPHAsset:asset Complete:^(NSData *fileData, NSString *fileName) {
        localDegist = [CocoaSecurity sha256WithData:fileData].hexLower;
    }];
    return localDegist;
}

#pragma mark - NSurlSessionDelegate

@end
