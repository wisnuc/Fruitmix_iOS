//
//  FMMediaShareTask.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/26.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMMediaShareTask.h"

@implementation FMMediaShareTask

+(instancetype)shareInstancetype{
    static FMMediaShareTask * task = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        task = [[FMMediaShareTask alloc]init];
    });
    return task;
}

+(void)mediaTaskAddTask:(FMNeedUploadMediaShare *)share{
    FMDBSet *set = [FMDBSet shared];
    FMDTInsertCommand *icmd = FMDT_INSERT(set.needUploadMediaShare);
    [icmd add:share];
    [icmd saveChangesInBackground:^{
        NSLog(@"一条mediaShare添加到本地TaskQ,MediaShareId:%@",share.uuid);
    }];
}

+(NSArray *)mediaTaskGetLocalMediaShare{
    FMDBSet *set = [FMDBSet shared];
    FMDTSelectCommand *scmd = FMDT_SELECT(set.needUploadMediaShare);
    [scmd where:@"state" notEqualTo:UPLOADED];
    return [scmd fetchArray];
}

+(NSArray *)mediaTaskGetLocalMediaShareWithShareId:(NSString *)mediaShareId{
    FMDBSet *set = [FMDBSet shared];
    FMDTSelectCommand *scmd = FMDT_SELECT(set.needUploadMediaShare);
    [scmd where:@"uuid" equalTo:mediaShareId];
//    scmd where:@"" notEqualTo:<#(id)#>
    return [scmd fetchArray];
}

+(NSArray *)mediaTaskGetLocalAlbum{
    FMDBSet * dbSet = [FMDBSet shared];
    FMDTSelectCommand *scmd = FMDT_SELECT(dbSet.needUploadMediaShare);
    [scmd where:@"album" equalTo:@(1)];
    [scmd where:@"state" notEqualTo:UPLOADED];
    return [scmd fetchArray];
}

//更新 local mediaShare
+(BOOL)managerUpdateAtMediaShare:(FMNeedUploadMediaShare *)share{
    FMDBSet * dbSet = [FMDBSet shared];
    FMDTUpdateObjectCommand * ucmd = FMDT_UPDATE_OBJECT(dbSet.needUploadMediaShare);
    [ucmd add:share];
    [ucmd saveChanges];

    return YES;
}

//获取可以编辑的Share
+(NSArray *)managerGetCanEditShareWithShareId:(NSString *)shareId{
    FMDBSet * dbSet = [FMDBSet shared];
    //判断状态
    FMDTSelectCommand *scmd = FMDT_SELECT(dbSet.needUploadMediaShare);
    [scmd where:@"uuid" equalTo:shareId];
    NSArray * result = [scmd fetchArray];
    return result;
}

//删除LocalMediaShare
+(void) managerDeleteShareWithShareID:(NSString *)shareId{
    //删除MediaShare
    FMDBSet * dbSet = [FMDBSet shared];
    FMDTDeleteCommand * dcmd = FMDT_DELETE(dbSet.needUploadMediaShare);
    [dcmd where:@"uuid" equalTo:shareId];
    [dcmd saveChanges];
    //删除Patch
    FMDTDeleteCommand * dcmd2 = FMDT_DELETE(dbSet.needUploadPatch);
    [dcmd2 where:@"shareid" equalTo:shareId];
    [dcmd2 saveChanges];
}


//新增一个 patch
+(void) mediaTaskAddPatchWithPatch:(FMNeedUploadPatch *)patch{
    FMDBSet * dbSet = [FMDBSet shared];
    FMDTInsertCommand * icmd = FMDT_INSERT(dbSet.needUploadPatch);
    [icmd add:patch];
    [icmd saveChanges];
}


+(void)Patch_GetPhotoNotLocalWithShareId:(NSString *)shareId andPhotos:(NSArray *)photos andCompletBlock:(void(^)(NSArray* localArr,NSArray * netArr))block{
    FMDBSet * dbSet = [FMDBSet shared];
    //判断状态
    //LocalPatch 中的 数据
    FMDTSelectCommand *scmd = FMDT_SELECT(dbSet.needUploadPatch);
    [scmd where:@"shareid" equalTo:shareId];
    NSArray * result = [scmd fetchArray];
    NSMutableSet * localPatch = [NSMutableSet set];
    for (FMNeedUploadPatch * pat in result) {
        [localPatch addObjectsFromArray:pat.addLocalArr];
    }
    
    //localMediaShare 中的 数据
    FMDTSelectCommand *scmd2 = FMDT_SELECT(dbSet.needUploadMediaShare);
    [scmd2 where:@"uuid" equalTo:shareId];
    NSArray * result2 = [scmd2 fetchArray];
    for (FMNeedUploadMediaShare * mediaShare in result2) {
        [localPatch addObjectsFromArray:mediaShare.localPhotos];
    }
    
    NSMutableArray * netArr = [NSMutableArray arrayWithArray:photos];
    NSMutableArray * localArr = [NSMutableArray arrayWithArray:photos];
    [netArr removeObjectsInArray:[localPatch allObjects]];
    [localArr removeObjectsInArray:netArr];
    
    NSAssert(photos.count == (netArr.count+localArr.count), @"数据不完整");
    
    block(localArr,netArr);
}



