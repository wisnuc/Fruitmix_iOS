//
//  FMPostNewShareAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/5/5.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMPostNewShareAPI.h"
#import "FMMediaShareTask.h"
#import "FMQuickMSManager.h"


@implementation FMPostNewShareAPI

-(instancetype)initWithContents:(id)contents andAlbum:(NSString *)isAlbum andMaintainers:(NSArray *)arr andViewers:(NSArray *)viewers andTags:(NSArray *)tags{
    if (self = [super init]) {
        NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
        NSData *contestData=[NSJSONSerialization dataWithJSONObject:contents options:0 error:nil];
        [dic setValue:[[NSString alloc]initWithData:contestData encoding:NSUTF8StringEncoding] forKey:@"contents"];
        
        [dic setValue:isAlbum forKey:@"album"];
        
        NSData *maintainersData=[NSJSONSerialization dataWithJSONObject:arr options:0 error:nil];
        [dic setValue:[[NSString alloc]initWithData:maintainersData encoding:NSUTF8StringEncoding] forKey:@"maintainers"];
        
        if (tags) {
//            NSData *viewersData=[NSJSONSerialization dataWithJSONObject:tags options:0 error:nil];
            [dic setValue:tags forKey:@"tags"];
        }else
            [dic setObject:[NSArray array] forKey:@"tags"];
        
        NSData *viewersData=[NSJSONSerialization dataWithJSONObject:viewers options:0 error:nil];
        [dic setValue:[[NSString alloc]initWithData:viewersData encoding:NSUTF8StringEncoding] forKey:@"viewers"];
        
        //是否归档：不归档
        [dic setObject:@"false" forKey:@"archived"];
        
        self.param = dic;
        
    }
    return self;
}

+(void)fm_PostAlbumWithArray:(NSArray *)arr andName:(NSString *)name andDesc:(NSString *)desc andIsPublic:(BOOL)isPublic andCanEdit:(BOOL)canEdit{
    NSMutableArray * contents = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray * localPhotos = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray * netPhotos = [NSMutableArray arrayWithCapacity:0];
    for (id photo in arr) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
        if ([photo isKindOfClass:[FMPhotoAsset class]]) {
            if ([(FMPhotoAsset *)photo degist]) {
                [dic setValue:[(FMPhotoAsset *)photo degist] forKey:@"digest"];
            }else{
                PHFetchOptions *option = [[PHFetchOptions alloc] init];
                PHFetchResult * result = [PHAsset fetchAssetsWithLocalIdentifiers:@[((FMPhotoAsset *)photo).localId] options:option];
                if (result.count) {
                    [PhotoManager getImageFromPHAsset:result[0] Complete:^(NSData *fileData, NSString *fileName) {
                        NSString * localDegist = [CocoaSecurity sha256WithData:fileData].hexLower;
                        [dic setValue:localDegist forKey:@"digest"];
                        [(FMPhotoAsset *)photo setDegist:localDegist];
                        
                        //更新数据库
                        FMDTUpdateCommand * ucmd = [[FMDBSet shared].photo createUpdateCommand];
                        [ucmd fieldWithKey:@"degist" val:localDegist];
                        [ucmd where:@"localIdentifier" equalTo:[(FMPhotoAsset *)photo localId]];
                        [ucmd saveChanges];
                    }];
                }else //跳过循环
                    continue;
            }
            [dic setValue:@"media" forKey:@"type"];
            [localPhotos addObject:[(FMPhotoAsset *)photo degist]];
        }else{
            NSString * photoHash = [photo getPhotoHash];
            [netPhotos addObject:photoHash];
            [dic setValue:photoHash forKey:@"digest"];
            [dic setValue:@"media" forKey:@"type"];
        }
        [contents addObject:dic];
    }
    
    //合成相关元素
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:name forKey:@"albumname"];
    [dic setValue:desc forKey:@"desc"];
    NSMutableArray * tags = [NSMutableArray arrayWithObject:dic];
    
    NSMutableArray * viewers = [NSMutableArray arrayWithCapacity:0];
    if (isPublic) {
        FMDBSet * set = [FMDBSet shared];
        FMDTSelectCommand * cmd = FMDT_SELECT(set.users);
        NSArray * users =  [cmd fetchArray];
        for (FMUsers *user in users) {
            [viewers addObject:user.uuid];
        }
    }else{
        [viewers addObject:DEF_UUID];
    }
    
    NSMutableArray * maintainersArr = nil;
    maintainersArr = canEdit ? viewers:[NSMutableArray arrayWithObject:DEF_UUID];
  
    //判断是否需要本地 推入 队列（是否有照片未上传）
    if(localPhotos.count>0){
        //需要TaskQueue
        FMNeedUploadMediaShare *share = [[FMNeedUploadMediaShare alloc]init];
//        share.archived = @(0);
//        share.album = @(1);
//        share.contents = contents;
//        share.viewers = viewers;
//        share.tags = tags;
//        share.maintainers = maintainersArr;
//        share.netPhotos = netPhotos;
//        share.localPhotos = localPhotos;
//        NSTimeInterval time=[[NSDate date] timeIntervalSince1970]*1000;
//        share.createDate = (long long)time;
//        share.creator = DEF_UUID;
//        share.state = UNUPLOAD;
        [FMMediaShareTask mediaTaskAddTask:share];
        
        FMQuickMSManager * manager = [FMQuickMSManager shareInstancetype];
        if (manager.isFinishd) {
            [manager startUploadLocalMediaShare];
        }else
            [manager addLocalMeidaShareToUpload:share];
        
    }else{
        FMPostNewShareAPI * api = [[FMPostNewShareAPI alloc]initWithContents:contents andAlbum:@"true" andMaintainers:maintainersArr andViewers:viewers andTags:tags];
        
        [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            NSLog(@"创建成功:%@",request.responseJsonObject);
        } failure:^(__kindof JYBaseRequest *request) {
            NSLog(@"创建失败 %@",request.error);
        }];
        
    }
}


