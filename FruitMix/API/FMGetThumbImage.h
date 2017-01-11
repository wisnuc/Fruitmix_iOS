//
//  FMGetThumbImage.h
//  FruitMix
//
//  Created by 杨勇 on 16/8/24.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FMGetThumbImageCompleteBlock)(UIImage *image,NSString * tag);

@interface FMGetThumbImage : NSObject

@property (nonatomic ,readonly) NSOperationQueue * getImageQueue;

@property (nonatomic, strong, readonly) YYImageCache * cache;

+(instancetype)defaultGetThumbImage;

-(void)getLocalThumbWithLocalId:(NSString *)localId andCompleteBlock:(FMGetThumbImageCompleteBlock)block;

-(void)getLocalThumbWithLocalId:(NSString *)localId andCompleteBlock:(FMGetThumbImageCompleteBlock)block andQueue:(dispatch_queue_t)queue;

/**
 *  加载缩略图
 */
//+(void)getThumbImageWithPhotoHash:(NSString * )hash andCompleteBlock:(FMGetThumbImageCompleteBlock)block;

/**
 *  用于 提速 加载 缩略图
 *
 */
//+(void)getThumbImageQuickWithPhotohash:(NSString * )hash andCompleteBlock:(FMGetThumbImageCompleteBlock)block;

/*
 *
 * 用于 处理网络请求 的 延时请求。
 *
 */
+(void)getThumbImageWithAsset:(id<IDMPhoto>)asset andCompleteBlock:(FMGetThumbImageCompleteBlock)block;
@end


