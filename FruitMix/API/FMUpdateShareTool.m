//
//  FMUpdateShareTool.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/21.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMUpdateShareTool.h"

@implementation FMUpdateShareTool

{
    NSTimer * _updateTimer;
}

+(instancetype)shareInstance{
    static id tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [FMUpdateShareTool new];
    });
    return tool;
}

-(instancetype)init{
    if (self = [super init]) {
//        _updateTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateMediaShareTimer) userInfo:nil repeats:YES];
//        [[NSRunLoop currentRunLoop] addTimer:_updateTimer forMode:NSRunLoopCommonModes];
    }
    return self;
}

+(void)getMediaShares:(GetShareCompleteBlock)block{
    FMGetShareAPI * api = [FMGetShareAPI new];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary * dic in request.responseJsonObject) {
            FMMediaShare  * photo = [FMMediaShare yy_modelWithJSON:dic];
            [arr addObject:photo];
        }
        block(arr);
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"GET_Share_Error : %@",request.error);
        block([NSMutableArray new]);
    }];
}

+(void)updateMediaSharesWithCompleteBlock:(void(^)(BOOL shouldUpdate))block{
    
}

//
//-(void)updateMediaShareTimer{
//    if (MyAppDelegate.isBackground) {
//        return;
//    }
//    [FMUpdateDocumentTool updateMediaSharesWithCompleteBlock:^(BOOL shouldUpdate) {
//        if (shouldUpdate) {
//            [[NSNotificationCenter defaultCenter]postNotificationName:FM_NEED_UPDATE_UI_NOTIFY object:nil];
//        }
//    }];
//}
//
//-(void)dealloc{
//    [_updateTimer invalidate];
//    _updateTimer = nil;
//}
//
//
//+(void)mediaShareNeedUpdate{
//    [self updateMediaSharesWithCompleteBlock:^(BOOL shouldUpdate) {
//        
//    }];
//}



//+(void)updateMediaSharesWithCompleteBlock:(void(^)(BOOL shouldUpdate))block{
    //    static int64_t lastRequestMTime = 0;
    //    NSLog(@"%lld",lastRequestMTime);
    //    NSTimeInterval tempTime  =[[NSDate date] timeIntervalSince1970];     //NSTimeInterval返回的是double类型
    //    if(lastRequestMTime >= tempTime - 3){
    //        NSLog(@"请求过于频繁");
    //        return;
    //    }
    //    //更新上次请求时间
    //    lastRequestMTime = tempTime;
//    [self _doUpdeShareWithBlock:block andIsDel:NO];
    //    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //        FMGetShareKeyAPI * keyAPI = [FMGetShareKeyAPI new];
    //        [keyAPI startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
    //            NSMutableArray * uuidArr = [NSMutableArray arrayWithCapacity:0];
    //            for (NSDictionary * dic in request.responseJsonObject) {
    //                [uuidArr addObject:dic[@"uuid"]];
    //            }
    //            FMDBSet * dbSet = [FMDBSet shared];
    //            FMDTSelectCommand * scmd = FMDT_SELECT(dbSet.mediashare);
    //            [scmd where:@"uuid" notContainedIn:uuidArr];
    //            NSArray * needDelArr = [scmd fetchArray];
    //            NSMutableArray * needDelUUIDArr = [NSMutableArray arrayWithCapacity:0];
    //            for (FMMediaShare * share in needDelArr) {
    //                [needDelUUIDArr addObject:share.uuid];
    //            }
    //            if (needDelUUIDArr.count>0) {
    //                FMDTDeleteCommand * dcmd = FMDT_DELETE(dbSet.mediashare);
    //                [dcmd where:@"uuid" containedIn:needDelUUIDArr];
    //                [dcmd saveChanges];
    //                if(block){
    //                    [[NSNotificationCenter defaultCenter]postNotificationName:FM_NEED_UPDATE_UI_NOTIFY object:nil];
    //                    block(YES);
    //                }
    //            }
    //        } failure:^(__kindof JYBaseRequest *request) {
    //            NSLog(@"更新mediashareKey失败:【FMUpdateDocumentTool】");
    //            if(block)
    //                block(NO);
    //        }];
    //    });
//}

//+(void)_doUpdeShareWithBlock:(void(^)(BOOL shouldUpdate))block andIsDel:(BOOL)isDel{

//    FMGetShareAPI * api = [FMGetShareAPI new];
    //    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
    //        NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
    //        for (NSDictionary * dic in request.responseJsonObject) {
    //            FMMediaShare  * photo = [FMMediaShare yy_modelWithJSON:dic];
    //            [arr addObject:photo];
    //        }
    //    } failure:^(__kindof JYBaseRequest *request) {
    //
    //    }];
    
    
    //    JYBaseRequest * api = [FMGetShareAPI new];
    //    if (LAST_REQUEST_TIME) {
    //        api = [FMGetAfterShareAPI new];
    //        [(FMGetAfterShareAPI *)api setAfterCTime:[LAST_REQUEST_TIME longLongValue]];
    //    }
//    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        //        NSTimeInterval time=[[NSDate date] timeIntervalSince1970]*1000;
        //        double i=time;      //NSTimeInterval返回的是double类型
//        NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
//        for (NSDictionary * dic in request.responseJsonObject) {
//            FMMediaShare  * photo = [FMMediaShare yy_modelWithJSON:dic];
//            [arr addObject:photo];
//        }
        //        if (arr.count>0) {
        //            i = [(FMMediaShare *)arr[0] mtime];
        //            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lld",(long long)i-100] forKey:LAST_REQUEST_TIME_STR];
        //            [[NSUserDefaults standardUserDefaults] synchronize];
        //        }
        
//        [[FMDBSet shared] asynMediaShareWithArray:arr andCompleteBlock:^(NSArray *insertArr, NSArray *updateArr) {
//            NSLog(@"插入 %ld条数据，更新 %ld条数据",(unsigned long)insertArr.count,(unsigned long)updateArr.count);
//            if (block) {
//                NSInteger i = insertArr.count+updateArr.count;
//                if (i>0 || isDel) {
//                    [[NSNotificationCenter defaultCenter]postNotificationName:FM_NEED_UPDATE_UI_NOTIFY object:nil];
//                    block(YES);
//                }else
//                    block(NO);
//            }
//        }];
//    } failure:^(__kindof JYBaseRequest *request) {
//        NSLog(@"更新mediaShare失败:【FMUpdateDocumentTool】");
//        if (block) {
//            block(NO);
//        }
//    }];
//}

//+(void)asycMediaPhotos{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        FMMediaAPI * api = [FMMediaAPI new];
//        [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//            //            NSLog(@"%@",request.responseJsonObject);
//            [self analysisPhotos:request.responseJsonObject];
//        } failure:^(__kindof JYBaseRequest *request) {
//            NSLog(@"失败:%@",request.error);
//        }];
//    });
//}
//
//+(void)analysisPhotos:(id)response{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSArray * userArr = response;
//        NSMutableArray * photoArr = [NSMutableArray arrayWithCapacity:0];
//        for (NSDictionary * dic in userArr) {
//            
//            FMNASPhoto * nasPhoto = [FMNASPhoto yy_modelWithJSON:dic];
//            
//            [photoArr addObject:nasPhoto];
//        }
//        //Cache 到数据库
//        [[FMDBSet shared] asynNASPhoto:photoArr andCompleteBlock:^{
//            NSLog(@"同步 nasPhoto 数据完成");
//        }];
//    });
//}


@end