+(void)fm_PostPhotosWithArray:(NSArray *)arr{
    NSMutableArray * contents = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray * localPhotos = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray * netPhotos = [NSMutableArray arrayWithCapacity:0];
    
    for (id photo in arr) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
        if ([photo isKindOfClass:[FMPhotoAsset class]]) {
            if ([(FMPhotoAsset *)photo degist]) {
                [dic setValue:[(FMPhotoAsset *)photo degist] forKey:@"digest"];
            }else{
                PHFetchOptions *option = [[PHFetchOptions alloc] init];
                PHFetchResult * result = [PHAsset fetchAssetsWithLocalIdentifiers:@[((FMPhotoAsset *)photo).localId] options:option];
                if(result.count){
                    [PhotoManager getImageFromPHAsset:result[0] Complete:^(NSData *fileData, NSString *fileName) {
                        NSString * localDegist = [CocoaSecurity sha256WithData:fileData].hexLower;
                        [dic setValue:localDegist forKey:@"digest"];
                        //更新数据库
                        FMDTUpdateCommand * ucmd = [[FMDBSet shared].photo createUpdateCommand];
                        [ucmd fieldWithKey:@"degist" val:localDegist];
                        [ucmd where:@"localIdentifier" equalTo:[(FMPhotoAsset *)photo localId]];
                        [ucmd saveChanges];
                    }];
                }else
                    continue;
                
            }
            [dic setValue:@"media" forKey:@"type"];
            [localPhotos addObject:[(FMPhotoAsset *)photo degist]];
        }else if ([photo isKindOfClass:[FMNASPhoto class]]){
            NSString * photoHash = [photo getPhotoHash];
            [netPhotos addObject:photoHash];
            
            [dic setValue:photoHash forKey:@"digest"];
            [dic setValue:@"media" forKey:@"type"];
        }
//        [dic setObject:DEF_UUID forKey:@"creator"];
//        NSTimeInterval time=[[NSDate date] timeIntervalSince1970]*1000;
//        double i=time;      //NSTimeInterval返回的是double类型
//        [dic setObject:[NSString stringWithFormat:@"%ld",(NSInteger)i] forKey:@"ctime"];
        [contents addObject:dic];
    }
    
    //所有的用户
    FMDBSet * set = [FMDBSet shared];
    FMDTSelectCommand * cmd = FMDT_SELECT(set.users);
    NSArray * users =  [cmd fetchArray];
    NSMutableArray * viewers = [NSMutableArray arrayWithCapacity:0];
    for (FMUsers *user in users) {
        [viewers addObject:user.uuid];
    }
    
    //判断是否需要本地 推入 队列（是否有照片未上传）
    if(localPhotos.count>0){
        //需要TaskQueue
//        FMNeedUploadMediaShare *share = [[FMNeedUploadMediaShare alloc]init];
//        share.archived = @(0);
//        share.album = @(0);
//        share.contents = contents;
//        share.viewers = viewers;
//        share.netPhotos = netPhotos;
//        share.localPhotos = localPhotos;
//        NSTimeInterval time=[[NSDate date] timeIntervalSince1970]*1000;
//        share.createDate = (long long)time;
//        share.creator = DEF_UUID;
//        share.state = UNUPLOAD;
//        [FMMediaShareTask mediaTaskAddTask:share];
//        
//        FMQuickMSManager * manager = [FMQuickMSManager shareInstancetype];
//        if (manager.isFinishd) {
//            [manager startUploadLocalMediaShare];
//        }else
//            [manager addLocalMeidaShareToUpload:share];
    }else{
        FMPostNewShareAPI * api = [[FMPostNewShareAPI alloc]initWithContents:contents andAlbum:@"false" andMaintainers:@[DEF_UUID] andViewers:viewers andTags:nil];
        [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            NSLog(@"分享成功 %@",request.responseJsonObject);
        } failure:^(__kindof JYBaseRequest *request) {
            NSLog(@"分享失败 %@",request.error);
        }];
    }
}

/*******************************************delegate*****************************************************/

-(id)requestArgument{
    NSLog(@"%@",_param);
    return self.param;
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodPost;
}
/// 请求的URL
- (NSString *)requestUrl{
    return @"mediashare";
}

-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}

- (id)responseSerialization{
    AFHTTPResponseSerializer * js = [AFHTTPResponseSerializer serializer];
    return js;
}
@end
