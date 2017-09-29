//
//  FMGetThumbImage.m
//  FruitMix
//
//  Created by 杨勇 on 16/8/24.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMGetThumbImage.h"
#import "NSOperationStack.h"
#import "UIImageView+WebCache.h"

@interface FMGetThumbImage ()

@property (nonatomic, strong, readwrite) YYImageCache * cache;
// fast look without sqlite
@property (nonatomic) NSMutableDictionary * localIdDic;

@property (nonatomic) NSOperationQueue * createQueue;

@property (nonatomic ,readwrite) NSOperationQueue * getImageQueue;

@end

@implementation FMGetThumbImage

+(instancetype)defaultGetThumbImage{
    static FMGetThumbImage * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FMGetThumbImage alloc]init];
    });
    return manager;
}

-(instancetype)init{
    if (self = [super init]) {
        _cache = [YYImageCache sharedCache];
        _cache.memoryCache.countLimit = 50;
        [_cache.diskCache setCountLimit:10000];
//        [_cache.diskCache setAutoTrimInterval:30];
//        [_cache.memoryCache setCostLimit:1*1024];
        _localIdDic = [NSMutableDictionary dictionaryWithCapacity:0];
        _createQueue = [[NSOperationQueue alloc]init];
        _createQueue.maxConcurrentOperationCount = 1;
        _createQueue.qualityOfService = NSQualityOfServiceUtility;
        _getImageQueue = [[NSOperationQueue alloc]init];
        _getImageQueue.maxConcurrentOperationCount = 2;
        _getImageQueue.qualityOfService = NSQualityOfServiceUtility;
    }
    return self;
}

-(void)getLocalThumbWithLocalId:(NSString *)localId andCompleteBlock:(FMGetThumbImageCompleteBlock)block{
    [self getLocalThumbWithLocalId:localId andCompleteBlock:block andQueue:[FMUtil setterLowQueue]];
}
/**
 *  通过 Asset 的 LocalId  拿到 缩略图
 *
 *
 */
-(void)getLocalThumbWithLocalId:(NSString *)localId andCompleteBlock:(FMGetThumbImageCompleteBlock)block andQueue:(dispatch_queue_t)queue{
    @weaky(self);
    [_createQueue addOperationAtFrontOfQueueWithBlock:^{
        @autoreleasepool {
            UIImage * image;
            if([weak_self.localIdDic objectForKey:localId] && (image = [_cache getImageForKey:[weak_self.localIdDic objectForKey:localId]])){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(block)
                        block(image,localId);
                });
            }else{
                PHAsset * asset = [[FMLocalPhotoStore shareStore] checkPhotoIsLocalWithLocalId:localId];
                if (asset) {
                    [weak_self createLocalThumb:asset andCompleteBlock:^(UIImage *image) {
                        if(block)
                            dispatch_async(dispatch_get_main_queue(), ^{
                                block(image,localId);
                            });
                        [weak_self cacheThumbImageWithLocalId:asset andImage:image];
                    }];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(nil,localId);
                    });
                }
                
            }
        }
    }];
}

/**
 *  制作缩略图
 *
 *  @param asset 本地资源
 *  @param block 制作完成通知
 */
-(void)createLocalThumb:(PHAsset *)asset andCompleteBlock:(void(^)(UIImage *image))block{
    @autoreleasepool {
        NSInteger retinaScale = [UIScreen mainScreen].scale;
        CGFloat thumbW = asset.pixelWidth*retinaScale>200*retinaScale?200*retinaScale:asset.pixelWidth*retinaScale;
        CGFloat thumbH = thumbW*(asset.pixelHeight/asset.pixelWidth);
        CGSize retinaSquare = CGSizeMake(thumbW, thumbH);
        PHImageRequestOptions *cropToSquare = [[PHImageRequestOptions alloc] init];
        cropToSquare.resizeMode = PHImageRequestOptionsResizeModeExact;
        CGRect square = CGRectMake(0, 0, asset.pixelWidth, asset.pixelHeight);
        CGRect cropRect = CGRectApplyAffineTransform(square,
                                                     CGAffineTransformMakeScale(1.0 / asset.pixelWidth,
                                                                                1.0 / asset.pixelHeight));
        cropToSquare.normalizedCropRect = cropRect;
        cropToSquare.synchronous = YES;
        cropToSquare.networkAccessAllowed = YES;
        cropToSquare.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        
        [[PHImageManager defaultManager]
         requestImageForAsset:asset
         targetSize:retinaSquare
         contentMode:PHImageContentModeAspectFit
         options:cropToSquare
         resultHandler:^(UIImage *result, NSDictionary *info) {
             if(block) block(result);
         }];
    }
}


