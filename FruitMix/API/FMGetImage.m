//
//  FMGetImage.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/22.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMGetImage.h"
#import "JYRequestConfig.h"
#import "YYImageCache.h"
#import "FMUtil.h"
#import "FMGetThumbImage.h"

NSString * const LocalThumbImageCache = @"LocalThumbImageCache";

@interface FMGetImage (){
    dispatch_semaphore_t _lock;
}
//@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) YYImageCache * cache;
@property (nonatomic) SDWebImageManager * manager;

@end

@implementation FMGetImage

+(instancetype)defaultGetImage{
    static FMGetImage * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FMGetImage alloc]init];
    });
    return manager;
}

-(instancetype)init{
    if (self = [super init]) {
        _cache = [YYImageCache sharedCache];
        _lock = dispatch_semaphore_create(1);
        _manager = [SDWebImageManager sharedManager];
        _manager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
        _manager.imageDownloader.maxConcurrentDownloads = 2;
    }
    return self;
}

-(void)getThumbImageWithHash:(NSString *)hash
                    andCount:(NSInteger)count
               andPressBlock:(SDWebImageDownloaderProgressBlock)progress
             andCompletBlock:(getImageComplete)block
                    andQueue:(dispatch_queue_t)queue{
    if(IsNilString(hash))
        return;
    
    //TODO cache NAS Photo
    @weakify(self);
    //全小写
    NSString * lowHash = [hash lowercaseString];
    FMDTSelectCommand * scmd = FMDT_SELECT([FMDBSet shared].nasPhoto);
    [scmd where:@"digest" equalTo:hash];
    NSArray *result = [scmd fetchArray];
    NSInteger H = 200;
    NSInteger W = 200;
    if (result.count>0) {
        FMNASPhoto * photo = result[0];
        if (photo.width&&photo.width<=200)
            W = photo.width;
        if (photo.height)
            H = W*photo.height/photo.width;
    }
    [weak_self getThumbImageWithHash:lowHash andHeight:H andWidth:W andCount:0 andPressBlock:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (progress) {
            progress(receivedSize,expectedSize);
        }
    } andCompletBlock:^(UIImage *image, NSString *tag) {
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(image,hash);
            });
        }
    } andQueue:queue];
}

-(void)getThumbImageWithHash:(NSString *)hash
                   andHeight:(NSInteger)H
                    andWidth:(NSInteger)W
                    andCount:(NSInteger)count
               andPressBlock:(SDWebImageDownloaderProgressBlock)progress
             andCompletBlock:(getImageComplete)block
                    andQueue:(dispatch_queue_t)queue{
    if(IsNilString(hash))
        return;
//    if(count++ == 5 )
//        return;
//    dispatch_async(queue, ^{
    _manager.imageDownloader.headersFilter = ^NSDictionary *(NSURL *url, NSDictionary *headers) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:headers];
        [dic setValue:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
        return dic;
    };
    
    //TODO cache NAS Photo
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@media/%@/thumbnail?width=%ld&height=%ld&modifier=caret&autoOrient=true",[JYRequestConfig sharedConfig].baseURL,hash,(long)W,(long)H]];
    
    [_manager downloadImageWithURL:url options:SDWebImageRetryFailed|SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (progress) {
            progress(receivedSize,expectedSize);
        }
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(image,hash);
            });
        }else{
            if (error.code == 404) {
                NSLog(@"服务端未查到此照片");
            }else{
                //1.5s后 继续请求
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[FMGetImage defaultGetImage] getThumbImageWithHash:hash andHeight:H andWidth:W andCount:count andPressBlock:progress andCompletBlock:block andQueue:queue];
                    });
                });
            }
        }
    }];
}


-(void)getThumbImageWithHash:(NSString *)hash
                    andCount:(NSInteger)count
               andPressBlock:(SDWebImageDownloaderProgressBlock)progress
             andCompletBlock:(getImageComplete)block{
    [self getThumbImageWithHash:hash andCount:count andPressBlock:progress andCompletBlock:block andQueue:[FMUtil setterLowQueue]];
}

