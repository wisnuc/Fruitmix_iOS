
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

#import "FMUploadFileAPI.h"

#import "EntriesModel.h"

#import "FMUserLoginViewController.h"
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
    CFAbsoluteTime  _start;
    CFAbsoluteTime _end;
    BOOL _switchOn;
    NSNumber *_allCount;
    NSOperationQueue *_queue;
//    NSMutableArray *_imageUploadArr;
//    NSTimer *_reachabilityTimer;
    
}

@property (nonatomic,weak) NSTimer *reachabilityTimer;
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
//        _canUpload = YES;
       
        _uploadarray = [NSMutableArray arrayWithCapacity:0];
//         [FMDBControl asyncLoadPhotoToDB];
//        _afManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[self defaultConfig]];
//        _afManager.attemptsToRecreateUploadTasksForBackgroundSessions = YES;
//        _afManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _afManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        _getImageQueue = [[NSOperationQueue alloc]init];
        _getImageQueue.maxConcurrentOperationCount = 1;
        _getImageQueue.qualityOfService = NSQualityOfServiceUserInitiated;
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
      
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(siftUploadArrCompleteBlock:) name:@"siftPhoto" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:@"enterForeground" object:nil];
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
    @weaky(self)
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
                            
//                            [FMUserLoginViewController siftPhotoFromNetwork];
//                            [weak_self uploadActionForChange];
//                            BOOL switchOn =[[NSUserDefaults standardUserDefaults] boolForKey:KSWITHCHON];
                            if (IsEquallString(USER_SHOULD_SYNC_PHOTO, DEF_UUID) && detail.insertedObjects.count>0) {
//                                if (switchOn &&_canUpload && shouldUpload) {
//                                [PhotoManager shareManager].canUpload = YES;
//                                }
//                                  [_uploadarray removeAllObjects];
//                                [weak_self siftUploadArrCompleteBlock:^(NSMutableArray *uploadArr) {
//                                [[NSNotificationCenter defaultCenter] postNotificationName:@"photoChange" object:nil];
//                                }];
                            }
                      
                        });
                    }
                }];
            }
        });
    }
}

- (void)cleanUploadTask{
    _canUpload = NO;
    startUpload = YES;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [_queue cancelAllOperations];
        [_uploadarray removeAllObjects];
        _uploadarray = nil;
    });
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [_reachabilityTimer invalidate];
    _reachabilityTimer = nil;
    [self cleanUploadTask];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"siftPhoto" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"enterForeground" object:nil];
    
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
        NSString *PATH_IMAGE_FILE ;
        if (NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).count>0) {
            PATH_IMAGE_FILE = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"FMUpload"];
        }else{
            return;
        }
//        NSString *PATH_IMAGE_FILE = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"FMUpload"];
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
    network = YES;
    NSInteger s;
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
                 if (!network) {
                     if (![PhotoManager shareManager].isUploading ) {
                         if(IsEquallString(USER_SHOULD_SYNC_PHOTO, DEF_UUID)){
                            [PhotoManager shareManager].canUpload = YES;
                         }
                     }

                 }
                 shouldUpload = YES;
                 network = YES;
                 change = YES;
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

- (void)uploadActionForChange{
//    if (_isUploading) {
//        [PhotoManager shareManager].canUpload = NO;
//    }
//      [PhotoManager shareManager].canUpload = YES;
}


- (void)refresh{
   BOOL switchOn = SWITHCHON_BOOL
    if (switchOn && shouldUpload) {
//        if (_uploadarray.count == 0) {
            self.canUpload = NO;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.canUpload = YES;
        });
    }
}

-(void)setCanUpload:(BOOL)canUpload{
    _canUpload = canUpload;
    if (canUpload){
        [PhotoManager reStartUploader];
    }else{
        [_reachabilityTimer invalidate];
        _reachabilityTimer = nil;
        self.isUploading = NO;
        [_queue cancelAllOperations];
    }
}

+(void)reStartUploader{
    if (startUpload) {
        [[PhotoManager shareManager] startUploadPhotos];//上传照片
    }
   
     BOOL swichOn = SWITHCHON_BOOL;
    if (swichOn) {
        MyNSLog(@"开关状态======>备份开关状态：开启");
    }else{
         MyNSLog(@"开关状态======>备份开关状态：关闭");
    }
    
}


