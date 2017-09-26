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
#import "FLGetDrivesAPI.h"
#import "FLGetDirveEntryAPI.h"
#import "FLFilesModel.h"
#import "DriveModel.h"
#import "DirectoriesModel.h"
#import "EntriesModel.h"
#import "PhotoManager.h"
#import "FLUploadFilesAPI.h"
#import <sys/utsname.h>

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
    FLGetDrivesAPI * api = [[FLGetDrivesAPI alloc]init];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSArray * responseArr = request.responseJsonObject;
        NSLog(@"%@",responseObject);
        for (NSDictionary *dic in responseArr) {
            @autoreleasepool {
                DriveModel *model = [DriveModel yy_modelWithJSON:dic];
                NSLog(@"%@",model.uuid);
                if ([model.tag isEqualToString:@"home"]) {
                    [[NSUserDefaults standardUserDefaults] setObject:model.uuid forKey:DRIVE_UUID_STR];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    completeBlock(YES);
                }
            }
        }
    } failure:^(__kindof JYBaseRequest *request) {
        completeBlock(NO);
        NSHTTPURLResponse * rep = (NSHTTPURLResponse *)request.dataTask.response;
        if (rep.statusCode == 404) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:PHOTO_ENTRY_UUID_STR];
        }
    }];
}
//+ (void)getDirectoriesForFilesCompleteBlock:(void(^)(BOOL successful))completeBlock{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    NSString *urlString = [NSString stringWithFormat:@"%@drives/%@/dirs",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID];
//    [manager.requestSerializer setValue: [NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
//    [manager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSArray * responseArr = responseObject;
//        NSLog(@"🍄🍄🍄🍄%@",responseObject);
//        for (NSDictionary *dic in responseArr) {
//            @autoreleasepool {
//                DirectoriesModel *model = [DirectoriesModel yy_modelWithJSON:dic];
//                NSLog(@"😆😆%@,%@",model.uuid,DEF_UUID);
//                if ([model.tag isEqualToString:@"home"]) {
//                    [[NSUserDefaults standardUserDefaults] setObject:model.uuid forKey:DIR_UUID_STR];
//                    [[NSUserDefaults standardUserDefaults] synchronize];
//                    completeBlock(YES);
//                }
//            }
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%@",error);
//
//    }];
//}

+ (void)getDirectoriesForPhotoCompleteBlock:(void(^)(BOOL successful))completeBlock{
    [FMUploadFileAPI getDirEntryWithUUId:DRIVE_UUID success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary * dic = responseObject;
        NSArray * arr = [dic objectForKey:@"entries"];
        NSLog(@"🍄%@",arr);
        if (arr.count>0) {
            for (NSDictionary *entriesDic in arr) {
                EntriesModel *model = [EntriesModel yy_modelWithDictionary:entriesDic];
                if ([model.name isEqualToString:@"上传的照片"] && [model.type isEqualToString:@"directory"]) {
                    [[NSUserDefaults standardUserDefaults] setObject:model.uuid forKey:ENTRY_UUID_STR];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    completeBlock(YES);
                }else{
                    [FMUploadFileAPI creatPhotoMainFatherDirEntryCompleteBlock:^(BOOL successful) {
                        if (successful) {
                            completeBlock(YES);
                        }
                    }];
                }
            }
        }else{
            [FMUploadFileAPI creatPhotoMainFatherDirEntryCompleteBlock:^(BOOL successful) {
                if (successful) {
                    completeBlock(YES);
                }
            }];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];
}

+ (void)getDirEntrySuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 20;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    NSString *urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID,DRIVE_UUID];
    [manager.requestSerializer setValue: [NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
    [manager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          NSLog(@"%@",responseObject);
    
        success(task,responseObject);
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
              NSHTTPURLResponse * rep = (NSHTTPURLResponse *)task.response;
              if (rep.statusCode == 404) {
                  [[NSUserDefaults standardUserDefaults] removeObjectForKey:PHOTO_ENTRY_UUID_STR];
              }
//              failure(task,error);
    }];

}

+ (void)getDirEntryWithUUId:(NSString *)uuid
                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure{
    [[FLGetDirveEntryAPI apiWithUUID:uuid] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        success(request.dataTask,request.responseJsonObject);
    } failure:^(__kindof JYBaseRequest *request) {
         failure(request.dataTask,request.error);
    }];
}