-(void)getOriginalImageWithHash:(NSString *)hash
                       andCount:(NSInteger)count
                  andPressBlock:(SDWebImageDownloaderProgressBlock)progress
                andCompletBlock:(getImageComplete)block{
    if(IsNilString(hash))
        return;
    _manager.imageDownloader.headersFilter = ^NSDictionary *(NSURL *url, NSDictionary *headers) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithDictionary:headers];
        [dic setValue:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
        return dic;
    };
    
    NSString * lowHash = [hash lowercaseString];
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@media/%@/download",[JYRequestConfig sharedConfig].baseURL,lowHash]];
    [_manager downloadImageWithURL:url options:SDWebImageRetryFailed|SDWebImageHandleCookies progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        if (progress) {
            progress(receivedSize,expectedSize);
        }
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image) {
            block(image,hash);
        }else{
            NSLog(@"获取大图失败：hash :%@\n error:%@",hash,error.localizedDescription);
        }
    }];

}


-(void)createLocalThumb:(PHAsset *)asset andCompleteBlock:(void(^)(UIImage *image))block{
    NSInteger retinaScale = [UIScreen mainScreen].scale;
    CGFloat thumbW = asset.pixelWidth*retinaScale>100*retinaScale?100*retinaScale:asset.pixelWidth*retinaScale;
    CGFloat thumbH = thumbW*(asset.pixelHeight/asset.pixelWidth);
    CGSize retinaSquare = CGSizeMake(thumbW, thumbH);
    PHImageRequestOptions *cropToSquare = [[PHImageRequestOptions alloc] init];
    cropToSquare.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    //            CGFloat cropSideLength = MIN(asset.pixelWidth, asset.pixelHeight);
    //            CGRect square = CGRectMake(0, 0, cropSideLength, cropSideLength);
    
    CGRect square = CGRectMake(0, 0, asset.pixelWidth, asset.pixelHeight);
    
    CGRect cropRect = CGRectApplyAffineTransform(square,
                                                 CGAffineTransformMakeScale(1.0 / asset.pixelWidth,
                                                                            1.0 / asset.pixelHeight));
    cropToSquare.normalizedCropRect = cropRect;
    cropToSquare.synchronous = YES;
    
//    @autoreleasepool {
        [[PHImageManager defaultManager]
         requestImageForAsset:asset
         targetSize:retinaSquare
         contentMode:PHImageContentModeAspectFit
         options:cropToSquare
         resultHandler:^(UIImage *result, NSDictionary *info) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if(block) block(result);
             });
         }];
//    }
}

//全屏图
-(void)getOriginalImageWithAsset:(PHAsset *)asset andCompleteBlock:(getImageComplete)block{
    CGFloat pW = __kWidth*[UIScreen mainScreen].scale;
    CGFloat pH = asset.pixelHeight * (pW/asset.pixelWidth);
    CGSize targetSize = CGSizeMake(pW, pH);
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    CGRect square = CGRectMake(0, 0, asset.pixelWidth, asset.pixelHeight);
    CGRect cropRect = CGRectApplyAffineTransform(square,
                                                 CGAffineTransformMakeScale(1.0 / asset.pixelWidth,
                                                                            1.0 / asset.pixelHeight));
    imageRequestOptions.normalizedCropRect = cropRect;
    imageRequestOptions.synchronous = YES;
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:imageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(result,nil);
                }
            });
        }
    }];
}

