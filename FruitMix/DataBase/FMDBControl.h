//
//  FMDBControl.h
//  FruitMix
//
//  Created by 杨勇 on 16/9/21.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^selectComplete)(NSArray<FMLocalPhoto *> * result);

@interface FMDBControl : NSObject
//数据库 添加 相册 新增照片
+(void)asyncLoadPhotoToDB;

+(void)asyncLoadPhotoToDBWithCompleteBlock:(void(^)(NSArray * addArr))block;

//获取 数据库中的未上传 照片信息
+(void)getDBPhotosWithCompleteBlock:(selectComplete)block;

//获取数据库中所有照片信息
+(void)getDBAllLocalPhotosWithCompleteBlock:(selectComplete)block;

//从表中删除照片 数据集
+(void)deletePhotoWithArray:(NSArray *)photoArr;

//Cache网络数据
+(void)asynNASPhoto:(NSArray<FMNASPhoto *> *)photoArr andCompleteBlock:(void(^)())block;


/**
 *  同步数据库 mediashare相关数据
 */
+(void)asynMediaShareWithArray:(NSArray<FMMediaShare *> *)arr andCompleteBlock:(void (^)(NSArray *insertArr,NSArray *updateArr))diffCallback;

/**
 *  拿到所有的数据库中的mediaShare
 *
 */
+(NSArray *)getAllMediaShares;
/**
 *  清空表
 */
+(void)reloadTables;
/**
 *  清空本地 的 mediaShare patch 和 comment
 */
+(void)reloadLocalMediaShares;


+(void)getAllAlbumWithCompleteBlock:(void(^)(NSArray * result))block;

/*
    获取本地下载的所有文件
 */
+(NSArray *)getAllDownloadFiles;
/*
    增加或删除 一条 download 记录
 */
+(void)updateDownloadWithFile:(FLDownload *)download isAdd:(BOOL)isAdd;



/********************** about User ***********************/

//同步本地User
+(void)asynUsers;

//同步UserHome
+(void)asyncUserHome;
/**
 *  获得当前NAS上所有用户的UUID
 */
+(NSArray *)getAllUsersUUID;

+(NSArray<FMUsers *> *)getAllUsers;

//添加一条 用户登录记录
+(void)addUserLoginInfo:(FMUserLoginInfo *)info;

//删除一条 用户登录记录
+(void)removeUserLoginInfo:(NSString *)userid;

//查询一条用户登录记录
+(FMUserLoginInfo *)findUserLoginInfo:(NSString *)userid;

+(NSArray  *)getAllUserLoginInfo;


+ (void)siftMidiaPhotoWithResultArr:(NSMutableArray *)arr CompleteBlock:(void (^)(NSMutableArray *photoArr))completeBlock;

@end

@interface FMLocalPhotoStore : NSObject

+(instancetype)shareStore;

@property (nonatomic ,strong ,readonly) NSMutableDictionary * localPhotoDic;

-(void)addAssetToStore:(PHAsset *)asset;

-(void)addDigestToStore:(NSString *)digest andLocalId:(NSString *)localId;

/*
 * return nil or asset,if nil, the photo is not local
 */
-(PHAsset *)checkPhotoIsLocalWithLocalId:(NSString *)localId;

/*
 * return nil or localId,if nil, the photo is not local
 */
-(NSString *)checkPhotoIsLocalWithDigest:(NSString *)digest;

/*
 * return nil or hash ,if nil, the photo has not caculture digest
 */
-(NSString *)getPhotoHashWithLocalId:(NSString *)localId;


@end