/**
 *  缓存image
 *
 *  @param asset 本地资源
 *  @param image 该资源的缩略图
 */
-(void)cacheThumbImageWithLocalId:(PHAsset *)asset andImage:(UIImage *)image{
    [PhotoManager getImageFromPHAsset:asset Complete:^(NSData *fileData, NSString *fileName) {
        dispatch_async([FMUtil setterCacheQueue], ^{
            if (fileData.length > 100) {
                NSString * localDegist = [CocoaSecurity sha256WithData:fileData].hexLower;
                [_cache setImage:image forKey:localDegist];
                //缓存图片
                [[FMLocalPhotoStore shareStore] addDigestToStore:localDegist andLocalId:asset.localIdentifier];                
                //更新数据库
                FMDTUpdateCommand * ucmd = [[FMDBSet shared].photo createUpdateCommand];
                [ucmd fieldWithKey:@"degist" val:localDegist];
                [ucmd where:@"localIdentifier" equalTo:asset.localIdentifier];
                [ucmd saveChangesInBackground:nil];
            }else{
                [MyAppDelegate.statusBarNotification displayNotificationWithMessage:@"No digest for photo" forDuration:1];
            }
        });
        
    }];
}


//+(void)getThumbImageWithPhotoHash:(NSString * )hash andCompleteBlock:(FMGetThumbImageCompleteBlock)block{
//    [self _getThumbImageWithPhotoHash:hash andCompleteBlock:block andQueue:[FMUtil setterLowQueue]];
//}
//
//
//+(void)getThumbImageQuickWithPhotohash:(NSString * )hash andCompleteBlock:(FMGetThumbImageCompleteBlock)block{
//    [self _getThumbImageWithPhotoHash:hash andCompleteBlock:block andQueue:[FMUtil setterHighQueue]];
//}



+(void)getThumbImageWithAsset:(id<IDMPhoto>)asset andCompleteBlock:(FMGetThumbImageCompleteBlock)block{
    NSString * hash = [asset getPhotoHash];
    if (IsNilString(hash) && [asset isKindOfClass:[FMPhotoAsset class]]) {
         [[FMGetThumbImage defaultGetThumbImage] getLocalThumbWithLocalId:((FMPhotoAsset *)asset).localId andCompleteBlock:block];
    }else{
        [self _getThumbImageWithPhotoHash:hash andAsset:asset andCompleteBlock:block];
    }
}

+(void)_getThumbImageWithPhotoHash:(NSString * )hash andAsset:(id<IDMPhoto>)asset andCompleteBlock:(FMGetThumbImageCompleteBlock)block{
    NSAssert(hash != nil, @"degist 不能为空");
    @weaky(asset);
    @weaky(self);
    [[FMGetThumbImage defaultGetThumbImage].getImageQueue addOperationAtFrontOfQueueWithBlock:^{
        if([[FMGetThumbImage defaultGetThumbImage].cache containsImageForKey:hash]){
            @autoreleasepool {
                UIImage *img = [[FMGetThumbImage defaultGetThumbImage].cache getImageForKey:hash];
                if(block)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(img,hash);
                });
            }
            
        }else{
            [PhotoManager managerCheckPhotoIsLocalWithPhotohash:hash andCompleteBlock:^(NSString *localId, NSString *photoHash, BOOL isLocal) {
                if(localId){//本地图
                    [[FMGetThumbImage defaultGetThumbImage] getLocalThumbWithLocalId:localId andCompleteBlock:^(UIImage *image, NSString *tag){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(block)
                                block(image,photoHash);
                        });
                    } andQueue:nil];
                }else{  //网络图
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        @autoreleasepool {
                            if (weak_asset.shouldRequestThumbnail) {
                                [weak_self  getThumbImageWithHash:hash andCount:0 andAsset:weak_asset andPressBlock:^(NSInteger receivedSize, NSInteger expectedSize) {
                                } andCompletBlock:^(UIImage *image,NSString * tag) {
                                    dispatch_async([FMUtil setterCacheQueue], ^{
                                        [[FMGetThumbImage defaultGetThumbImage].cache setImage:image forKey:hash];
                                    });
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        if(block && weak_asset.shouldRequestThumbnail)
                                            block(image,photoHash);
                                    });
                                }];
                            }
                        }
                    });
                }
            }];
        }
    }];
}