//(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject
+ (void)uploadDirEntryWithFilePath:(NSString *)filePath
                           success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure otherFailure:(void (^)(NSString *null))otherFailure{
    MyNSLog(@"==========================开始上传==============================");
    NSString * hashString = [FileHash sha256HashOfFileAtPath:filePath];
    NSInteger sizeNumber = (NSInteger)[FMUploadFileAPI fileSizeAtPath:filePath];
    NSString * exestr = [filePath lastPathComponent];
//    MyNSLog (@"上传照片POST请求：URL======>%@\n上传照片照片名======>%@\n Hash======>%@\n",urlString,exestr,hashString);
    [[FLUploadFilesAPI apiWithPhotoUUID:PHOTO_ENTRY_UUID]startWithFromDataBlock:^(id<AFMultipartFormData> formData) {
        NSString *str = [NSString stringWithFormat:@"{\"size\":%ld,\"sha256\":\"%@\"}",(long)sizeNumber ,hashString];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
        if (data.length>0) {
            [formData appendPartWithFileData:data name:exestr fileName:str mimeType:@"image/jpeg"];
        }else{
            otherFailure(@"null");
        }
    } uploadProgressBlock:^(NSProgress *progress) {
        
    } CompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        MyNSLog(@"上传请求成功,POST返回成功");
        success(request.dataTask,request.responseJsonObject);
    } failure:^(__kindof JYBaseRequest *request) {
        NSData *errorData = request.error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        if(errorData.length >0){
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            NSLog(@"error--%@",serializedData);
            MyNSLog (@"上传照片error======>%@",serializedData);
        }
//        MyNSLog (@"上传照片error======>%@",request.error);
    }];
    
    
    
    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
//    NSString * hashString = [FileHash sha256HashOfFileAtPath:filePath];
//    NSString *urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries/",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID,PHOTO_ENTRY_UUID];
//   NSInteger sizeNumber = (NSInteger)[FMUploadFileAPI fileSizeAtPath:filePath];
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
//    NSString * exestr = [filePath lastPathComponent];
//    MyNSLog (@"上传照片POST请求：URL======>%@\n上传照片照片名======>%@\n Hash======>%@\n",urlString,exestr,hashString);
//    [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        // 上传 多张图片
////        for(NSInteger i = 0; i < photoArr.count; i++)
////        {
//            NSString *str = [NSString stringWithFormat:@"{\"size\":%ld,\"sha256\":\"%@\"}",(long)sizeNumber ,hashString];
//            NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
//        if (data.length>0) {
//           [formData appendPartWithFileData:data name:exestr fileName:str mimeType:@"image/jpeg"];
//        }else{
//            otherFailure(@"null");
//        }
//    } progress:^(NSProgress * _Nonnull uploadProgress) {
//
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        MyNSLog(@"上传请求成功,POST返回成功");
//        success(task,responseObject);
//
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
////        NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
//        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
//        if(errorData.length >0){
//            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
//            NSLog(@"error--%@",serializedData);
//            MyNSLog (@"上传照片error======>%@",serializedData);
//        }
//          MyNSLog (@"上传照片error======>%@",error);
////       NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//
//        failure(task,error);
//    }];
    
    
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


+ (void)creatPhotoMainFatherDirEntryCompleteBlock:(void(^)(BOOL successful))completeBlock{
//    [FLCreateFolderAPI apiWithParentUUID:DRIVE_UUID andFolderName:@"上传的照片"];
    NSString *urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID,DRIVE_UUID];

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSDictionary *dic= @{@"op": @"mkdir"};
        NSData *data= [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        [formData appendPartWithFormData:data name:@"上传的照片"];
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
                          if ([model.name isEqualToString:@"上传的照片"] && [model.type isEqualToString:@"directory"]) {
                          [[NSUserDefaults standardUserDefaults] setObject:model.uuid forKey:ENTRY_UUID_STR];
                          [[NSUserDefaults standardUserDefaults] synchronize];
                          completeBlock(YES);
                }
              }
            }
        }];
    [uploadTask resume];
}