- (void)siftUploadArrCompleteBlock:(void (^)(NSMutableArray *uploadArr))block{
    @weaky(self)
    BOOL switchOn = SWITHCHON_BOOL;
    if (_uploadarray) {
        [_uploadarray removeAllObjects];
    }
    NSString *entryuuid = PHOTO_ENTRY_UUID;
    if (entryuuid.length == 0) {
        [FMUploadFileAPI getDriveInfoCompleteBlock:^(BOOL successful) {
            if (successful) {
                [FMUploadFileAPI getDirectoriesForPhotoCompleteBlock:^(BOOL successful) {
                    if (successful) {
                        [FMUploadFileAPI creatPhotoDirEntryCompleteBlock:^(BOOL successful) {
                            if (successful) {
                                [FMUploadFileAPI getDirEntryWithUUId:entryuuid success:^(NSURLSessionDataTask *task, id responseObject) {
                                    MyNSLog (@"请求的URL======>%@\n获取NAS照片的responseObject======>:%@",task.currentRequest.URL,responseObject);
                                    NSArray * arr ;
                                    if (!KISCLOUD) {
                                        NSDictionary * dic = responseObject;
                                        arr = dic[@"entries"];
                                    }else {
                                        NSDictionary * dic = responseObject;
                                        NSDictionary * entriesDic = dic[@"data"];
                                        arr = entriesDic[@"entries"];
                                    }
                                    NSMutableArray * photoArrHash = [NSMutableArray arrayWithCapacity:0];
                         
                                    for (NSDictionary *dic in arr) {
                                        FMNASPhoto *nasPhoto = [FMNASPhoto yy_modelWithJSON:dic];
                                        [photoArrHash addObject:nasPhoto.fmhash];
                                    }
                                    MyNSLog (@"NAS里的照片的所有Hash======>%@",photoArrHash);
                                    MyNSLog (@"NAS里的照片数量======>%u",photoArrHash.count);
//                                    [FMDBControl asyncLoadPhotoToDBWithCompleteBlock:^(NSArray *addArr) {
                                        [FMDBControl getDBAllLocalPhotosWithCompleteBlock:^(NSArray<FMLocalPhoto *> *result) {
                                          
                                            NSMutableArray *localPhotoHashArr = [NSMutableArray arrayWithCapacity:0];
                                            for (FMLocalPhoto * p in result) {
                                                if (p.degist.length >0) {
                                                    [localPhotoHashArr addObject:p.degist];
                                                }
                                            }
                                            
                                            //              MyNSLog (@"本地照片的所有Hash======>%@",localPhotoHashArr);
                                            
                                            //                        NSPredicate * filterPredicate2 = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",photoArrHash];
                                            //                        NSArray * filter2 = [localPhotoHashArr filteredArrayUsingPredicate:filterPredicate2];
                                            NSSet *localPhotoHashArrSet = [NSSet setWithArray:localPhotoHashArr];
                                            NSSet *photoArrHashSet = [NSSet setWithArray:photoArrHash];
                                            _allCount = [NSNumber numberWithUnsignedInteger:[localPhotoHashArrSet allObjects].count];
                                            NSMutableArray *uploadArray = [NSMutableArray arrayWithCapacity:0];
                                            for (NSString *hashString in [localPhotoHashArrSet allObjects]) {
                                                if (![[photoArrHashSet allObjects] containsObject:hashString]) {
                                                    [uploadArray addObject:hashString];
                                                }
                                            }
//                                            NSPredicate * filterPredicate1 = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",[photoArrHashSet allObjects]];
//                                            NSArray * filter1 = [[localPhotoHashArrSet allObjects] filteredArrayUsingPredicate:filterPredicate1];
                                            //                        //找到在arr1中不在数组arr2中的数据
                                            //                        NSPredicate * filterPredicate2 = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",localPhotoHashArr];
                                            //                        NSArray * filter2 = [photoArrHash filteredArrayUsingPredicate:filterPredicate2];
                                            //拼接数组
//                                            NSMutableArray *array = [NSMutableArray arrayWithArray:filter1];
//                                            [array addObjectsFromArray:filter1];
                                            NSSet *arrSet = [NSSet setWithArray:uploadArray];
                                            NSMutableArray *toUploadArray = [NSMutableArray arrayWithArray:[arrSet allObjects]];
                                            MyNSLog(@"比对结果Array=======>%@",uploadArray);
                                            block (toUploadArray);
                                        }];
//                                    }];
                                    
                                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                    NSHTTPURLResponse * rep = (NSHTTPURLResponse *)task.response;
                                    if (rep.statusCode == 404) {
                                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PHOTO_ENTRY_UUID_STR];
                                    }
                                    startUpload = YES;
                                    if (switchOn  && shouldUpload) {
                                        [[PhotoManager shareManager] setCanUpload:YES];
                                    }
                                }];

                                }
                        }];
                    }
                }];
            }
        }];
    }else{
    [FMUploadFileAPI getDirEntryWithUUId:entryuuid success:^(NSURLSessionDataTask *task, id responseObject) {
        MyNSLog (@"请求的URL======>%@\n获取NAS照片的responseObject======>:%@",task.currentRequest.URL,responseObject);
        NSArray * arr ;
        if (!KISCLOUD) {
            NSDictionary * dic = responseObject;
            arr = dic[@"entries"];
        }else {
            NSDictionary * dic = responseObject;
            NSDictionary * entriesDic = dic[@"data"];
            arr = entriesDic[@"entries"];
        }
        NSMutableArray * photoArrHash = [NSMutableArray arrayWithCapacity:0];
        
//        NSArray * arr = [dic objectForKey:@"entries"];
        for (NSDictionary *dic in arr) {
            FMNASPhoto *nasPhoto = [FMNASPhoto yy_modelWithJSON:dic];
            [photoArrHash addObject:nasPhoto.fmhash];
        }
        MyNSLog (@"NAS里的照片的所有Hash======>%@",photoArrHash);
        MyNSLog (@"NAS里的照片数量======>%lu",(unsigned long)photoArrHash.count);
//        [FMDBControl asyncLoadPhotoToDBWithCompleteBlock:^(NSArray *addArr) {
            [FMDBControl getDBAllLocalPhotosWithCompleteBlock:^(NSArray<FMLocalPhoto *> *result) {
               
                NSMutableArray *localPhotoHashArr = [NSMutableArray arrayWithCapacity:0];
                for (FMLocalPhoto * p in result) {
                    if (p.degist.length >0) {
                        [localPhotoHashArr addObject:p.degist];
                    }
                }
                //              MyNSLog (@"本地照片的所有Hash======>%@",localPhotoHashArr);
                
                //                        NSPredicate * filterPredicate2 = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",photoArrHash];
                //                        NSArray * filter2 = [localPhotoHashArr filteredArrayUsingPredicate:filterPredicate2];
                NSSet *localPhotoHashArrSet = [NSSet setWithArray:localPhotoHashArr];
                NSSet *photoArrHashSet = [NSSet setWithArray:photoArrHash];
                _allCount = [NSNumber numberWithUnsignedInteger:[localPhotoHashArrSet allObjects].count];
                NSMutableArray *uploadArray = [NSMutableArray arrayWithCapacity:0];
                for (NSString *hashString in [localPhotoHashArrSet allObjects]) {
                    if (![[photoArrHashSet allObjects] containsObject:hashString]) {
                        [uploadArray addObject:hashString];
                    }
                }
                NSPredicate * filterPredicate1 = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",[photoArrHashSet allObjects]];
                NSArray * filter1 = [[localPhotoHashArrSet allObjects] filteredArrayUsingPredicate:filterPredicate1];
                //                        //找到在arr1中不在数组arr2中的数据
                //                        NSPredicate * filterPredicate2 = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",localPhotoHashArr];
                //                        NSArray * filter2 = [photoArrHash filteredArrayUsingPredicate:filterPredicate2];
                //拼接数组
                NSMutableArray *array = [NSMutableArray arrayWithArray:filter1];
                [array addObjectsFromArray:filter1];
                NSSet *arrSet = [NSSet setWithArray:uploadArray];
                NSMutableArray *toUploadArray = [NSMutableArray arrayWithArray:[arrSet allObjects]];
                MyNSLog(@"比对结果Array=======>%@",uploadArray);
                block (toUploadArray);
//        }];
    }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSHTTPURLResponse * rep = (NSHTTPURLResponse *)task.response;
        if (rep.statusCode == 404) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:PHOTO_ENTRY_UUID_STR];
        }
          startUpload = YES;
        if (switchOn  && shouldUpload) {
            [[PhotoManager shareManager] setCanUpload:YES];
        }
    }];
}
}

