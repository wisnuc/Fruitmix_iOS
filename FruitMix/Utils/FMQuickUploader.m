//
//  FMQuickUploader.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/26.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMQuickUploader.h"
#import "FMMediaShareTask.h"

#define QuickUploaderTypeMediaShare @"mediaShare"
#define QuickUploaderTypePatch  @"patch"

@interface FMQuickUploader ()

@property (copy, nonatomic) void (^singleSuccessBlock)(NSString *);
@property (copy, nonatomic)  void (^singleFailureBlock)();

@end

@implementation FMQuickUploader{
    NSString * _mediaShareId;
    FMNeedUploadMediaShare * _mediaShare;
    
    NSString * _patchId;
    FMNeedUploadPatch * _patch;
}

-(void)startWithPhotos:(NSString *)mediaShareId andCompleteBlock:(QuickUploaderCompleteBlock)block{
    _mediaShareId = mediaShareId;
    FMDBSet * dbSet = [FMDBSet shared];
    FMDTSelectCommand * scmd = FMDT_SELECT(dbSet.needUploadMediaShare);
    [scmd where:@"uuid" equalTo:mediaShareId];
    NSArray * arr = [scmd fetchArray];
    if (arr.count) {
        _mediaShare = arr[0];
        NSArray * localPhotosArr = [_mediaShare localPhotos];
        if(localPhotosArr.count){
            [self uploadImages:localPhotosArr success:^(NSArray * arr) {
                NSLog(@"上传一个LocalMediaShare成功");
                if (block) {
                    block(mediaShareId,UPLOADED);
                }
            } failure:^{
                NSLog(@"上传一个LocalMediaShare失败");
                if (block) {
                    block(mediaShareId,FAILED);
                }
            } andType:QuickUploaderTypeMediaShare];
        }else{
            if (block) {
                NSLog(@"%@ ： 此mediaShare没有 需要上传的照片",mediaShareId);
                block(mediaShareId,UPLOADED);
            }
        }
    }
}

-(void)startWithPatch:(NSString *)patchId andCompleteBlock:(QuickUploaderCompleteBlock)block{
    _patchId = patchId;
    FMDBSet * dbSet = [FMDBSet shared];
    FMDTSelectCommand * scmd = FMDT_SELECT(dbSet.needUploadPatch);
    [scmd where:@"localid" equalTo:patchId];
    NSArray * arr = [scmd fetchArray];
    if (arr.count) {
        _patch = arr[0];
        NSArray * localPhotosArr = _patch.addLocalArr;
        if(localPhotosArr.count){
            [self uploadImages:localPhotosArr success:^(NSArray * arr) {
                NSLog(@"上传一个Localpatch成功");
                if (block) {
                    block(patchId,UPLOADED);
                }
            } failure:^{
                NSLog(@"上传一个LocalPatch失败");
                if (block) {
                    block(patchId,FAILED);
                }
            } andType:QuickUploaderTypePatch];
        }else{
            if (block) {
                NSLog(@"%@ ： 此 patch 没有 需要上传的照片",patchId);
                block(patchId,UPLOADED);
            }
        }
    }
}


-(void)uploadImages:(NSArray *)imageArr success:(void (^)(NSArray *))success failure:(void (^)())failure  andType:(NSString *)type{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    __block float totalProgress = 0.0f;
    __block float partProgress = 1.0f / [imageArr count];
    __block NSUInteger currentIndex = 0;
    __weak typeof(self) weakSelf = self;
    self.singleFailureBlock = ^() {
        NSLog(@"上传失败");
        failure();
        return;
    };
    self.singleSuccessBlock  = ^(NSString *url) {
        NSLog(@"%@",url);
        [array addObject:url];
        totalProgress += partProgress;
        currentIndex++;
        NSLog(@"共%ld张需要上传,已上传%ld张",(unsigned long)imageArr.count,(unsigned long)currentIndex);
        if ([array count] >= [imageArr count]) {
            success([array copy]);
            return;
        }
        else {
            
            [weakSelf quickUploadImage:imageArr[currentIndex] success:weakSelf.singleSuccessBlock failure:weakSelf.singleFailureBlock andType:type];
        }
    };
    [self quickUploadImage:imageArr[0] success:weakSelf.singleSuccessBlock failure:weakSelf.singleFailureBlock andType:type];
}


