//
//  FLDataSource.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/2.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FLDataSource.h"
#import "FLGetDrivesAPI.h"
#import "FLDrivesModel.h"
#import "FLGetFilesAPI.h"
#import "FMUploadFileAPI.h"
#import "EntriesModel.h"
@implementation FLDataSource

-(instancetype)init{
    if (self = [super init]) {
        [self getDataSource];
    }
    return self;
}

- (void)getDataSource{
    _dataSource = [NSMutableArray arrayWithCapacity:0];
    
    //        [self getFilesWithUUID:[FMConfiguation shareConfiguation].userHome];
    NSString *dirUUID = DRIVE_UUID;
    //        NSLog(@"%@",DRIVE_UUID);
    if (dirUUID.length==0) {
        [FMUploadFileAPI getDriveInfoCompleteBlock:^(BOOL successful) {
            if (successful) {
                [FMUploadFileAPI getDirEntryWithUUId:DRIVE_UUID success:^(NSURLSessionDataTask *task, id responseObject) {
                    NSDictionary * dic = responseObject;
                    NSArray * arr = [dic objectForKey:@"entries"];
                    for (NSDictionary *entriesDic in arr) {
                        FLFilesModel * model = [FLFilesModel yy_modelWithJSON:entriesDic];
                        [self.dataSource addObject:model];
                    }
                    NSLog(@"%ld",(long)self.dataSource.count);
                    if (self.delegate && [self.delegate respondsToSelector:@selector(fl_Datasource:finishLoading:)]) {
                        [self.delegate fl_Datasource:self finishLoading:YES];
                    }
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    NSLog(@"%@",error);
                    if (self.delegate && [self.delegate respondsToSelector:@selector(fl_Datasource:finishLoading:)]) {
                        [self.delegate fl_Datasource:self finishLoading:NO];
                    }
                }];
            }else{
                if (self.delegate && [self.delegate respondsToSelector:@selector(fl_Datasource:finishLoading:)]) {
                    [self.delegate fl_Datasource:self finishLoading:NO];
                }
            }
                }];
//            }
//        }];
    }else{
        [FMUploadFileAPI getDirEntryWithUUId:DRIVE_UUID success:^(NSURLSessionDataTask *task, id responseObject) {
            NSLog(@"%@",responseObject);
            NSDictionary * dic = responseObject;
            NSArray * arr = [dic objectForKey:@"entries"];
            for (NSDictionary *entriesDic in arr) {
                FLFilesModel * model = [FLFilesModel yy_modelWithJSON:entriesDic];
                [self.dataSource addObject:model];
            }
            NSLog(@"%ld",(long)self.dataSource.count);
            if (self.delegate && [self.delegate respondsToSelector:@selector(fl_Datasource:finishLoading:)]) {
                [self.delegate fl_Datasource:self finishLoading:YES];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"%@",error);
            if (self.delegate && [self.delegate respondsToSelector:@selector(fl_Datasource:finishLoading:)]) {
                [self.delegate fl_Datasource:self finishLoading:NO];
            }
            NSHTTPURLResponse * rep = (NSHTTPURLResponse *)task.response;
            if (rep.statusCode == 404) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:PHOTO_ENTRY_UUID_STR];
            }
        }];
    }
 
}

-(instancetype)initWithFileUUID:(NSString *)uuid{
    if (self = [super init]) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
        [self getFilesWithUUID:uuid];
    }
    return self;
}

-(void)getFilesWithUUID:(NSString *)uuid{
    [FMUploadFileAPI  getDirEntryWithUUId:(NSString *)uuid success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"%@",responseObject);
        NSDictionary * dic = responseObject;
        NSArray * arr = [dic objectForKey:@"entries"];
        for (NSDictionary *entriesDic in arr) {
            FLFilesModel * model = [FLFilesModel yy_modelWithJSON:entriesDic];
            [self.dataSource addObject:model];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(fl_Datasource:finishLoading:)]) {
            [self.delegate fl_Datasource:self finishLoading:YES];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
        if (self.delegate && [self.delegate respondsToSelector:@selector(fl_Datasource:finishLoading:)]) {
            [self.delegate fl_Datasource:self finishLoading:NO];
        }
    }];

//    [[FLGetFilesAPI apiWithFileUUID:uuid]
//     startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//        NSArray * arr = request.responseJsonObject;
//           NSLog(@"%@",request.responseJsonObject);
//        for (NSDictionary * dic in arr) {
//            FLFilesModel * model = [FLFilesModel yy_modelWithJSON:dic];
//            model.parUUID = uuid;
//            [self.dataSource addObject:model];
//        }
//        if (self.delegate && [self.delegate respondsToSelector:@selector(fl_Datasource:finishLoading:)]) {
//            [self.delegate fl_Datasource:self finishLoading:YES];
//        }
//    } failure:^(__kindof JYBaseRequest *request) {
//        NSLog(@"%@",request.error);
//        if (self.delegate && [self.delegate respondsToSelector:@selector(fl_Datasource:finishLoading:)]) {
//            [self.delegate fl_Datasource:self finishLoading:NO];
//        }
//    }];
}



@end