//static  NSInteger overCount = 0;
//标注是否可以上传（wifi）
BOOL shouldUpload = NO;
BOOL startUpload = YES;
-(void)startUploadPhotos{
    
        __weak typeof(self) weakSelf = self;
            if (_uploadarray.count == 0) {
                [self siftUploadArrCompleteBlock:^(NSMutableArray *uploadArr) {
                      startUpload = NO;
                     _uploadarray = [NSMutableArray arrayWithArray:uploadArr];
                  MyNSLog(@"回调后判断是否进入上传序列");
                    dispatch_queue_t queue = dispatch_queue_create("tk.bourne.Queue", DISPATCH_QUEUE_SERIAL);
                    //2.把任务添加到队列中执行
                    dispatch_barrier_async(queue, ^(){
                    if (_uploadarray.count>0){
                        [weakSelf uploadImages:_uploadarray success:^(NSArray *arr) {

                        } failure:^{
                        }];
                        }else if (_uploadarray.count ==0) {
//                    if (!_reachabilityTimer) {
//                        _reachabilityTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
////                        [_reachabilityTimer fire];
//                    }
                    
                }
 });
                }];
   
            }else{
                 startUpload = NO;
                dispatch_queue_t queue = dispatch_queue_create("tk.bourne.Queue", DISPATCH_QUEUE_SERIAL);
                //2.把任务添加到队列中执行
                dispatch_barrier_async(queue, ^(){
                [weakSelf uploadImages:_uploadarray success:^(NSArray *arr) {
                 if (_uploadarray.count==0) {
//                     if (!_reachabilityTimer) {
//                     _reachabilityTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
//                         [_reachabilityTimer fire];
//                 }
                }
                } failure:^{
                }];
            });
        }
    if (!_reachabilityTimer) {
        _reachabilityTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    }
}

