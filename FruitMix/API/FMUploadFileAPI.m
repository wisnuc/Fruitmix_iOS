//
//  FMUploadFileAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/10/25.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMUploadFileAPI.h"
#import "FLCreateFolderAPI.h"
#import "FLGetFilesAPI.h"
#import "FLFilesModel.h"
#import "DriveModel.h"
#import "DirectoriesModel.h"
#import "EntriesModel.h"
#import "PhotoManager.h"
@implementation FMUploadFileAPI
NSInteger imageUploadCount = 0;
+(void)uploadAddressFileWithFilePath:(NSString *)filePath  andCompleteBlock:(void(^)(BOOL success))completeBlock{
    [[FLGetFilesAPI apiWithFileUUID:[FMConfiguation shareConfiguation].userHome]startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSArray * arr = request.responseJsonObject;
        BOOL hasAddressDir = NO;
        NSString * uuid;
        for (NSDictionary * dic in arr) {
            FLFilesModel * model = [FLFilesModel yy_modelWithJSON:dic];
            if(IsEquallString(model.name, @"addressbook")){
                hasAddressDir = YES;
                uuid = model.uuid;
                break;
            }
        }
        
        if(hasAddressDir){
            //上传Address文件
            [self _uploadAddressFile:filePath andFolderUUID:uuid andCompleteBlock:completeBlock];
        }else{
            //创建addressbook 文件夹
            [[FLCreateFolderAPI apiWithParentUUID:[FMConfiguation shareConfiguation].userHome andFolderName:@"addressbook"]
             startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
                NSDictionary * dic = request.responseJsonObject;
                NSString * uuid = dic[UUIDKey];
                NSLog(@"创建 addressbook 文件夹 成功");
                [FMUploadFileAPI _uploadAddressFile:filePath andFolderUUID:uuid andCompleteBlock:completeBlock];
            } failure:^(__kindof JYBaseRequest *request) {
                NSLog(@"创建 addressbook 文件夹 失败");
                completeBlock(NO);
            }];
        }
    } failure:^(__kindof JYBaseRequest *request) {
        completeBlock(NO);
    }];
}