-(void)getCoverImageWithAsset:(PHAsset *)asset andCompleteBlock:(getImageComplete)block{
    @autoreleasepool {
        NSInteger retinaScale = [UIScreen mainScreen].scale;
        CGFloat thumbW = asset.pixelWidth*retinaScale>400*retinaScale?400*retinaScale:asset.pixelWidth*retinaScale;
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
    
    
        [[PHCachingImageManager defaultManager]
         requestImageForAsset:asset
         targetSize:retinaSquare
         contentMode:PHImageContentModeAspectFit
         options:cropToSquare
         resultHandler:^(UIImage *result, NSDictionary *info) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if(block) block(result,nil);
             });
         }];
    }
}

-(void)getOriginalImageWithLocalhash:(NSString *)hash andCompleteBlock:(getImageComplete)block andIsCover:(BOOL)isCover{
    dispatch_async([FMUtil setterDefaultQueue], ^{
        FMLocalPhotoStore * store = [FMLocalPhotoStore shareStore];
        PHAsset * asset = [store checkPhotoIsLocalWithLocalId:[store checkPhotoIsLocalWithDigest:hash]];
        if (asset) {
            if (isCover)
                [self getCoverImageWithAsset:asset andCompleteBlock:block];
            else
                [self getOriginalImageWithAsset:asset andCompleteBlock:block];
        }
    });
}



-(void)getFullImageWithAsset:(PHAsset *)asset andCompleteBlock:(getImageComplete)block{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        @autoreleasepool {
            CGSize targetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
            PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
            imageRequestOptions.synchronous = YES;
            [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeDefault options:imageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                if (result) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(result,nil);
                    });
                }
            }];
//        }
    });
}


+(void)getFullScreenImageWithPhotoHash:(NSString * )hash andCompleteBlock:(getImageComplete)block{
    //本地图片
    [self getFullScreenImageWithPhotoHash:hash andCompleteBlock:block andIsAlbumCover:NO];
}

+(void)getFullScreenImageWithPhotoHash:(NSString * )hash andCompleteBlock:(getImageComplete)block andIsAlbumCover:(BOOL)isCover{
    //本地图片
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //封面大图 key 格式
        NSString * hashKey = [NSString stringWithFormat:@"%@&w=800&h=600",hash];
        if(isCover && [[FMGetThumbImage defaultGetThumbImage].cache containsImageForKey:hashKey]){
            UIImage *img = [[FMGetThumbImage defaultGetThumbImage].cache getImageForKey:hashKey];
            if(block)
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(img,hash);
                });
        }else{
            [PhotoManager managerCheckPhotoIsLocalWithPhotohash:hash andCompleteBlock:^(NSString *localId, NSString *photoHash, BOOL isLocal) {
                if (isLocal)
                    [[FMGetImage defaultGetImage] getOriginalImageWithLocalhash:hash andCompleteBlock:^(UIImage *image, NSString *tag) {
                        if (isCover)//封面大图 需要缓存
                            [self cacheCoverImage:image andKey:hashKey];
                        if(block) block(image,hash);
                    } andIsCover:isCover];
                
                else{
                    if (isCover) {
                        //封面大图 需要缓存
                        [[FMGetImage defaultGetImage] getThumbImageWithHash:hash andHeight:600 andWidth:800 andCount:0 andPressBlock:^(NSInteger receivedSize, NSInteger expectedSize) {
                        } andCompletBlock:^(UIImage *image, NSString *tag) {
                            [self cacheCoverImage:image andKey:hashKey];
                            if(block)
                                block(image,tag);
                        } andQueue:nil];
                    }else{
                        [[FMGetImage defaultGetImage] getOriginalImageWithHash:hash andCount:0 andPressBlock:^(NSInteger receivedSize, NSInteger expectedSize) {
                        } andCompletBlock:^(UIImage *image, NSString *tag) {
                            if(block) block(image,tag);
                        }];
                    }
                }
            }];
        }
    });
}

+(void)cacheCoverImage:(UIImage *)image andKey:(NSString *)key{
    dispatch_async([FMUtil setterCacheQueue], ^{
        [[FMGetThumbImage defaultGetThumbImage].cache setImage:image forKey:key];
    });
}

@end