-(void)uploadImages:(NSArray *)imageArr success:(void (^)(NSArray *))success failure:(void (^)())failure{
//    MyNSLog(@"要上传的所有照片数量======>%lu",(unsigned long)imageArr.count);
//    NSCondition *condition = [[NSCondition alloc]init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    __block NSUInteger currentIndex = 0;
     BOOL switchOn = SWITHCHON_BOOL;
    FMUploadHelper *uploadHelper = [FMUploadHelper sharedInstance];
    __weak typeof(uploadHelper) weakHelper = uploadHelper;
    __weak typeof(self) weakSelf = self;
    [PhotoManager shareManager].isUploading = YES;
       uploadHelper.singleFailureBlock = ^() {
        NSLog(@"上传失败");
        if (_uploadarray.count == 0) {
               MyNSLog(@"传完了");
            [[NSNotificationCenter defaultCenter]postNotificationName:@"uploadOverNoti" object:nil];
            [PhotoManager shareManager].canUpload = YES;
            if (!_reachabilityTimer) {
                _reachabilityTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
            }
    
        }

        failure();
//        if (_canUpload && shouldUpload && switchOn) {
//         [_uploadarray removeObjectAtIndex:currentIndex];
//          [PhotoManager shareManager].canUpload = YES;
//        }
//        return;
    };
    uploadHelper.singleSuccessBlock  = ^(NSString *url) {
        [array addObject:url];
        currentIndex++;
        
        MyNSLog(@"要上传的所有照片数量======>%lu",(unsigned long)_uploadarray.count);
//        MyNSLog(@"要上传的所有照片Hash======>%@",imageArr);
        if (_uploadarray.count == 0) {
            MyNSLog(@"传完了");

        }
        if (!_canUpload) {
            if (_reachabilityTimer) {
                [_reachabilityTimer invalidate];
                _reachabilityTimer = nil;
            }
            MyNSLog(@"上传通道关闭");
        }
      
//     NSLog(@"%ld张=========%ld张",(unsigned long)[array count],(unsigned long)[imageArr count]);
        if ([_uploadarray count] <1) {
            success([array copy]);
     
        [[NSNotificationCenter defaultCenter]postNotificationName:@"uploadOverNoti" object:nil];
        [PhotoManager shareManager].canUpload = YES;
            if (!_reachabilityTimer) {
              _reachabilityTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
            }
        }
        else {
            
            if(_canUpload && shouldUpload){
                @autoreleasepool {
                  MyNSLog(@"上传返回成功，即将上传下一张");

               _queue  = [[NSOperationQueue alloc] init];
                if(imageArr.count>0){
                    if (_queue.isSuspended) {
                        MyNSLog(@"线程暂停");
                        [_queue cancelAllOperations];
                        return ;
                    }
                    _queue.maxConcurrentOperationCount = 1;
                    // 2. 添加操作到队列中：addOperationWithBlock:
                    [_queue addOperationWithBlock:^{
                         MyNSLog(@"加入队列上传");
                         MyNSLog (@"成功返回后要传的照片Hash=====>%@",_uploadarray[0]);
                        [weakSelf uploadImage:_uploadarray[0] success:weakHelper.singleSuccessBlock failure:weakHelper.singleFailureBlock];
                         MyNSLog(@"%@",[NSThread currentThread]);
                    }];
                }else{
                    [_queue cancelAllOperations];
                    return ;
                }
            }
            }else{
                [PhotoManager shareManager].isUploading = NO;
            }
        }
    };
    
    if(_canUpload && shouldUpload && switchOn){
        if(imageArr.count>0){
            MyNSLog(@"进入上传队列");
            MyNSLog (@"要传的照片Hash=====>%@",_uploadarray[0]);
            [self uploadImage:_uploadarray[0] success:weakHelper.singleSuccessBlock failure:weakHelper.singleFailureBlock];
        }
    }
}

- (void)startBackgroundSession
{
    __block UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"BackGround Session");
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    }];
}

- (void)applicationWillEnterForeground{
//    BOOL switch_bool = SWITHCHON_BOOL;
//    [_uploadarray removeAllObjects];
//    if (switch_bool && _canUpload) {
//        _canUpload = YES;
//    }
}

