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