+(void) Patch_RemovePhotosPatchAtMeidaShare:(NSString *)shareid andPhotos:(NSArray *)rmArr{
    FMDBSet * dbSet = [FMDBSet shared];
    //判断状态
    FMDTSelectCommand *scmd = FMDT_SELECT(dbSet.needUploadPatch);
    [scmd where:@"shareid" equalTo:shareid];
    NSArray * result = [scmd fetchArray];
    NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
    for (FMNeedUploadPatch * pat in result) {
        NSMutableArray * arr = [NSMutableArray arrayWithArray:pat.addLocalArr];
        [arr removeObjectsInArray:rmArr];
        pat.addLocalArr = arr;
        [tempArr addObject:pat];
    }
    if (tempArr.count >0) {
        FMDTUpdateObjectCommand * ucmd = FMDT_UPDATE_OBJECT(dbSet.needUploadPatch);
        [ucmd addWithArray:tempArr];
        [ucmd saveChanges];
    }
    NSLog(@"完成删除LocalPatch中的Photos");
}


//删除 照片
+(void) mediaTask_DeleteWithShareId:(NSString *)shareId andDeleteArr:(NSArray<NSString *> *)arr{
    [self Patch_RemovePhotosPatchAtMeidaShare:shareId andPhotos:arr];
    [self mediaTask_DeletePhotoAtMediaShare:shareId andDelArr:arr];
}



+(void) mediaTask_DeletePhotoAtMediaShare:(NSString *)shareId andDelArr:(NSArray *)delArr{
    FMDBSet * dbSet = [FMDBSet shared];
    FMDTSelectCommand *scmd = FMDT_SELECT(dbSet.needUploadMediaShare);
    [scmd where:@"uuid" equalTo:shareId];
    NSArray * result = [scmd fetchArray];
    NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
    for (FMNeedUploadMediaShare * mediaShare in result) {
        NSMutableArray * netPhotos = [NSMutableArray arrayWithArray:mediaShare.netPhotos];
        NSMutableArray * localPhotos = [NSMutableArray arrayWithArray:mediaShare.localPhotos];
        [netPhotos removeObjectsInArray:delArr];
        [localPhotos removeObjectsInArray:delArr];
        mediaShare.netPhotos = netPhotos;
        mediaShare.localPhotos = localPhotos;
        [tempArr addObject:mediaShare];
    }
    if (tempArr.count >0) {
        FMDTUpdateObjectCommand * ucmd = FMDT_UPDATE_OBJECT(dbSet.needUploadMediaShare);
        [ucmd addWithArray:tempArr];
        [ucmd saveChanges];
    }
    NSLog(@"完成删除LocalMediaShare中的Photos");
}



+(void) mediaTask_AddWithShareId:(NSString *)shareId andAddLocalArr:(NSArray<NSString *> *)localArr andNetArr:(NSArray<NSString *> *)netArr{
    FMDBSet * dbSet = [FMDBSet shared];
    NSArray * result = [self  managerGetCanEditShareWithShareId:shareId];
    NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
    for (FMNeedUploadMediaShare * mediaShare in result) {
        NSMutableSet * netPhotos = [NSMutableSet setWithArray:mediaShare.netPhotos];
        NSMutableSet * localPhotos = [NSMutableSet setWithArray:mediaShare.localPhotos];
        if (netArr)
            [netPhotos addObjectsFromArray:netArr];
        if (localArr)
            [localPhotos addObjectsFromArray:localArr];
        mediaShare.netPhotos = [netPhotos allObjects];
        mediaShare.localPhotos = [localPhotos allObjects];
        
        [tempArr addObject:mediaShare];
    }
    if (tempArr.count >0) {
        FMDTUpdateObjectCommand * ucmd = FMDT_UPDATE_OBJECT(dbSet.needUploadMediaShare);
        [ucmd addWithArray:tempArr];
        [ucmd saveChanges];
    }else{
        //创建一个新的 Patch
        NSMutableArray * tempPhotos = [NSMutableArray arrayWithArray:localArr];
        [tempPhotos addObjectsFromArray:netArr];
        [self mediaTask_AddAtPatchWithShareId:shareId andPhotos:tempPhotos];
        NSLog(@"追加时创建了一个新的本地Patch");
    }
}

