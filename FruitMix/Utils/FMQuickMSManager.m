//
//  FMQuickMSManager.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/30.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMQuickMSManager.h"
#import "FMMediaShareTask.h"
#import "FMQuickUploader.h"

@interface FMQuickMSManager ()
@property (nonatomic) QuickUploaderCompleteBlock successBlock;

@property (nonatomic) NSMutableArray * uploadingArr;

@end

@implementation FMQuickMSManager{

}

+(instancetype)shareInstancetype{
    static FMQuickMSManager * task = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        task = [[FMQuickMSManager alloc]init];
        task.isFinishd = NO;
    });
    return task;
}


-(void)addLocalMeidaShareToUpload:(FMNeedUploadMediaShare *)mediaShare{
    if(!self.isFinishd){
        [self.uploadingArr addObject:mediaShare];
    }else{
        NSLog(@"mediashare 插入队列失败，重新生成队列");
        [self startUploadLocalMediaShare];
    }
}

-(void)startUploadLocalMediaShare{
    FMQuickUploader * uploader = [[FMQuickUploader alloc]init];
    NSMutableArray * localMSArr = [NSMutableArray arrayWithArray:[FMMediaShareTask mediaTaskGetLocalMediaShare]];
    _uploadingArr = localMSArr;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    __block float totalProgress = 0.0f;
    __block float partProgress = 1.0f / [_uploadingArr count];
    __block NSUInteger currentIndex = 0;
    
     __weak typeof(self) weakSelf = self;
    if(_uploadingArr.count){
        self.successBlock = ^(NSString * mediaShareId ,NSString * state){
            [array addObject:mediaShareId];
            [weakSelf updateLocalMediaStateAtMedia:mediaShareId andState:state];
            totalProgress += partProgress;
            currentIndex++;
            if ([array count] >= [_uploadingArr count]) {
                weakSelf.isFinishd = YES;
                [weakSelf startToUploadPatch];
                return;
            }
            else {
                FMNeedUploadMediaShare * mediaShare = weakSelf.uploadingArr[currentIndex];
                [uploader startWithPhotos:mediaShare.uuid andCompleteBlock:weakSelf.successBlock];
            }
        };
        FMNeedUploadMediaShare * mediaShare = _uploadingArr[0];
        [uploader startWithPhotos:mediaShare.uuid andCompleteBlock:weakSelf.successBlock];
    }else{
        self.isFinishd = YES;
        [self startToUploadPatch];
    }
}


-(void)updateLocalMediaStateAtMedia:(NSString *)mediaShareId andState:(NSString *)state{
    if (IsEquallString(state, UPLOADED)) {
        //上传mediashare
        NSArray * tempArr = [FMMediaShareTask mediaTaskGetLocalMediaShareWithShareId:mediaShareId];
        if (tempArr.count) {
//            __weak typeof(self) weakSelf = self;
//            FMNeedUploadMediaShare * share = tempArr[0];
//            NSString * album = [share.album integerValue] == 1?@"true":@"false";
//            NSArray * maintainer = share.maintainers;
//            NSArray * viewers = share.viewers;
//            if (!maintainer) {
//                maintainer = [NSArray array];
//            }
//            if (!viewers) {
//                viewers = [NSArray array];
//            }
//            FMPostNewShareAPI * api = [[FMPostNewShareAPI alloc]initWithContents:share.getUploadContents andAlbum:album andMaintainers:maintainer andViewers:viewers andTags:share.tags];
//            [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//                NSLog(@"LocalMediaShare上传成功:%@",request.responseJsonObject[@"uuid"]);
//                //更新mediaShare 的nas 端id
//                NSString * uuid = request.responseJsonObject[@"uuid"];
//                share.netShareId = uuid;
//                share.state = UPLOADED;
//                [FMMediaShareTask managerUpdateAtMediaShare:share];
//                [weakSelf uploadLocalCommentsWithMediaShare:share];
//                
//                [FMUpdateDocumentTool mediaShareNeedUpdate];//需要刷新mediaShare
//                [[NSNotificationCenter defaultCenter] postNotificationName:FM_NEED_UPDATE_UI_NOTIFY object:nil];
//            } failure:^(__kindof JYBaseRequest *request) {
//                NSLog(@"创建失败 %@",request.error);
//            }];

        }
    }
}