- (void)uploadImage:(NSString *)photoHash success:(void (^)(NSString *url))success failure:(void (^)(void))failure{
    
    _start = CFAbsoluteTimeGetCurrent();
//     MyNSLog(@"每张上传照片开始时间：%f",_start);
    BOOL switchOn = SWITHCHON_BOOL;
    @autoreleasepool {
        if (shouldUpload && _canUpload) {
            MyNSLog(@"获取Asset");
            FMLocalPhotoStore * store = [FMLocalPhotoStore shareStore];
            PHAsset * asset = [store checkPhotoIsLocalWithLocalId:[store checkPhotoIsLocalWithDigest:photoHash]];
            
            if(!asset){
                [self _uploadFailedWithNotFoundAsset:YES andLocalId:[store checkPhotoIsLocalWithDigest:photoHash]];
                @synchronized(self){
                if (_uploadarray.count >0 && _uploadarray !=nil) {
                     [_uploadarray removeObjectAtIndex:0];
                }
                }
                if (switchOn && _canUpload &&shouldUpload) {
                    [PhotoManager shareManager].canUpload = YES;
                }
                if (success) success(@"233");
                return ;
            }
            //检查是否为已上传
            @weaky(self);
//            FMDTSelectCommand * scmd = [[FMDBSet shared].photo createSelectCommand];
//            [scmd where:@"localIdentifier" equalTo:photo.localIdentifier];
//            [scmd fetchArrayInBackground:^(NSArray *result) {
//                if (result.count) {
//                    FMLocalPhoto * p = result[0];
////                    NSLog(@"%@",p.uploadTime);
//                    if (!p.uploadTime) {
            if (!_canUpload) {
                MyNSLog(@"上传通道被关闭(获取Assets时)");
            }
            
            if (switchOn && _canUpload &&shouldUpload) {
                MyNSLog(@"即将进入请求");
               [weak_self _uploadPhotoWithAsset:asset success:success failure:failure];
            }
//                    }else{
//                        NSLog(@"********早就已上传*******");
//                        if (success) success(@"233");
//                    }
//                }else
//                    if (success) success(@"233");
//            }];
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
    @weaky(self);
    MyNSLog(@"即将进入请求");
//typedef void(^successBlock)(NSString *url);
//    successBlock = success;
//    dispatch_async([FMUtil setterBackGroundQueue], ^{
        [PhotoManager getImageDataWithPHAsset:asset andCompleteBlock:^(NSString *filePath) {
        
            if (filePath) {
                NSString * hashStr = [FileHash sha256HashOfFileAtPath:filePath];
                MyNSLog(@"localId:%@,hashStr:%@",asset.localIdentifier,hashStr);
                if (!hashStr) {
                    if (success)
                        success(@"123");
                    return ;
                }
               BOOL switchOn = SWITHCHON_BOOL;
                    startUpload = YES;
//                __block BOOL completed = NO;
//                NSCondition *condition = [[NSCondition alloc] init];
//                @synchronized(self){
                if (_canUpload && switchOn) {
                dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
                    //2.把任务添加到队列中执行
                dispatch_async(queue, ^{
                NSString *entryUUID = PHOTO_ENTRY_UUID;
                NSLog(@"%@",entryUUID);
                if (entryUUID.length==0) {
                  [FMUploadFileAPI getDriveInfoCompleteBlock:^(BOOL successful) {
                      if (successful) {
                          [FMUploadFileAPI getDirectoriesForPhotoCompleteBlock:^(BOOL successful) {
                              if (successful) {
                                  [FMUploadFileAPI creatPhotoDirEntryCompleteBlock:^(BOOL successful) {
                                      if (successful) {
                                            NSString *entryuuid = PHOTO_ENTRY_UUID;
                                          [FMUploadFileAPI getDirEntryWithUUId:entryuuid success:^(NSURLSessionDataTask *task, id responseObject) {
                                              NSArray * arr ;
                                              if (!KISCLOUD) {
                                                  NSDictionary * dic = responseObject;
                                                  arr = dic[@"entries"];
                                              }else {
                                                  NSDictionary * dic = responseObject;
                                                  NSDictionary * entriesDic = dic[@"data"];
                                                  arr = entriesDic[@"entries"];
                                              }
                                              if (arr.count >0) {
                                               
                                                  [FMUploadFileAPI uploadDirEntryWithFilePath:filePath success:^(NSURLSessionDataTask *task, id responseObject) {
                                                      NSHTTPURLResponse * rep = (NSHTTPURLResponse *)task.response;
                                                      
                                                      [weak_self uploadComplete:(rep.statusCode == 200)
                                                                      andSha256:hashStr
                                                                   withFilePath:filePath
                                                                       andAsset:asset
                                                                andSuccessBlock:success
                                                                        Failure:failure];
//                                                              [condition signal];
                                                  } failure:^(NSURLSessionDataTask *task, NSError *error){
                                                      [self errorActionWithTask:task HashString:hashStr];
                                                  } otherFailure:^(NSString *null) {
//                                                              [condition signal];
                                                       [self removeNullWithString:null filePathHash:hashStr];
//                                                              [condition signal];
                                                  }];

                                              }else{
//
                                                          [FMUploadFileAPI uploadDirEntryWithFilePath:filePath success:^(NSURLSessionDataTask *task, id responseObject) {
                                                              NSHTTPURLResponse * rep = (NSHTTPURLResponse *)task.response;
                                                              
                                                              [weak_self uploadComplete:(rep.statusCode == 200)
                                                                              andSha256:hashStr
                                                                           withFilePath:filePath
                                                                               andAsset:asset
                                                                        andSuccessBlock:success
                                                                                Failure:failure];
//                                                              [condition signal];
                                                          } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                               [self errorActionWithTask:task HashString:hashStr];
//                                                            [condition signal];
                                                          } otherFailure:^(NSString *null) {
                                                               [self removeNullWithString:null filePathHash:hashStr];
//                                                              [condition signal];
                                                          }];
//                                                         [condition unlock];
//                                                      }else{
//                                                          
//                                                      }
//                                                  }];
  
                                              }
                                         
                                          } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                              NSHTTPURLResponse * rep = (NSHTTPURLResponse *)task.response;
                                              if (rep.statusCode == 404) {
                                                  [[NSUserDefaults standardUserDefaults] removeObjectForKey:PHOTO_ENTRY_UUID_STR];
                                              }
                                              if (switchOn  && shouldUpload) {
                                                  [[PhotoManager shareManager] setCanUpload:YES];
                                              }
                                          }];
                                      }
                                  }];
                              }
                        }];
                      }
                  }];
                }else{
                     if (switchOn &&_canUpload && shouldUpload) {
                                [FMUploadFileAPI uploadDirEntryWithFilePath:filePath success:^(NSURLSessionDataTask *task, id responseObject) {
                                    MyNSLog(@"上传照片Hash%@",hashStr);
                                NSHTTPURLResponse * rep = (NSHTTPURLResponse *)task.response;
                                [weak_self uploadComplete:(rep.statusCode == 200)
                                                andSha256:hashStr
                                             withFilePath:filePath
                                                 andAsset:asset
                                          andSuccessBlock:success
                                                  Failure:failure];
                 
                            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                  [self errorActionWithTask:task HashString:hashStr];

                            } otherFailure:^(NSString *null) {
                                [self removeNullWithString:null filePathHash:hashStr];
                            }];
                            }
            
                }
            });
  
            }
            
            else{
//                [weak_self _uploadFailedWithNotFoundAsset:NO andLocalId:asset.localIdentifier];
                if (success)
                    success(@"123");
            }
         }
        }];
//    });
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
           startUpload = YES;
//        dispatch_async([FMUtil setterCacheQueue], ^{
//            FMDTUpdateCommand * ucmd = [[FMDBSet shared].photo createUpdateCommand];
//            [ucmd fieldWithKey:@"degist" val:str];
//            [ucmd where:@"localIdentifier" equalTo:asset.localIdentifier];
//            [ucmd saveChangesInBackground:^{
//                [ucmd fieldWithKey:@"uploadTime" val:[NSDate getFormatDateWithDate:[NSDate date]]];
//                [ucmd where:@"localIdentifier" equalTo:asset.localIdentifier];
//                [ucmd saveChangesInBackground:^{
//                    
//                }];
                //添加上传记录
//                NSLog(@"上传的LocalID: ---> %@", asset.localIdentifier);
//                FMDTInsertCommand * icmd = FMDT_INSERT([FMDBSet shared].syncLogs);
//                FMSyncLogs * log = [FMSyncLogs new];
//                log.userId =DEF_UUID;
//                log.photoHash = str;
//                log.localId = asset.localIdentifier;
//                [icmd add:log];
//                [icmd saveChangesInBackground:^{
//                    
//                }];
//                NSMutableArray *uploadImageArr = [NSMutableArray arrayWithCapacity:0];
//                NSMutableArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"uploadImageArr"];
//                if (array) {
//                    [uploadImageArr addObjectsFromArray:array];
//                    
//                }else {
//                    uploadImageArr = [NSMutableArray arrayWithCapacity:0];
//                }
                if (_uploadarray.count >0) {
                    [_uploadarray removeObjectAtIndex:0];
                }
               MyNSLog(@"新算出来的已经上传的数量👌====>%lu",[_allCount unsignedIntegerValue] - _uploadarray.count);
               NSNumber *number = [NSNumber numberWithUnsignedInteger:[_allCount unsignedIntegerValue] - _uploadarray.count];
               [[NSUserDefaults standardUserDefaults] setObject:number forKey: @"addCount"];
               [[NSUserDefaults standardUserDefaults] synchronize];
//                [uploadImageArr addObject:sha256Str];
        
//                [[NSUserDefaults standardUserDefaults] setObject:uploadImageArr forKey:@"uploadImageArr"];
//                [[NSUserDefaults standardUserDefaults] synchronize];
                _end = CFAbsoluteTimeGetCurrent();
                MyNSLog(@"上传成功！该照片Hash=====>%@",sha256Str);
                MyNSLog(@"结束时间%f======>",_end);
                MyNSLog(@"上传一张用时时间%f======>",_end-_start);
                NSLog(@"上传成功！%@",str);
    //            }];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"backUpProgressChange" object:nil];
            if (success) success(str);
            
     
    }else{ //失败
        [self saveUploadArrayWithHash:sha256Str];
        if (failure) failure();
    }
}