+ (void)creatPhotoDirEntryCompleteBlock:(void(^)(BOOL successful))completeBlock{
    NSString *photoDirName = [NSString stringWithFormat:@"来自%@",[FMUploadFileAPI getDeviceName]];
    [FMUploadFileAPI getDirEntryWithUUId:ENTRY_UUID success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary * dic = responseObject;
        NSArray * arr = [dic objectForKey:@"entries"];
        if (arr.count >0) {
            for (NSDictionary *entriesDic in arr) {
                EntriesModel *model = [EntriesModel yy_modelWithDictionary:entriesDic];
                if ([model.name isEqualToString:photoDirName] && [model.type isEqualToString:@"directory"]) {
                    [[NSUserDefaults standardUserDefaults] setObject:model.uuid forKey:PHOTO_ENTRY_UUID_STR];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    completeBlock(YES);
                }else{
                    NSString *urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID,ENTRY_UUID];
                    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
                    [manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
                    [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                        NSDictionary *dic= @{@"op": @"mkdir"};
                        NSData *data= [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
                        [formData appendPartWithFormData:data name:photoDirName];
                    } progress:^(NSProgress * _Nonnull uploadProgress) {
                        
                    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                        NSLog(@"--> %@", responseObject);
                        NSDictionary * dic = responseObject;
                        NSArray * arr = [dic objectForKey:@"entries"];
                        for (NSDictionary *entriesDic in arr) {
                            EntriesModel *model = [EntriesModel yy_modelWithDictionary:entriesDic];
                            if ([model.name isEqualToString:photoDirName] && [model.type isEqualToString:@"directory"]) {
                                [[NSUserDefaults standardUserDefaults] setObject:model.uuid forKey:PHOTO_ENTRY_UUID_STR];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                completeBlock(YES);
                            }
                        }
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        NSLog(@"%@", error);
                        //        failure(task,error);
                    }];
                }
            }
        }else{
            NSString *urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID,ENTRY_UUID];
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
            [manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
            [manager POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                
                NSDictionary *dic= @{@"op": @"mkdir"};
                NSData *data= [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
                [formData appendPartWithFormData:data name:photoDirName];
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                NSLog(@"--> %@", responseObject);
                NSDictionary * dic = responseObject;
                NSArray * arr = [dic objectForKey:@"entries"];
                for (NSDictionary *entriesDic in arr) {
                    EntriesModel *model = [EntriesModel yy_modelWithDictionary:entriesDic];
                    if ([model.name isEqualToString:photoDirName] && [model.type isEqualToString:@"directory"]) {
                        [[NSUserDefaults standardUserDefaults] setObject:model.uuid forKey:PHOTO_ENTRY_UUID_STR];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        completeBlock(YES);
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"%@", error);
                //        failure(task,error);
            }];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
          NSLog(@"%@", error);
    }];
    

//    NSString *urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID,DRIVE_UUID];
//    
//    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        NSDictionary *dic= @{@"op": @"mkdir"};
//        NSData *data= [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
//        [formData appendPartWithFormData:data name:@"上传的照片"];
//        
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
//                          NSDictionary * dic = responseObject;
//                          NSArray * arr = [dic objectForKey:@"entries"];
//                          for (NSDictionary *entriesDic in arr) {
//                              EntriesModel *model = [EntriesModel yy_modelWithDictionary:entriesDic];
//                              if ([model.name isEqualToString:@"iphoto"] && [model.type isEqualToString:@"directory"]) {
//                                  [[NSUserDefaults standardUserDefaults] setObject:model.uuid forKey:ENTRY_UUID_STR];
//                                  [[NSUserDefaults standardUserDefaults] synchronize];
//                                  completeBlock(YES);
//                              }
//                          }
//                      }
//                  }];
//    [uploadTask resume];
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
//        NSLog(@"🍄🍄🍄%@",model.photoHash);
        if ([localPhotoHash isEqualToString:model.photoHash]) {
            [mutableArr addObject:localPhotoHash];
        }
    }
//    NSLog(@"🍄🍄🍄%@",mutableArr);
    if (mutableArr.count == 0) {
        completeBlock(YES);
    }else{
        [[PhotoManager shareManager] uploadComplete:NO andSha256:localPhotoHash withFilePath:filePath andAsset:asset andSuccessBlock:success Failure:failure];
        completeBlock(NO);
    }
}
+ (void)getPhotoUUIDWithBlock:(void(^)(BOOL successful))completeBlock{
    [FMUploadFileAPI getDriveInfoCompleteBlock:^(BOOL successful) {
    if (successful) {
    [FMUploadFileAPI getDirectoriesForPhotoCompleteBlock:^(BOOL successful) {
        if (successful) {
            [FMUploadFileAPI creatPhotoDirEntryCompleteBlock:^(BOOL successful) {
                if (successful) {
                    completeBlock(YES);
                }
            }];
        }
    }];
    }
}];

}

+ (NSString *)getDeviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,3"])    return @"iPhone SE";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7Plus";
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([deviceString isEqualToString:@"iPod7,1"])      return @"iPod Touch 6G";
    
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceString;
}
@end