-(void)quickUploadImage:(NSString *)photohash success:(void (^)(NSString *url))success failure:(void (^)())failure andType:(NSString *)type{
    @autoreleasepool {
        BOOL shouldUploaded = YES;
        NSArray * photoArr = [self uploadImagesLocalIds:photohash];
        if (photoArr.count>0) {
            FMLocalPhoto * photo = photoArr[0];
            shouldUploaded = !photo.uploadTime;
        }
        //判断是否为已上传 照片
        if (!shouldUploaded) {
            if (success) {
                if (IsEquallString(type, QuickUploaderTypeMediaShare)) {
                    [self successUploadWithPhotoHash:photohash];
                }
                NSLog(@"%@ 一张照片早已上传",QuickUploaderTypeMediaShare);
                success(@"has already uploaded");
            }
            return;
        }
        
        NSMutableArray * tempLocalidArr = [NSMutableArray arrayWithCapacity:0];
        for (FMLocalPhoto * photo in photoArr) {
            [tempLocalidArr addObject:photo.localIdentifier];
        }
        
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        PHFetchResult * result = [PHAsset fetchAssetsWithLocalIdentifiers:tempLocalidArr options:option];
        PHAsset * asset = nil;
        //判断该文件是否还存在
        if(result.count>0)
            asset = result[0];
        else{
            if (IsEquallString(QuickUploaderTypeMediaShare, type)) {
                [self jumpUploadWithPhotoHash:photohash];
            }
            if (IsEquallString(QuickUploaderTypePatch, type)) {
                [self jumpUploadPhotoAtPatchWithPhotoHash:photohash];
            }
            NSLog(@"QucikUploader:找不到这张照片：%@,从 %@ 删除",photohash,type);
            
            //找不到这张照片
            if (success) {
                success(@"notfound");
            }
            return ;
        }
        dispatch_async([FMUtil setterQuickUploadQueue], ^{
            [PhotoManager getImageDataWithPHAsset:asset andCompleteBlock:^(NSString *filePath) {
                if (filePath) {
                    NSString * str = photohash;
                    NSString * url = [NSString stringWithFormat:@"%@library/%@?hash=%@",[JYRequestConfig sharedConfig].baseURL,[PhotoManager getUUID],str];
                    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" fileName:@"file" mimeType:@"image/jpeg" error:nil];
                    } error:nil];
                    [request setValue:[NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
                    AFURLSessionManager * afManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                    afManager.responseSerializer = [AFHTTPResponseSerializer serializer];
                    NSURLSessionUploadTask *uploadTask;
                    uploadTask = [afManager
                                  uploadTaskWithStreamedRequest:request
                                  progress:^(NSProgress *uploadProgress){
                                      
                                  }
                                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                      NSHTTPURLResponse * rep = (NSHTTPURLResponse *)response;
                                      if (rep.statusCode == 200) {//成功
                                          if (IsEquallString(QuickUploaderTypeMediaShare, type)) {
                                              [self successUploadWithPhotoHash:photohash];
                                          }
                                          if (success) {
                                              success(str);
                                          }
                                      }else{ //失败
                                          NSLog(@"QuickUploader:一张照片上传失败：%@",photohash);
                                          //调用 成功
                                          if (failure) {
                                              failure();
                                          }
                                      }
                                  }];
                    [uploadTask resume];
                }
                else{
                    if (IsEquallString(QuickUploaderTypeMediaShare, type)) {
                        [self jumpUploadWithPhotoHash:photohash];
                    }
                    if (IsEquallString(QuickUploaderTypePatch, type)) {
                        [self jumpUploadPhotoAtPatchWithPhotoHash:photohash];
                    }
                    
                    NSLog(@"QuickUploader:跳过一个视频文件");
                    if (success) {
                        success(@"jump video");
                    }
                }
            }];
        });
    }
}

/************************************************************************************************************************************************************/
/***********************************************************   LocalMediaShare  *****************************************************************************/
/************************************************************************************************************************************************************/

-(NSArray *)uploadImagesLocalIds:(NSString *)photoHash{
    FMDBSet *set = [FMDBSet shared];
    FMDTSelectCommand * scmd = FMDT_SELECT(set.photo);
    [scmd where:@"degist" equalTo:photoHash];
    return [scmd fetchArray];
}

-(void)jumpUploadWithPhotoHash:(NSString *)photoHash{
    NSMutableArray * tempDelArr = [NSMutableArray arrayWithArray:_mediaShare.localPhotos];
    [tempDelArr removeObject:photoHash];
    _mediaShare.localPhotos = tempDelArr;
    [FMMediaShareTask managerUpdateAtMediaShare:_mediaShare];
}

-(void)successUploadWithPhotoHash:(NSString *)photoHash{
    //删除未上传
    NSMutableArray * tempDelArr = [NSMutableArray arrayWithArray:_mediaShare.localPhotos];
    [tempDelArr removeObject:photoHash];
    //增加已上传
    NSMutableArray * tempAddArr = [NSMutableArray arrayWithArray:_mediaShare.netPhotos];
    [tempAddArr addObject:photoHash];
    _mediaShare.netPhotos = tempAddArr;
    _mediaShare.localPhotos = tempDelArr;
    [FMMediaShareTask managerUpdateAtMediaShare:_mediaShare];
}


/************************************************************************************************************************************************************/
/****************************************************************   LocalPatch  *****************************************************************************/
/************************************************************************************************************************************************************/


-(void)jumpUploadPhotoAtPatchWithPhotoHash:(NSString *)hash{
    //删除未上传
    NSMutableArray * tempDelArr = [NSMutableArray arrayWithArray:_patch.addLocalArr];
    [tempDelArr removeObject:hash];
    [FMMediaShareTask mediaTaskUpdateAtPatch:_patch];
}

@end