//+(NSString *)getUUID{
//    __block NSString * uuid = DEVICE_UUID;
//    if (uuid.length<=0) {
//        __block BOOL completed = NO;
//        NSCondition *condition = [[NSCondition alloc] init];
//        AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
//        manager.requestSerializer = [AFJSONRequestSerializer serializer];
//        [manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
//        [manager POST:[NSString stringWithFormat:@"%@libraries",[JYRequestConfig sharedConfig].baseURL] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSString * str = responseObject[@"uuid"];
//            FMConfigInstance.deviceUUID = str;
//            uuid = str;
//            completed = YES;
//            [condition signal];
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            NSLog(@"获取DeviceUUID失败,%@",error);
//            completed = YES;
//            [condition signal];
//        }];
//        [condition lock];
//        while (!completed) {
//            [condition wait];
//        }
//        [condition unlock];
//    }
//    return uuid;
//}


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

+(void)calculateDigestWhenPhotoHaveNotCompleteBlock:(void(^)(NSArray * arr))block{
    dispatch_async([FMUtil setterLowQueue], ^{
        FMDBSet * set = [FMDBSet shared];
        FMDTSelectCommand * scmd = FMDT_SELECT(set.photo);
        [scmd whereIsNull:@"degist"];
        NSArray * photosArr = [scmd fetchArray];
        NSLog(@"共%ld需要计算hash",(unsigned long)photosArr.count);
     
        if (photosArr.count>0) { //计算digest
              CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
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
                NSLog(@"已计算%ld张,还需要计算%ld张",(unsigned long)currentIndex,(unsigned long)photosArr.count-currentIndex);
                if (currentIndex >= [photosArr count] ) {
                    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
                    block(photosArr);
                    NSLog(@"计算完成");
                    MyNSLog(@"计算Hash 完成时间%f", end - start);
                    return;
                }
                else {
                    [weakSelf calculateDigestWithLocalId:((FMLocalPhoto *)photosArr[currentIndex]).localIdentifier andCompleteBlock:weakHelper.singleSuccessBlock];
                }
            };
            [self calculateDigestWithLocalId:((FMLocalPhoto *)photosArr[0]).localIdentifier andCompleteBlock:weakHelper.singleSuccessBlock];
        }else{
              block(photosArr);
        }
    });
}