//get net asset thumbnail
+(void)getThumbImageWithHash:(NSString *)hash
                    andCount:(NSInteger)count
                    andAsset:(id<IDMPhoto>)asset
               andPressBlock:(SDWebImageDownloaderProgressBlock)progress
             andCompletBlock:(getImageComplete)block{
    @weaky(self);
    NSInteger H = 200;
    NSInteger W = 200;
    [weak_self getThumbImageWithHash:hash andHeight:H andWidth:W andCount:0 andAsset:asset andPressBlock:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (progress) {
            progress(receivedSize,expectedSize);
        }
    } andCompletBlock:^(UIImage *image, NSString *tag) {
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(image,hash);
            });
        }
    }];
}

+(void)getThumbImageWithHash:(NSString *)hash
                   andHeight:(NSInteger)H
                    andWidth:(NSInteger)W
                    andCount:(NSInteger)count
                    andAsset:(id<IDMPhoto>)asset
               andPressBlock:(SDWebImageDownloaderProgressBlock)progress
             andCompletBlock:(getImageComplete)block{
    if(IsNilString(hash))
        return;
    @weaky(self);
    SDWebImageManager * _manager = [SDWebImageManager sharedManager];
    [[SDImageCache sharedImageCache] setShouldDecompressImages:NO];
    [[SDWebImageDownloader sharedDownloader] setShouldDecompressImages:NO];
    _manager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    _manager.imageDownloader.maxConcurrentDownloads = 2;
    _manager.imageDownloader.headersFilter = ^NSDictionary *(NSURL *url, NSDictionary *headers) {
         NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:headers];
        if (KISCLOUD) {
          [dic setValue:[NSString stringWithFormat:@"%@",DEF_Token] forKey:@"Authorization"];
        }else{
          [dic setValue:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
        }
        return dic;
    };
    NSString *sourceUrl = [NSString stringWithFormat:@"media/%@",hash];
    NSString *sourceUrlBase64 = [sourceUrl base64EncodedString];
    NSURL * url;
     if (KISCLOUD) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@stations/%@/pipe?alt=thumbnail&width=%ld&height=%ld&modifier=caret&autoOrient=true&method=GET&resource=%@",[JYRequestConfig sharedConfig].baseURL,KSTATIONID,(long)W,(long)H,sourceUrlBase64]];
     }else{
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@media/%@?alt=thumbnail&width=%ld&height=%ld&modifier=caret&autoOrient=true",[JYRequestConfig sharedConfig].baseURL,hash,(long)W,(long)H]];
     }
//    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@media/%@?alt=thumbnail&width=%ld&height=%ld&modifier=caret&autoOrient=true",[JYRequestConfig sharedConfig].baseURL,hash,(long)W,(long)H]];
//    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@media/%@/thumbnail?width=%ld&height=%ld&modifier=caret&autoOrient=true",[JYRequestConfig sharedConfig].baseURL,hash,(long)W,(long)H]];
    _manager.imageDownloader.downloadTimeout = 100000;
    id <SDWebImageOperation> op = [_manager downloadImageWithURL:url options:SDWebImageRetryFailed|SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (progress) {
            if (!asset.shouldRequestThumbnail) {
                [op cancel];
            }
            progress(receivedSize,expectedSize);
        }
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image)
            dispatch_async(dispatch_get_main_queue(), ^{
                block(image,hash);
            });
        else{
              NSLog(@"%@",error);
            if (error.code == 404) NSLog(@"服务端未查到此照片");
            else
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (asset.shouldRequestThumbnail) {
                            [weak_self getThumbImageWithHash:hash andHeight:H andWidth:W andCount:count andAsset:asset andPressBlock:progress andCompletBlock:block];
                        }
                    });
                });
        }
    }];
}

-(void)dealloc {
    SDImageCache *canche = [SDImageCache sharedImageCache];
    canche.shouldDecompressImages = YES;
    SDWebImageDownloader *downloder = [SDWebImageDownloader sharedDownloader];
    downloder.shouldDecompressImages = YES;
}
@end
