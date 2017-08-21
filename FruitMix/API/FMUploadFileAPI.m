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

+ (void)getDriveInfoCompleteBlock:(void(^)(BOOL success))completeBlock{
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

+ (void)getDirectoriesCompleteBlock:(void(^)(BOOL success))completeBlock{
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
            [[NSUserDefaults standardUserDefaults] setObject:model.uuid forKey:DIR_UUID_STR];
            [[NSUserDefaults standardUserDefaults] synchronize];
                 completeBlock(YES);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];

}
//+ (void)getDirUploadDirEntryWithFilePath:(NSString *)filePath{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    NSString *urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID,DIR_UUID];
//    [manager.requestSerializer setValue: [NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
//    [manager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//          NSLog(@"%@",responseObject);
//          [FMUploadFileAPI getDirEntry];
//
//          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%@",error);
//    }];
//
//}

+ (void)uploadDirEntryWithFilePath:(NSString *)filePath  completionHandler:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler {
    imageUploadCount++;
    NSMutableArray *photoArr = [NSMutableArray array];
    for (int i=0; i<imageUploadCount; i++) {
    [photoArr addObject:filePath];
    NSString * hashString = [FileHash sha256HashOfFileAtPath:filePath];
    NSString *urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries/",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID,ENTRY_UUID];
//   NSNumber *sizeNumber = [NSNumber numberWithLongLong:[FMUploadFileAPI fileSizeAtPath:filePath]];
    NSInteger sizeNumber = (NSInteger)[FMUploadFileAPI fileSizeAtPath:filePath];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer]
                                    multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
//                                        NSMutableDictionary *mutableDic= [NSMutableDictionary dictionary];
//  NSDictionary * dic =
//            @{
//            @"size": sizeNumber,
//            @"sha256": hashString
//        };
//                                        
//        [mutableDic  setValue:dic forKey:@"filename"];
//        NSData *data= [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
//        NSLog(@"😁😁😁😁😁😁%@",mutableDic);
//                                        NSString *josnString = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
//        
//        [formData appendPartWithFormData:data name:@"filename"];
        NSString * exestr = [filePath lastPathComponent];
//                                         NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
//                                        [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\";", exestr] forKey:@"Content-Disposition"];
//                                         [mutableHeaders setValue:dic forKey:@"Content-Disposition"];
//                                        [mutableHeaders setValue:@"image/jpeg" forKey:@"Content-Type"];
//        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
//                            [formData appendPartWithHeaders:mutableHeaders body:imageData];
//                                       
                    
        NSString *str = [NSString stringWithFormat:@"{\"size\":%ld,\"sha256\":\"%@\"}",(long)sizeNumber ,hashString];

        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:exestr fileName:str mimeType:@"image/jpeg" error:nil];
            NSLog(@"😁😁😁😁😁😁%@",str);
//                                        NSLog(@"%@",exestr);
                                        // 获得文件名（不带后缀）
//                                        exestr = [exestr stringByDeletingPathExtension];
//        [formData appendPartWithFileData:data name:@"iphoto" fileName:@"file" mimeType:@"image/jpeg"];
//        name="foo"; filename="{"size":FILE_SIZE,"sha256":"SHA256_HASH_STRING"
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
                      }
                  }];
    
    [uploadTask resume];
  }
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


+ (void)getDirEntryCompleteBlock:(void(^)(BOOL success))completeBlock{
    
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

@end