+ (void)_getImageDataWithPHAsset:(PHAsset *)asset andCompleteBlock:(void(^)(NSString * filePath))block{
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
        NSString *PATH_IMAGE_FILE ;
        if (NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).count>0) {
         PATH_IMAGE_FILE = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"FMDigest"];
        }else{
            return;
        }
        
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

+(void)calculateDigestWithLocalId:(NSString *)localId andCompleteBlock:(void(^)(BOOL success,NSString * digest))block{
    NSAssert(!IsNilString(localId), @"localId can not be nil when calculate digest");
    PHAsset * asset = [[FMLocalPhotoStore shareStore] checkPhotoIsLocalWithLocalId:localId];
    if (asset) {
        [self _getImageDataWithPHAsset:asset andCompleteBlock:^(NSString *filePath) {
            if (filePath) {
               NSDictionary *dic  = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
               NSDate *modificationDate = [dic valueForKey:@"NSFileModificationDate"];
                dispatch_async([FMUtil setterLowQueue], ^{
                    NSString * localDegist = [FileHash sha256HashOfFileAtPath:filePath];
                    if (localDegist) {
                        NSDate *modificationDate2 = [dic valueForKey:@"NSFileModificationDate"];
                        if ([modificationDate isEqualToDate:modificationDate2]) {
                            [FMFileManagerInstance removeFileAtPath:filePath];
                            FMDTUpdateCommand * ucmd = [[FMDBSet shared].photo createUpdateCommand];
                            [ucmd fieldWithKey:@"degist" val:localDegist];
                            [ucmd where:@"localIdentifier" equalTo:asset.localIdentifier];
                            [ucmd saveChangesInBackground:^{
                                [[FMLocalPhotoStore shareStore] addDigestToStore:localDegist andLocalId:localId];
                                
                                //                        [[NSNotificationCenter defaultCenter]postNotificationName:FM_CALCULATE_HASH_SUCCESS_NOTIFY object:@{asset.localIdentifier:localDegist}];
                                if (block) block(YES,localDegist);
                                
                            }];
                        }else{
                            NSString * localDegist2 = [FileHash sha256HashOfFileAtPath:filePath];
                            [FMFileManagerInstance removeFileAtPath:filePath];
                            FMDTUpdateCommand * ucmd = [[FMDBSet shared].photo createUpdateCommand];
                            [ucmd fieldWithKey:@"degist" val:localDegist2];
                            [ucmd where:@"localIdentifier" equalTo:asset.localIdentifier];
                            [ucmd saveChangesInBackground:^{
                                [[FMLocalPhotoStore shareStore] addDigestToStore:localDegist andLocalId:localId];
                                
                                //                        [[NSNotificationCenter defaultCenter]postNotificationName:FM_CALCULATE_HASH_SUCCESS_NOTIFY object:@{asset.localIdentifier:localDegist}];
                                if (block) block(YES,localDegist);
                                }];
                        }
                        
                   
                    }else
                        if (block) block(NO,nil);
                });
                
            }else
                if (block) block(NO,nil);
        }];
    }else
        if (block) block(NO,nil);
}
static NSInteger s = 0;
- (void)errorActionWithTask:(NSURLSessionDataTask *)task HashString:(NSString *)hashStr{
    BOOL switchOn = SWITHCHON_BOOL;
   
    @weaky(self)
    NSHTTPURLResponse * rep = (NSHTTPURLResponse *)task.response;
    NSLog(@"%@",task.error);
    if (rep.statusCode == 404) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PHOTO_ENTRY_UUID_STR];
        if (switchOn &&_canUpload && shouldUpload) {
            [PhotoManager shareManager].canUpload = YES;
        }
    }else {
            if (switchOn &&_canUpload && shouldUpload) {
                dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
                dispatch_after(delayTime, dispatch_get_main_queue(), ^{
//                    [PhotoManager shareManager].canUpload = YES;
                    [self saveUploadArrayWithHash:hashStr];
                });
            }
    }   
 }
