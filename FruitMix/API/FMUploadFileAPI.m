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

@implementation FMUploadFileAPI

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

+ (void)getDriveInfo{
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
            }
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
    
  }

+ (void)getDirectories{
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
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];

}
+ (void)getDir{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID,DIR_UUID];
    [manager.requestSerializer setValue: [NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
    [manager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary * dic = responseObject;
        NSArray * arr = [dic objectForKey:@"entries"];
        for (NSString *name in arr) {
            if ([name isEqualToString:@"iphoto"]) {
                [self getDirEntry];
            }else{
                
            }
        }
        
//        NSLog(@"%@",responseObject);
        
//        for (NSDictionary *dic in responseArr) {
//            @autoreleasepool {
//                DirectoriesModel *model = [DirectoriesModel yy_modelWithJSON:dic];
//                NSLog(@"%@",model.uuid);
//                [[NSUserDefaults standardUserDefaults] setObject:model.uuid forKey:DIR_UUID_STR];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//            }
//        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];

}

+ (void)uploadDirEntry{
    
    NSString *urlString = [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID,DIR_UUID];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSDictionary *dic= @{
            @"size": @1234,
            @"sha256": @"SHA256_HASH_STRING",
            @"overwrite":@"TARGET_FILE_UUID"
        };
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
                      }
                  }];
    
    [uploadTask resume];
    
    //    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //        [manager.requestSerializer setValue: [NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
    ////    NSDictionary
    //    NSDictionary * dic = @{@"iphoto":
    //                           @{@"op": @"mkdir"
    //                           }
    //                        };
    //    [manager POST:urlString parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
    //
    //    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    //        NSArray * responseArr = responseObject;
    //        NSLog(@"%@",responseObject);
    //        for (NSDictionary *dic in responseArr) {
    //            @autoreleasepool {
    ////                DirectoriesModel *model = [DirectoriesModel yy_modelWithJSON:dic];
    ////                NSLog(@"%@",model.uuid);
    ////                [[NSUserDefaults standardUserDefaults] setObject:model.uuid forKey:DIR_UUID_STR];
    ////                [[NSUserDefaults standardUserDefaults] synchronize];
    //            }
    //        }
    //    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    //        NSLog(@"%@",error);
    //    }];
}

+ (void)getDirEntry{
    
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
                      }
                  }];
    
    [uploadTask resume];
    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//        [manager.requestSerializer setValue: [NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
////    NSDictionary
//    NSDictionary * dic = @{@"iphoto":
//                           @{@"op": @"mkdir"
//                           }
//                        };
//    [manager POST:urlString parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSArray * responseArr = responseObject;
//        NSLog(@"%@",responseObject);
//        for (NSDictionary *dic in responseArr) {
//            @autoreleasepool {
////                DirectoriesModel *model = [DirectoriesModel yy_modelWithJSON:dic];
////                NSLog(@"%@",model.uuid);
////                [[NSUserDefaults standardUserDefaults] setObject:model.uuid forKey:DIR_UUID_STR];
////                [[NSUserDefaults standardUserDefaults] synchronize];
//            }
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%@",error);
//    }];
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