-(void)updateLocalPatchAtPatch:(NSString *)patchid andState:(NSString *)state{
    if (IsEquallString(state, UPLOADED)) {
        FMDBSet * dbSet = [FMDBSet shared];
        FMDTSelectCommand * scmd = FMDT_SELECT(dbSet.needUploadPatch);
        [scmd where:@"localid" equalTo:patchid];
        NSArray * arr = [scmd fetchArray];
        if (arr.count) {
            FMNeedUploadPatch * patch = arr[0];
            FMMediaPatchAPI * api = [FMMediaPatchAPI new];
            for (NSString * digest in patch.addLocalArr) {
                NSMutableDictionary * contents = [[NSMutableDictionary alloc]init];
                [contents setValue:digest forKey:@"digest"];
                [contents setValue:@"media" forKey:@"type"];
                [api addPatchType:PatchTypeAdd andPath:patch.shareid andValue:contents];
            }
            if (api.patchArr.count>0) {
                [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
                    NSLog(@"成功上传一个  add patch 到服务端");
                    FMDBSet * dbSet = [FMDBSet shared];
                    FMDTDeleteCommand * dcmd = FMDT_DELETE(dbSet.needUploadPatch);
                    [dcmd where:@"localid" equalTo:patchid];
                    [dcmd saveChanges];//保存 删除;
                } failure:^(__kindof JYBaseRequest *request) {
                    NSLog(@"失败：%@",request.error);
                    
                }];
            }
        }
        
    }
}

-(void)uploadLocalCommentsWithMediaShare:(FMNeedUploadMediaShare *)meidaShare{
    FMDBSet * dbSet = [FMDBSet shared];
    FMDTSelectCommand * scmd = FMDT_SELECT(dbSet.needUploadComments);
    [scmd where:@"shareid" equalTo:meidaShare.uuid];
    NSArray * uploadComments = [scmd fetchArray];
    if (uploadComments.count) {
        for (FMNeedUploadComments *comments in uploadComments) {
            if ([meidaShare.netPhotos containsObject:comments.photoDigest]) {
                __weak typeof(self) weakSelf = self;
                [FMPostCommentAPI postNewCommentWithComment:comments.text andPhotoDigest:comments.photoDigest andShareId:meidaShare.netShareId andCompleteBlock:^(BOOL success, id response) {
                    if (success) {
                        [weakSelf delLocalCommentWithCommentId:comments.commentId];
                    }
                }];
            }
        }
    }else{
        
    }
}

//删除一条评论
-(void)delLocalCommentWithCommentId:(NSString *)commentId{
    
    FMDBSet * dbSet = [FMDBSet shared];
    FMDTDeleteCommand * dcmd = FMDT_DELETE(dbSet.needUploadComments);
    [dcmd where:@"commentId" equalTo:commentId];
    [dcmd saveChanges];
}

- (void)startToUploadPatch{
    FMQuickUploader * uploader = [[FMQuickUploader alloc]init];
    NSArray * localPArr = [FMMediaShareTask mediaTaskGetPatch];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    __block float totalProgress = 0.0f;
    __block float partProgress = 1.0f / [localPArr count];
    __block NSUInteger currentIndex = 0;
    
    __weak typeof(self) weakSelf = self;
    if(localPArr.count){
        self.successBlock = ^(NSString * mediaShareId ,NSString * state){
            [array addObject:mediaShareId];
            [weakSelf updateLocalPatchAtPatch:mediaShareId andState:state];
            totalProgress += partProgress;
            currentIndex++;
            if ([array count] >= [localPArr count]) {
                return;
            }
            else {
                FMNeedUploadPatch * patch = localPArr[currentIndex];
                [uploader startWithPatch:patch.localid andCompleteBlock:weakSelf.successBlock];
            }
        };
        FMNeedUploadPatch * patch = localPArr[0];
        [uploader startWithPatch:patch.localid andCompleteBlock:weakSelf.successBlock];
    }
}

@end