+ (void)getDriveInfoCompleteBlock:(void(^)(BOOL successful))completeBlock{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *urlString = [NSString stringWithFormat:@"%@drives",[JYRequestConfig sharedConfig].baseURL];
     [manager.requestSerializer setValue: [NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
    NSLog(@"%@",DEF_Token);
    [manager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray * responseArr = responseObject;
        NSLog(@"%@",responseObject);
        for (NSDictionary *dic in responseArr) {
            @autoreleasepool {
                DriveModel *model = [DriveModel yy_modelWithJSON:dic];
                NSLog(@"%@",model.uuid);
                [[NSUserDefaults standardUserDefaults] setObject:model.uuid forKey:DRIVE_UUID_STR];
                [[NSUserDefaults standardUserDefaults] synchronize];
                completeBlock(YES);
            }
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
    
  }

+ (void)getDirectoriesCompleteBlock:(void(^)(BOOL successful))completeBlock{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *urlString = [NSString stringWithFormat:@"%@drives/%@/dirs",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID];
    [manager.requestSerializer setValue: [NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
    [manager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray * responseArr = responseObject;
        NSLog(@"%@",responseObject);
        for (NSDictionary *dic in responseArr) {
            @autoreleasepool {
            DirectoriesModel *model = [DirectoriesModel yy_modelWithJSON:dic];
            NSLog(@"%@",model.uuid);
                if ([model.parent isEqualToString:@""]) {
                    [[NSUserDefaults standardUserDefaults] setObject:model.uuid forKey:DIR_UUID_STR];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    completeBlock(YES);
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];

}
+ (void)getDirEntrySuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID,DIR_UUID];
    [manager.requestSerializer setValue: [NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
    [manager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//          NSLog(@"%@",responseObject);
    
        success(task,responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
//              failure(task,error);
    }];

}

+ (void)getDirEntryWithUUId:(NSString *)uuid
                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID,uuid];
    [manager.requestSerializer setValue: [NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
    [manager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"%@",responseObject);
        
        success(task,responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%@",error);
        failure(task,error);
    }];
}

//(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject
+ (void)uploadDirEntryWithFilePath:(NSString *)filePath
                           success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
{
//    imageUploadCount++;
//    NSMutableArray *photoArr = [NSMutableArray array];
//    for (int i=0; i<imageUploadCount; i++) {
//        [photoArr addObject:filePath];
//    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSString * hashString = [FileHash sha256HashOfFileAtPath:filePath];
    NSString *urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries/",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID,ENTRY_UUID];
   NSInteger sizeNumber = (NSInteger)[FMUploadFileAPI fileSizeAtPath:filePath];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];

    [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // 上传 多张图片
//        for(NSInteger i = 0; i < photoArr.count; i++)
//        {
            NSString * exestr = [filePath lastPathComponent];
            
            NSString *str = [NSString stringWithFormat:@"{\"size\":%ld,\"sha256\":\"%@\"}",(long)sizeNumber ,hashString];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
            [formData appendPartWithFileData:data name:exestr fileName:str mimeType:@"image/jpeg"];
            
//        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"--> %@", responseObject);
       
        success(task,responseObject);
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        failure(task,error);
    }];
    
    

    
//    for (int i=0; i<imageUploadCount; i++) {
//    [photoArr addObject:filePath];
//    NSString * hashString = [FileHash sha256HashOfFileAtPath:filePath];
//    NSString *urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries/",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID,ENTRY_UUID];
////   NSNumber *sizeNumber = [NSNumber numberWithLongLong:[FMUploadFileAPI fileSizeAtPath:filePath]];
//    NSInteger sizeNumber = (NSInteger)[FMUploadFileAPI fileSizeAtPath:filePath];
//    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer]
//                                    multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
////                                        NSMutableDictionary *mutableDic= [NSMutableDictionary dictionary];
////  NSDictionary * dic =
////            @{
////            @"size": sizeNumber,
////            @"sha256": hashString
////        };
////                                        
////        [mutableDic  setValue:dic forKey:@"filename"];
////        NSData *data= [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
////        NSLog(@"😁😁😁😁😁😁%@",mutableDic);
////                                        NSString *josnString = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
////        
////        [formData appendPartWithFormData:data name:@"filename"];
//        NSString * exestr = [filePath lastPathComponent];
////                                         NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
////                                        [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\";", exestr] forKey:@"Content-Disposition"];
////                                         [mutableHeaders setValue:dic forKey:@"Content-Disposition"];
////                                        [mutableHeaders setValue:@"image/jpeg" forKey:@"Content-Type"];
////        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
////                            [formData appendPartWithHeaders:mutableHeaders body:imageData];
////                                       
//                    
//        NSString *str = [NSString stringWithFormat:@"{\"size\":%ld,\"sha256\":\"%@\"}",(long)sizeNumber ,hashString];
//        NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
//                                        [formData appendPartWithFileData:data name:exestr fileName:str mimeType:@"image/jpeg"];
////        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:exestr fileName:str mimeType:@"image/jpeg" error:nil];
//            NSLog(@"😁😁😁😁😁😁%@",str);
////                                        NSLog(@"%@",exestr);
//                                        // 获得文件名（不带后缀）
////                                        exestr = [exestr stringByDeletingPathExtension];
////        [formData appendPartWithFileData:data name:@"iphoto" fileName:@"file" mimeType:@"image/jpeg"];
////        name="foo"; filename="{"size":FILE_SIZE,"sha256":"SHA256_HASH_STRING"
//    } error:nil];
//    
//    [request setValue:[NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    NSURLSessionUploadTask *uploadTask;
//    uploadTask = [manager
//                  uploadTaskWithStreamedRequest:request
//                  progress:^(NSProgress * _Nonnull uploadProgress) {
//                  }
//                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//                      if (error) {
//                          NSLog(@"Error: %@", error);
//                      } else {
//                          NSLog(@"%@ %@", response, responseObject);
//                      }
//                  }];
//    
//    [uploadTask resume];
//  }
}

+(NSString *)JSONString:(NSString *)aString {
    NSMutableString *s = [NSMutableString stringWithString:aString];
    [s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}


+ (long long) fileSizeAtPath:(NSString*) filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}


+ (void)creatPhotoDirEntryCompleteBlock:(void(^)(BOOL successful))completeBlock{
    
    NSString *urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID,DIR_UUID];

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSDictionary *dic= @{@"op": @"mkdir"};
        NSData *data= [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        [formData appendPartWithFormData:data name:@"iphoto"];

    } error:nil];
    
    [request setValue:[NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                  }
              completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                  if (error) {
                      NSLog(@"Error: %@", error);
                  } else {
                      NSLog(@"%@ %@", response, responseObject);
                      NSDictionary * dic = responseObject;
                      NSArray * arr = [dic objectForKey:@"entries"];
                      for (NSDictionary *entriesDic in arr) {
                      EntriesModel *model = [EntriesModel yy_modelWithDictionary:entriesDic];
                      if ([model.name isEqualToString:@"iphoto"] && [model.type isEqualToString:@"directory"]) {
                          [[NSUserDefaults standardUserDefaults] setObject:model.uuid forKey:ENTRY_UUID_STR];
                          [[NSUserDefaults standardUserDefaults] synchronize];
                          completeBlock(YES);
                }
              }
            }
        }];
    [uploadTask resume];
}

+(void)_uploadAddressFile:(NSString *)filePath andFolderUUID:(NSString *)folderUUID  andCompleteBlock:(void(^)(BOOL success))completeBlock{
    NSString * str = [FileHash sha256HashOfFileAtPath:filePath];
    NSString * url = [NSString stringWithFormat:@"%@files/%@",[JYRequestConfig sharedConfig].baseURL,folderUUID];
    NSDictionary * dic = [NSDictionary dictionaryWithObject:str forKey:@"sha256"];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" error:nil];
    } error:nil];
    [request setValue:[NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
    AFURLSessionManager * afManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [afManager uploadTaskWithStreamedRequest:request
                                                 progress:nil
                                        completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                            NSHTTPURLResponse * rep = (NSHTTPURLResponse *)response;
                                            completeBlock(rep.statusCode == 200);
                                        }];
    [uploadTask resume];
}

+ (void)uploadsSiftWithDataSouce:(NSArray *)dataSouce Asset:(PHAsset *)asset LocalPhotoHash:(NSString*)localPhotoHash filePath:(NSString *)filePath SuccessBlock:(void (^)(NSString *url))success Failure:(void (^)())failure CopmleteBlock:(void(^)(BOOL upload))completeBlock  {
    NSMutableArray * mutableArr = [NSMutableArray array];
    for (NSDictionary *entriesDic in dataSouce) {
        EntriesModel *model = [EntriesModel yy_modelWithDictionary:entriesDic];
//        NSLog(@"%@🍄🍄🍄%@",localPhotoHash,model.photoHash);
        if ([localPhotoHash isEqualToString:model.photoHash]) {
            [mutableArr addObject:localPhotoHash];
        }
    }
    NSLog(@"🍄🍄🍄%@",mutableArr);
    if (mutableArr.count == 0) {
        completeBlock(YES);
    }else{
        [[PhotoManager shareManager] uploadComplete:YES andSha256:localPhotoHash withFilePath:filePath andAsset:asset andSuccessBlock:success Failure:failure];
        completeBlock(NO);
    }
}
@end
