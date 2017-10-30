//
//  FMPhotoManager.h
//  Photos
//
//  Created by JackYang on 2017/10/26.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "UploadWokingModel.h"

@class FMAsset;
@interface FMPhotoManager : NSObject
+(__kindof FMPhotoManager *)defaultManager;

@property (nonatomic, readonly) NSMutableArray<FMAsset *> *hashwaitingQueue;

@property (nonatomic, readonly) NSMutableArray<FMAsset *> *hashWorkingQueue;

@property (nonatomic, readonly) NSMutableArray<FMAsset *> *hashFailQueue;

@property (nonatomic, readonly) NSMutableArray<FMAsset *> *uploadPaddingQueue;

@property (nonatomic, readonly) NSMutableArray<FMAsset *> *uploadingQueue;

@property (nonatomic, readonly) NSMutableArray<FMAsset *> *uploadedQueue;

@property (nonatomic, readonly) NSMutableArray<FMAsset *> *uploadErrorQueue;

@property (nonatomic, readonly) BOOL isStoped;

@property (nonatomic) NSInteger hashLimitCount; // default 1

@property (nonatomic) NSInteger uploadLimitCount; // default 1

@property (nonatomic) FMAsset *asset;

@property (nonatomic) UploadWokingModel *workingModel;

//+ (instancetype)defaultManager;

- (void)start;

- (void)stop;

- (void)destroy;

- (void)readyCompleteBlock:(void(^)(BOOL))callback;

@end

@interface FMAsset : NSObject

@property (nonatomic) PHAsset * asset;

@property (nonatomic) NSString * sha256;

/**
 *  @property (nonatomic) NSDictionary * otherMateData; // 根据业务需求展开 作为通用逻辑
 */

@end
