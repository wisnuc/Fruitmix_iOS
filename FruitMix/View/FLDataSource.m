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

@implementation FLDataSource

-(instancetype)init{
    if (self = [super init]) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
        [self getFilesWithUUID:[FMConfiguation shareConfiguation].userHome];
    }
    return self;
}

-(instancetype)initWithFileUUID:(NSString *)uuid{
    if (self = [super init]) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
        [self getFilesWithUUID:uuid];
    }
    return self;
}

-(void)getFilesWithUUID:(NSString *)uuid{
    [[FLGetFilesAPI apiWithFileUUID:uuid]
     startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSArray * arr = request.responseJsonObject;
        for (NSDictionary * dic in arr) {
            FLFilesModel * model = [FLFilesModel yy_modelWithJSON:dic];
            [self.dataSource addObject:model];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(fl_Datasource:finishLoading:)]) {
            [self.delegate fl_Datasource:self finishLoading:YES];
        }
    } failure:^(__kindof JYBaseRequest *request) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(fl_Datasource:finishLoading:)]) {
            [self.delegate fl_Datasource:self finishLoading:NO];
        }
    }];
}



@end
