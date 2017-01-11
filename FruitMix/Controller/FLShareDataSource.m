//
//  FLShareDataSource.m
//  FruitMix
//
//  Created by 杨勇 on 16/10/9.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FLShareDataSource.h"
#import "FLGetSharedWithMeAPI.h"
#import "FLShareModel.h"

@implementation FLShareDataSource

-(instancetype)init{
    if (self = [super init]) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
        [self getShares];
    }
    return self;
}

-(void)getShares{
    NSLog(@"获取分享的文件");
    [[FLGetSharedWithMeAPI new] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSLog(@"获取成功%@",request.responseJsonObject);
        for (NSDictionary * dic in request.responseJsonObject) {
            FLShareModel * model = [FLShareModel yy_modelWithJSON:dic];
            [self.dataSource addObject:model];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(shareDataSourceLoadingComplete:)])
            [self.delegate shareDataSourceLoadingComplete:YES];
        
    } failure:^(__kindof JYBaseRequest *request) {
         if (self.delegate && [self.delegate respondsToSelector:@selector(shareDataSourceLoadingComplete:)])
             [self.delegate shareDataSourceLoadingComplete:NO];
    }];
}

@end
