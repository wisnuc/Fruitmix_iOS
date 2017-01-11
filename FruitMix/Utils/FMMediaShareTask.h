//
//  FMMediaShareTask.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/26.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMMediaShareTask : NSObject

+(instancetype)shareInstancetype;



+(NSArray *)mediaTaskGetLocalMediaShare;

/**
 *  尝试本地更新share
 *  返回 NO 代表 此mediaShare 以上传操作
 */
+(BOOL)managerUpdateAtMediaShare:(FMNeedUploadMediaShare *)share;

//更新patch
+(void)mediaTaskUpdateAtPatch:(FMNeedUploadPatch *)patch;


+(void) mediaTaskAddPatchWithPatch:(FMNeedUploadPatch *)patch;

+(void)Patch_GetPhotoNotLocalWithShareId:(NSString *)shareId andPhotos:(NSArray *)photos andCompletBlock:(void(^)(NSArray* localArr,NSArray * netArr))block;



//判断这个mediaShare 是否为本地
+(BOOL)mediaShareIsLocal:(NSString *)shareId;

//追加（增）
+(void) mediaTask_AddWithShareId:(NSString *)shareId andAddLocalArr:(NSArray<NSString *> *)localArr andNetArr:(NSArray<NSString *> *)netArr;
//创建（增）
+(void)mediaTaskAddTask:(FMNeedUploadMediaShare *)share;

//创建评论
+(id<FMCommentsProtocol>)mediaTaskAddCommentWithShareId:(NSString *)shareId andPhotoHash:(NSString *)photoHash andText:(NSString *)text;

//删
+(void) mediaTask_DeleteWithShareId:(NSString *)shareId andDeleteArr:(NSArray<NSString *> *)arr;

/**
 *  删除某个MediaShare 本地所有记录
 *
 *  @param shareId localshare.uuid
 */
+(void) managerDeleteShareWithShareID:(NSString *)shareId;


//查
+(NSArray *)mediaTask_SelectPatchWithShareId:(NSString *)shareId;

//查评论
+(NSArray *)mediaTask_SelectCommentWithPhotoHash:(NSString *)hash;

//查 相册
+(NSArray *)mediaTaskGetLocalAlbum;

//查某个mediashare
+(NSArray *)mediaTaskGetLocalMediaShareWithShareId:(NSString *)mediaShareId;

//查 相册
+(NSArray *)mediaTaskGetPatch;

@end