//static NSInteger s =0;
- (void)saveUploadArrayWithHash:(NSString *)hashString{
//    s++;
//    if (s>3) {
//        [PhotoManager calculateDigestWhenPhotoHaveNot];
//        [_uploadarray removeAllObjects];
//        self.canUpload = NO;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            self.canUpload = YES;
//        });
//    }
    startUpload = YES;
    BOOL switchOn = SWITHCHON_BOOL;
    NSMutableArray *uploadImageArr = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"uploadImageArr"];
    if (array) {
        [uploadImageArr addObjectsFromArray:array];
    }else{
        
        uploadImageArr = [NSMutableArray arrayWithCapacity:0];
    }
    [uploadImageArr addObject:hashString];
    if (_uploadarray.count >0) {
        [_uploadarray removeObjectAtIndex:0];
    }
//    NSNumber *number = [NSNumber numberWithUnsignedInteger:[_allCount unsignedIntegerValue] - _uploadarray.count];
//    
//    [[NSUserDefaults standardUserDefaults]setObject:number forKey:@"addCount"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
////    [[NSUserDefaults standardUserDefaults] setObject:uploadImageArr forKey:@"uploadImageArr"];
////    [[NSUserDefaults standardUserDefaults] synchronize];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"backUpProgressChange" object:nil];
//    if (switchOn &&_canUpload && shouldUpload) {
//        [self uploadImages:_uploadarray success:^(NSArray *arr) {
//            //                [FMPhotoDataSource siftPhotos];
//            if (switchOn &&_canUpload && shouldUpload) {
//                [[PhotoManager shareManager] startUploadPhotos];
//            }
//        } failure:^{
//        }];
//    }
    if (switchOn  && shouldUpload) {
        [[PhotoManager shareManager] setCanUpload:YES];
    }
}


+(NSString *) getSha256WithAsset:(PHAsset *)asset{
    __block NSString * localDegist = @"";
    [PhotoManager getImageFromPHAsset:asset Complete:^(NSData *fileData, NSString *fileName) {
        localDegist = [CocoaSecurity sha256WithData:fileData].hexLower;
    }];
    return localDegist;
}

- (void)removeNullWithString:(NSString *)nullString filePathHash:(NSString *)filePathHash{
//       BOOL switchOn = SWITHCHON_BOOL;
    if ([nullString isEqualToString:@"null"]) {
        [self saveUploadArrayWithHash:filePathHash];
    }
}

#pragma mark - NSurlSessionDelegate

@end