+(void) mediaTask_AddAtPatchWithShareId:(NSString * )shareId andPhotos:(NSArray *)photos{
    //本地Patch中找
     FMDBSet * dbSet = [FMDBSet shared];
    FMDTSelectCommand *patchCmd = FMDT_SELECT(dbSet.needUploadPatch);
    [patchCmd where:@"shareid" equalTo:shareId];
    NSArray * patchrResult = [patchCmd fetchArray];
    if (patchrResult.count) {
         NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
        for (FMNeedUploadPatch * patch in patchrResult) {
            NSMutableArray * arr = [NSMutableArray arrayWithArray:patch.addLocalArr];
            [arr addObjectsFromArray:photos];
            patch.addLocalArr = arr;
            [tempArr addObject:patch];
        }
        if (tempArr.count >0) {
            FMDTUpdateObjectCommand * ucmd = FMDT_UPDATE_OBJECT(dbSet.needUploadPatch);
            [ucmd addWithArray:tempArr];
            [ucmd saveChanges];
        }
    }else{
        //创建新的Patch
        FMNeedUploadPatch * patch = [FMNeedUploadPatch new];
        patch.addLocalArr = photos;
        patch.shareid = shareId;
        [self mediaTaskAddPatchWithPatch:patch];
    }
}

//查询patch
+(NSArray *)mediaTask_SelectPatchWithShareId:(NSString *)shareId{
    FMDBSet * dbSet = [FMDBSet shared];
    FMDTSelectCommand *patchCmd = FMDT_SELECT(dbSet.needUploadPatch);
    [patchCmd where:@"shareid" equalTo:shareId];
    NSArray * patchrResult = [patchCmd fetchArray];
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    for (FMNeedUploadPatch * pat in patchrResult) {
        [tempArr addObjectsFromArray:pat.addLocalArr];
    }
    return tempArr;
}

//新建 本地评论
+(id<FMCommentsProtocol>)mediaTaskAddCommentWithShareId:(NSString *)shareId andPhotoHash:(NSString *)photoHash andText:(NSString *)text{
    FMDBSet * dbSet = [FMDBSet shared];
    FMDTInsertCommand *icmd = FMDT_INSERT(dbSet.needUploadComments);
    FMNeedUploadComments * comment = [FMNeedUploadComments new];
    comment.shareid = shareId;
    comment.photoDigest = photoHash;
    comment.text = text;
    comment.createDate = [[NSDate date] timeIntervalSince1970]*1000;
    comment.creator = DEF_UUID;
    [icmd add:comment];
    [icmd saveChanges];
    
    NSLog(@"添加一条评论到本地数据库:needUploadComments");
    return comment;
}

+(NSArray *)mediaTask_SelectCommentWithPhotoHash:(NSString *)hash{
    FMDBSet * dbSet = [FMDBSet shared];
    FMDTSelectCommand * scmd = FMDT_SELECT(dbSet.needUploadComments);
    [scmd where:@"photoDigest" equalTo:hash];
    return [scmd fetchArray];
}





+(void)mediaTaskUpdateAtPatch:(FMNeedUploadPatch *)patch{
    FMDBSet * dbSet = [FMDBSet shared];
    FMDTUpdateObjectCommand * ucmd = FMDT_UPDATE_OBJECT(dbSet.needUploadMediaShare);
    [ucmd add:patch];
    [ucmd saveChanges];
}



//查 相册
+(NSArray *)mediaTaskGetPatch{
    FMDBSet * dbSet = [FMDBSet shared];FMDTSelectCommand * scmd = FMDT_SELECT(dbSet.needUploadPatch);
    return [scmd fetchArray];
}




+(BOOL)mediaShareIsLocal:(NSString *)shareId{
    FMDBSet * dbSet = [FMDBSet shared];
    FMDTSelectCommand *scmd = FMDT_SELECT(dbSet.needUploadMediaShare);
    [scmd where:@"uuid" equalTo:shareId];
    [scmd where:@"state" notEqualTo:UPLOADED];
    NSArray * result = [scmd fetchArray];
    return result.count>0;
}

@end
