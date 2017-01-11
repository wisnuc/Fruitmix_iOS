//
//  FMAlbumDataSource.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/23.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMAlbumDataSource.h"
#import "FMMediaShareDataSource.h"
#import "FMStatusLayout.h"

@implementation FMAlbumDataSource

-(instancetype)init{
    if (self = [super init]) {
        _dataSource = [NSMutableArray new];
        [self _getAlbumDataWithShares:[FMMediaShareDataSource sharedDataSource].dataSource];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_getAlbumDataWithNotify:) name:FM_SHARE_UPDATE_NOTIFY object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)_getAlbumDataWithNotify:(NSNotification *)notify{
    NSMutableArray * arr = notify.object;
    [self _getAlbumDataWithShares:arr];
}

-(void)_getAlbumDataWithShares:(NSMutableArray *)arr{
    if (arr.count) {
        NSMutableArray * tempAlbums = [NSMutableArray arrayWithCapacity:0];
        for (FMStatusLayout * layout in arr) {
            if ([layout.status.isAlbum boolValue]) {
                [tempAlbums addObject:layout.status];
            }
        }
        self.dataSource = tempAlbums;
        [self.delegate albumDataSourceDidChange];//通知代理
    }
}

-(void)sortDataSource{
    NSArray *array2 = [self.dataSource sortedArrayUsingComparator:
                       ^NSComparisonResult(id<FMMediaShareProtocol> obj1, id<FMMediaShareProtocol>obj2) {
                           NSComparisonResult result = NSOrderedDescending;
                           if ([obj1 getTime]>[obj2 getTime]) {
                               result = NSOrderedAscending;
                           }
                           return result;
                       }];
    self.dataSource = [NSMutableArray arrayWithArray:array2];
}

+(void)updateAlbum:(id<FMMediaShareProtocol>)album andComPleteBlock:(void(^)(BOOL success,BOOL isShare))block{

    //TODO localCache Share
    
    NSMutableArray * viewers = [NSMutableArray arrayWithArray:album.viewers];
    NSString * op = @"delete";
    if(album.viewers.count == 0){
        [viewers addObjectsFromArray: [FMDBControl getAllUsersUUID]];
        op = @"add";
    }
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:op forKey:@"op"];
    [dic setObject:@"viewers" forKey:@"path"];
    [dic setObject:viewers forKey:@"value"];
    
    NSArray * tempArr = [NSArray arrayWithObject:dic];
    [[FMUpdateSharesAPI apiWithShareId:album.uuid andParam:tempArr]
     startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        [MyAppDelegate.mediaDataSource refreshData];
        block(YES,IsEquallString(op, @"add"));
        NSLog(@"%@",request.responseJsonObject);
    } failure:^(__kindof JYBaseRequest *request) {
        block(NO, IsEquallString(op, @"add"));
        NSLog(@"%@",request.error);
    }];
}

+(void)updateAlbum:(id<FMMediaShareProtocol>)album andAlbum:(NSDictionary *)albumDic andIsPublic:(BOOL)isPublic andCanAdd:(BOOL)canAdd andComPleteBlock:(void (^)(BOOL success))block{
    
    NSMutableArray * ops = [NSMutableArray arrayWithCapacity:0];
    NSMutableSet * viewers = [NSMutableSet setWithArray:album.viewers];
    NSString * op = @"delete";
    if(isPublic || canAdd){
        [viewers addObjectsFromArray: [FMDBControl getAllUsersUUID]];
        op = @"add";
    }
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setObject:op forKey:@"op"];
    [dic setObject:@"viewers" forKey:@"path"];
    [dic setObject:[viewers allObjects] forKey:@"value"];
    [ops addObject:dic];
    
    NSMutableDictionary * albumChange = [NSMutableDictionary dictionaryWithCapacity:0];
    [albumChange setObject:@"replace" forKey:@"op"];
    [albumChange setObject:@"album" forKey:@"path"];
    [albumChange setObject:albumDic forKey:@"value"];
    [ops addObject:albumChange];
    
    
    [[FMUpdateSharesAPI apiWithShareId:album.uuid andParam:ops]
     startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
         [MyAppDelegate.mediaDataSource refreshData];
         block(YES);
         NSLog(@"%@",request.responseJsonObject);
     } failure:^(__kindof JYBaseRequest *request) {
         block(NO);
         NSLog(@"%@",request.error);
     }];
}

+(void)deleteAlbum:(id<FMMediaShareProtocol>)album andComPleteBlock:(void(^)(BOOL success))block{
    
    //TODO localCache Delete
    [[FMDeleteShareAPI apiWithDeleteShareId:album.uuid]
     startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
         [MyAppDelegate.mediaDataSource refreshData];
         NSLog(@"删除成功:%@",request.responseJsonObject);
        block(YES);
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"删除失败：%@",request.error);
        block(NO);
    }];
}

+(void)editContentsAlbum:(id<FMMediaShareProtocol>)album adds:(NSArray *)adds removes:(NSArray *)removes andComPleteBlock:(void(^)(BOOL success))block{
    
    if (!adds.count && !removes.count) {
        block(YES);
        return;
    }
    
    NSMutableArray * editArr = [NSMutableArray arrayWithCapacity:0];
    //创建 add 任务
    if(adds.count){
        NSMutableDictionary *addDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [addDic setObject:@"add" forKey:@"op"];
        [addDic setObject:@"contents" forKey:@"path"];
        [addDic setObject:adds forKey:@"value"];
        [editArr addObject:addDic];
    }
    
    if (removes.count) {
        //创建remove 任务
        NSMutableDictionary *removeDic = [NSMutableDictionary dictionaryWithCapacity:0];
        [removeDic setObject:@"delete" forKey:@"op"];
        [removeDic setObject:@"contents" forKey:@"path"];
        [removeDic setObject:removes forKey:@"value"];
        [editArr addObject:removeDic];
    }
    
    [[FMUpdateSharesAPI apiWithShareId:album.uuid andParam:editArr]
     startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
         NSLog(@"%@",request.responseJsonObject);
         block(YES);
     } failure:^(__kindof JYBaseRequest *request) {
         NSLog(@"%@",request.error);
         block(NO);
     }];
}

+(void)createAlbumWithMaintainers:(NSArray *)maintainers Viewers:(NSArray *)viewers Contents:(NSArray *)contents IsAlbum:(NSDictionary *)album andComPleteBlock:(void(^)(BOOL success))block{
    [[FMCreateShareAPI shareCreateWithMaintainers:maintainers Viewers:viewers Contents:contents IsAlbum:album] startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSLog(@"创建相册成功%@",request.responseJsonObject);
        block(YES);
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"创建相册失败：%@",request.error);
        block(NO);
    }];
}
@end
