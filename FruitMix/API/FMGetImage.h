//
//  FMGetImage.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/22.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/SDWebImageManager.h>

extern  NSString * const LocalThumbImageCache;

typedef void(^getImageComplete)(UIImage *image,NSString * tag);

@interface FMGetImage : NSObject

+(instancetype)defaultGetImage;

@property (nonatomic, strong) YYImageCache * cache;
@property (nonatomic) SDWebImageManager * manager;


/**
 *  获取 网络缩略图
 *
 *  @param hash  原图hash（sha256）宽高由 数据库查询所得
 *  @param count 请求次数
 *  @param block return thumbImage
 */
-(void)getThumbImageWithHash:(NSString *)hash andCount:(NSInteger)count andPressBlock:(SDWebImageDownloaderProgressBlock)progress andCompletBlock:(getImageComplete)block;

/**
 *获取网络缩略图 自己指定宽高
 *
 */
-(void)getThumbImageWithHash:(NSString *)hash
                   andHeight:(NSInteger)H
                    andWidth:(NSInteger)W
                    andCount:(NSInteger)count
               andPressBlock:(SDWebImageDownloaderProgressBlock)progress
             andCompletBlock:(getImageComplete)block
                    andQueue:(dispatch_queue_t)queue;
/**
 *  获取网络原图
 *
 *  @param hash
 */
-(void)getOriginalImageWithHash:(NSString *)hash andCount:(NSInteger)count andPressBlock:(SDWebImageDownloaderProgressBlock)progress andCompletBlock:(getImageComplete)block;
/**
 *  获取 本地缩略图
 *
 *  @param localId asset.localid
 *  @param block   return thumbImage
 */
//-(void)getThumbImageWithLocalId:(PHAsset *)asset
//                   andAssetHash:(NSString *)hash
//               andCompleteBlock:(getImageComplete)block;

//获取本地缩略图 通过 hash
//-(void)getThumbImageWithLocalHash:(NSString *)hash andCompleteBlock:(getImageComplete)block;
/**
 *  获取本地全屏图
 *
 */

-(void)getOriginalImageWithAsset:(PHAsset *)asset andCompleteBlock:(getImageComplete)block;
/**
 *  获取本地原图
 */
-(void)getFullImageWithAsset:(PHAsset *)asset andCompleteBlock:(getImageComplete)block;

/**
 *  get Public Image
 */
//-(void)getPublicImageWithHash:(NSString *)hash andUUID:(NSString *)uuid andCompleteBlock:(getImageComplete)block;
/**
 *  通过hash获取本地全屏图
 */
-(void)getOriginalImageWithLocalhash:(NSString *)hash andCompleteBlock:(getImageComplete)block andIsCover:(BOOL)isCover; 


/******************************************************************************************************************************/
/******************************************************************************************************************************/
/******************************************************************************************************************************/
//获得缩略图
//+(void)getThumbImageWithPhotoHash:(NSString * )hash andCompleteBlock:(getImageComplete)block;

//获得大图
+(void)getFullScreenImageWithPhotoHash:(NSString * )hash andCompleteBlock:(getImageComplete)block;


+(void)getFullScreenImageWithPhotoHash:(NSString * )hash andCompleteBlock:(getImageComplete)block andIsAlbumCover:(BOOL)isCover;
/**
 *  用于快速获取大图
 */
-(void)getThumbImageWithHash:(NSString *)hash
                    andCount:(NSInteger)count
               andPressBlock:(SDWebImageDownloaderProgressBlock)progress
             andCompletBlock:(getImageComplete)block
                    andQueue:(dispatch_queue_t)queue;
@end
