//
//  FMDBControl.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/21.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMDBControl.h"
#import "FMMediaShareTask.h"
#import "FMFileManager.h"
#import "FMAccountUsersAPI.h"
@interface FMLocalPhotoStore ()
@property (nonatomic ,strong ,readwrite) NSMutableDictionary * localPhotoDic;
@property (nonatomic ,strong ,readwrite) NSMutableDictionary * hashToLocalIdMap;
@property (nonatomic ,strong ,readwrite) NSMutableDictionary * localIdToHashMap;
@end

@implementation FMLocalPhotoStore

+(instancetype)shareStore{
    static FMLocalPhotoStore * localStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        localStore = [[FMLocalPhotoStore alloc]init];
        
    });
    return localStore;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        FMDTSelectCommand * cmd = FMDT_SELECT([FMDBSet shared].photo);
        [cmd whereIsNotNull:@"degist"];
        NSArray * hashsPhoto = [cmd fetchArray];
        @weaky(self);
        [hashsPhoto enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [weak_self.hashToLocalIdMap setObject:((FMLocalPhoto *)obj).localIdentifier forKey:((FMLocalPhoto *)obj).degist];
            [weak_self.localIdToHashMap setObject:((FMLocalPhoto *)obj).degist forKey:((FMLocalPhoto *)obj).localIdentifier];
        }];
    }
    return self;
}

-(NSMutableDictionary *)localPhotoDic{
    if (!_localPhotoDic) {
        _localPhotoDic = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _localPhotoDic;
}

-(NSMutableDictionary *)localIdToHashMap{
    if (!_localIdToHashMap) {
        _localIdToHashMap = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _localIdToHashMap;
}

-(NSMutableDictionary *)hashToLocalIdMap{
    if (!_hashToLocalIdMap) {
        _hashToLocalIdMap = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _hashToLocalIdMap;
}

-(void)addAssetToStore:(PHAsset *)asset{
    if (asset)
        [self.localPhotoDic setObject:asset forKey:asset.localIdentifier];
}

-(void)addDigestToStore:(NSString *)digest andLocalId:(NSString *)localId{
    if (digest && localId){
        [self.hashToLocalIdMap setObject:localId forKey:digest];
        [self.localIdToHashMap setObject:digest forKey:localId];
    }
}



-(NSString *)getPhotoHashWithLocalId:(NSString *)localId{
    if([[self.localIdToHashMap allKeys]containsObject:localId]){
        return [self.localIdToHashMap objectForKey:localId];
    }
    return nil;
}

///********* Store Local Assets **********/
//

-(PHAsset *)checkPhotoIsLocalWithLocalId:(NSString *)localId{
    if([[self.localPhotoDic allKeys]containsObject:localId]){
        return [self.localPhotoDic objectForKey:localId];
    }
    return nil;
}



-(NSString *)checkPhotoIsLocalWithDigest:(NSString *)digest{
    if([[self.hashToLocalIdMap allKeys]containsObject:digest]){
        return [self.hashToLocalIdMap objectForKey:digest];
    }
    return nil;
}

///********* End Store Local Assets **********/

@end

@implementation FMDBControl


+(void)asyncLoadPhotoToDB{
    [self asyncLoadPhotoToDBWithCompleteBlock:nil];
}

+(void)asyncLoadPhotoToDBWithCompleteBlock:(void(^)(NSArray * addArr))block{    
    FMDBSet * dbSet = [FMDBSet shared];
    dbSet.isLoading = YES;
     dbSet.degistIsLoading = YES;
    dispatch_async([FMUtil setterDefaultQueue], ^{
        PhotoManager * manager = [PhotoManager shareManager];
        [manager getAllPHAssetAndCompleteBlock:^(NSArray<PHAsset *> *result) {
            __block NSArray * result2 = result;//创建插入对象
            NSMutableArray * photoArr = [NSMutableArray array]; //本地所有图片
            NSMutableArray * photoIDArr = [NSMutableArray array];//所有图片localid
            for (PHAsset * asset in result2) {//添加要插入的对象集合
                if (asset.mediaType != PHAssetMediaTypeImage)//不是图片不入库 直接跳过
                    continue;
                FMLocalPhoto * photo = [[FMLocalPhoto alloc]init];
                photo.localIdentifier = asset.localIdentifier;//标识符
                photo.createDate = asset.creationDate;//创建时间
                
                photo.longitude = asset.location.coordinate.longitude;//经度
                photo.latitude = asset.location.coordinate.latitude;
                
                [[FMLocalPhotoStore shareStore] addAssetToStore:[asset copy]];//store asset
//                if(asset.location){
//                    [self geocodeWithLocation:asset.location];
//                }
                
                [photoArr addObject:photo];
                [photoIDArr addObject:asset.localIdentifier];
            }
            
            //查找已删除的
            FMDTSelectCommand * scmd1 = FMDT_SELECT(dbSet.photo);
            [scmd1 where:@"localIdentifier" notContainedIn:photoIDArr];
            [scmd1 fetchArrayInBackground:^(NSArray *result1) {
                NSMutableArray * tempDelArrIds = [NSMutableArray arrayWithCapacity:0];
                for (FMLocalPhoto * p in result1) {
                    [tempDelArrIds addObject:p.localIdentifier];
                }
                
                //删除操作
                FMDTDeleteCommand * delcmd = FMDT_DELETE(dbSet.photo);
                [delcmd where:@"localIdentifier" containedIn:tempDelArrIds];
                [delcmd saveChangesInBackground:nil];
                
                //查找没有的
                FMDTSelectCommand * scmd = FMDT_SELECT(dbSet.photo);
                [scmd where:@"localIdentifier" containedIn:photoIDArr];
                //查询数据库存在的照片 对应的localIdentifier
                [scmd fetchArrayInBackground:^(NSArray *result) {
                    @autoreleasepool {
                        //已存在的locaiD 集合
                        NSMutableArray * hadArr = [NSMutableArray arrayWithCapacity:0];
                        for (FMLocalPhoto * photo  in result) {
                            [hadArr addObject:photo.localIdentifier];
                        }
            
                        NSMutableArray * addArr = [NSMutableArray arrayWithCapacity:0];
                        for (FMLocalPhoto * photo in photoArr) {
                            if(![hadArr containsObject:photo.localIdentifier]){
                                [addArr addObject:photo];
                            }
                        }
                        //插入新增内容
                        FMDTInsertCommand *icmd = [[FMDBSet shared].photo createInsertCommand];
                        //设置添加操作是否使用replace语句
                        //                [icmd setRelpace:YES];
                        NSLog(@"新增%ld张照片",(unsigned long)addArr.count);
                        [icmd addWithArray:addArr];
                        //执行插入操作
                        [icmd saveChangesInBackground:^{
                            NSLog(@"照片入库完成");
                            result2 = nil;
                            //后台 计算 degist
                            dbSet.isLoading = NO;
                            [PhotoManager calculateDigestWhenPhotoHaveNotCompleteBlock:^(NSArray *arr) {
                             dbSet.degistIsLoading = NO;
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"calculateDigestComplete" object:nil];
//                                BOOL switchOn = SWITHCHON_BOOL
//                                if (switchOn) {
//                                    [PhotoManager shareManager].canUpload = NO;
//                                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
//                                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                                        [PhotoManager shareManager].canUpload = YES;
//                                    });
//                                }
                            
                            }];
                            if (block)
                                block(addArr);
                         
                        }];
                    }
                }];
            }];
        }];
    });
}


//反地理编码
-(void)geocodeWithLocation:(CLLocation *)location{
    //创建位置
    //    CLGeocoder *revGeo = [[CLGeocoder alloc] init];
    //    [revGeo reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
    //        if (!error && [placemarks count] > 0)
    //        {
    //            NSDictionary *dict = [[placemarks objectAtIndex:0] addressDictionary];
    //            NSLog(@"street address: %@",[dict objectForKey:@"Street"]);
    //            NSLog(@"City : %@",[dict objectForKey:@"City"]);
    //            NSLog(@"Country :%@",[dict objectForKey:@"Country"]);
    //            NSLog(@"FormattedAddressLines :%@",[dict objectForKey:@"FormattedAddressLines"][0]);
    //            NSLog(@"SubLocality : %@",[dict objectForKey:@"SubLocality"]);
    //            NSLog(@"SubThoroughfare : %@",[dict objectForKey:@"SubThoroughfare"]);
    //            NSLog(@"Thoroughfare : %@",[dict objectForKey:@"Thoroughfare"]);
    //        }
    //        else
    //        {
    //            NSLog(@"ERROR: %@", error); }
    //    }];
    
}

+(void)getDBPhotosWithCompleteBlock:(selectComplete)block{
    __weak id weakSelf = self;
    dispatch_async([FMUtil setterDefaultQueue], ^{
        FMDBSet * dbSet = [FMDBSet shared];
        if (dbSet.isLoading) {
            //如果 数据库正在同步照片库 等两秒
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf performSelector:@selector(getDBPhotosWithCompleteBlock:) withObject:block afterDelay:2];
            });
        }else{
            FMDTSelectCommand * scmd  = FMDT_SELECT(dbSet.syncLogs);
            [scmd where:@"userId" equalTo:DEF_UUID];
            [scmd fetchArrayInBackground:^(NSArray *result) {
                NSMutableArray * temp = [NSMutableArray arrayWithCapacity:0];
                for (FMSyncLogs * log in result) {
                    [temp addObject:log.localId];
//                    NSLog(@"%@",log.localId);
                }
//                NSSet *resultSet = [NSSet setWithArray:temp];
//                NSArray * resultDataSource  = [resultSet allObjects];
//                NSLog(@"%@",temp);
                FMDTSelectCommand *cmd = [dbSet.photo createSelectCommand];
                [cmd where:@"localIdentifier" notContainedIn:temp];
//                NSLog(@"%@",[cmd fetchArray]);
                block([cmd fetchArray]);
            }];
            
        }
    });
}

+(void)getDBAllLocalPhotosWithCompleteBlock:(selectComplete)block{
    __weak id weakSelf = self;
    dispatch_async([FMUtil setterDefaultQueue], ^{
        FMDBSet * dbSet = [FMDBSet shared];
        if (dbSet.degistIsLoading) {
            //如果 数据库正在同步照片库 等两秒
//            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0/*延迟执行时间*/ * NSEC_PER_SEC));
//            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
//                [weakSelf getDBAllLocalPhotosWithCompleteBlock:^(NSArray<FMLocalPhoto *> *result) {
//                }];
             dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf performSelector:@selector(getDBAllLocalPhotosWithCompleteBlock:) withObject:block afterDelay:2];
                 });
//            });
        
//            [weakSelf  performSelectorInBackground:@selector(getDBAllLocalPhotosWithCompleteBlock:)  withObject:block];
        }else{
            FMDTSelectCommand *cmd = [dbSet.photo createSelectCommand];
            NSArray * arr = [cmd fetchArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                block(arr);
            });
        }
    });
}

+(void)deletePhotoWithArray:(NSArray *)photoArr{
    FMDTDeleteCommand * cmd = FMDT_DELETE([FMDBSet shared].photo);
    [cmd where:@"localIdentifier" containedIn:photoArr];
    [cmd saveChangesInBackground:^{
        NSLog(@"清理已删除未备份照片成功");
    }];
}

+(void)reloadTables{
    FMDBSet * dbSet = [FMDBSet shared];
    //清空表
    FMDTDeleteCommand * cmd = FMDT_DELETE(dbSet.nasPhoto);
    [cmd saveChanges];
    
    
    FMDTDeleteCommand * cmd1 = FMDT_DELETE(dbSet.mediashare);
    [cmd1 saveChanges];
    
    //清空上传记录
    FMDTUpdateCommand * ucmd = FMDT_UPDATE(dbSet.photo);
    [ucmd fieldWithKey:@"uploadTime" val: [NSNull new]];
    [ucmd saveChanges];
    
//    FMDTDeleteCommand * cmd2 = FMDT_DELETE(dbSet.download);
//    [cmd2 saveChanges];
    
    FMDTDeleteCommand * cmd3 = FMDT_DELETE(dbSet.needUploadMediaShare);
    [cmd3 saveChanges];
    
    FMDTDeleteCommand * cmd4 = FMDT_DELETE(dbSet.needUploadPatch);
    [cmd4 saveChanges];
    
    FMDTDeleteCommand * cmd5 = FMDT_DELETE(dbSet.needUploadComments);
    [cmd5 saveChanges];
    
    FMDTDeleteCommand * cmd6 = FMDT_DELETE(dbSet.ownerset);
    [cmd6 saveChanges];
    
    FMDTDeleteCommand * cmd7 = FMDT_DELETE(dbSet.users);
    [cmd7 saveChanges];
    
    FMDTDeleteCommand * cmd8 = FMDT_DELETE(dbSet.userLoginInfo);
    [cmd8 saveChanges];
    
    FMDTDeleteCommand * cmd9 = FMDT_DELETE(dbSet.userInfo);
    [cmd9 saveChanges];
}


+(void)reloadLocalMediaShares{
    FMDBSet * dbSet = [FMDBSet shared];
    FMDTDeleteCommand * cmd3 = FMDT_DELETE(dbSet.needUploadMediaShare);
    [cmd3 saveChanges];
    
    FMDTDeleteCommand * cmd4 = FMDT_DELETE(dbSet.needUploadPatch);
    [cmd4 saveChanges];
    
    FMDTDeleteCommand * cmd5 = FMDT_DELETE(dbSet.needUploadComments);
    [cmd5 saveChanges];
}
#pragma  mark - NSAPhoto

+(void)asynNASPhoto:(NSArray<FMNASPhoto *> *)photoArr andCompleteBlock:(void(^)())block{
    FMDBSet * dbSet = [FMDBSet shared];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //清空表
        FMDTDeleteCommand * cmd = FMDT_DELETE(dbSet.nasPhoto);
        [cmd saveChangesInBackground:^{
            //插入表
            FMDTInsertCommand *icmd = [[FMDBSet shared].nasPhoto createInsertCommand];
            [icmd addWithArray:photoArr];
            [icmd saveChangesInBackground:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    block();
                });
            }];
        }];
        
    });
}

#pragma mark - 缓存 mediaShare

+(void)asynMediaShareWithArray:(NSArray<FMMediaShare *> *)arr andCompleteBlock:(void (^)(NSArray *insertArr,NSArray *updateArr))diffCallback{
    FMDBSet * dbSet = [FMDBSet shared];
    NSMutableArray * idArr = [NSMutableArray arrayWithCapacity:0];
    for (FMMediaShare * doc in arr) {
        [idArr addObject:doc.digest];
    }
    
    NSMutableArray * uuidArr = [NSMutableArray arrayWithCapacity:0];
    for (FMMediaShare * doc in arr) {
        [uuidArr addObject:doc.uuid];
    }
    
    FMDTSelectCommand * scmd = FMDT_SELECT(dbSet.mediashare);
    [scmd where:@"digest" containedIn:idArr];
    
    //查询本地存在的degist对应的uuid
    [scmd fetchArrayInBackground:^(NSArray *result) {
        //已存在的uuid全集(本地 不需要更新)
        NSMutableArray * localUUIDArr = [NSMutableArray arrayWithCapacity:0];
        for (FMMediaShare * doct in result) {
            [localUUIDArr addObject:doct.uuid];
        }
        //查找不包含在已存在的本地uuid（需要更新 hash）
        [scmd where:@"uuid" notContainedIn:localUUIDArr];
        //需要更新的uuid集合
        NSArray * needUpdateArr = [scmd fetchArray];
        
        NSMutableArray * needUpdateUUIDArr = [NSMutableArray arrayWithCapacity:0];
        for (FMMediaShare * share in needUpdateArr) {
            [needUpdateUUIDArr addObject:share.uuid];
        }
        NSMutableArray * updateArr = [NSMutableArray arrayWithCapacity:0];
        
        //需要插入或更新的 uuid
        NSMutableArray * toolArr = [NSMutableArray array];
        for (FMMediaShare * docc in arr) {
            if(![localUUIDArr containsObject:docc.uuid]){
                if ([needUpdateUUIDArr containsObject:docc.uuid]) {
                    [updateArr addObject:docc];
                }else{
                    [toolArr addObject:docc];
                }
            }
        }
        //执行更新操作
        FMDTUpdateObjectCommand * ocmd =  FMDT_UPDATE_OBJECT(dbSet.mediashare);
        [ocmd addWithArray:updateArr];
        [ocmd saveChanges];
        
        FMDTInsertCommand *icmd = [dbSet.mediashare createInsertCommand];
        [icmd addWithArray:toolArr];
        //执行插入操作
        [icmd saveChangesInBackground:^{
            NSLog(@"mediaShare存档完成");
        }];
        
        if (diffCallback) {
            diffCallback(toolArr,updateArr);
        }
    }];
    
}

+(NSArray *)getAllMediaShares{
    FMDBSet * dbSet = [FMDBSet shared];
    FMDTSelectCommand * scmd = FMDT_SELECT(dbSet.mediashare);
    [scmd orderByDescending:@"mtime"];
    NSLog(@"完成取出数据");
    NSArray * arr = [scmd fetchArray];
    
    //本地去查询 结果 合并
    NSArray * localArr = [FMMediaShareTask mediaTaskGetLocalMediaShare];
    NSMutableArray * tempArr = [NSMutableArray arrayWithArray:arr];
    [tempArr addObjectsFromArray:localArr];
    
    //排序
    NSArray *array2 = [tempArr sortedArrayUsingComparator:
                       ^NSComparisonResult(id<FMMediaShareProtocol> obj1, id<FMMediaShareProtocol>obj2) {
                           NSComparisonResult result = NSOrderedDescending;
                           if ([obj1 getTime]>[obj2 getTime]) {
                               result = NSOrderedAscending;
                           }
                           return result;
                       }];
    tempArr = [NSMutableArray arrayWithArray:array2];
    
    
    NSMutableArray * all = [NSMutableArray arrayWithCapacity:0];
    for (id<FMMediaShareProtocol> share in tempArr) {
        if (IsEquallString(share.author, DEF_UUID) && share.viewers.count<2 &&  [share.isAlbum integerValue] == 1) {
            continue;
        }
        [all addObject:share];
    }
    return  all;
}

+(void)getAllAlbumWithCompleteBlock:(void(^)(NSArray * result))block;{
    FMDBSet * set = [FMDBSet shared];
    FMDTSelectCommand * scmd = FMDT_SELECT(set.mediashare);
    [scmd where:@"album" equalTo:@(1)];
    [scmd where:@"archived" equalTo:@(0)];
    [scmd orderByDescending:@"mtime"];
    [scmd fetchArrayInBackground:^(NSArray *result) {
        block(result);
    }];
}



#pragma mark - 拿到 用户名


#pragma mark - OwnerSet
//+(void)asynOwnerSet{
//    FMOwnerSetAPI * api = [FMOwnerSetAPI new];
//    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//        NSLog(@"获取ownerSet成功");
//        FMDBSet * dbSet = [FMDBSet shared];
//        //清空表
//        FMDTDeleteCommand * cmd = FMDT_DELETE(dbSet.ownerset);
//        [cmd saveChanges];
//        
//        //添加
//        FMOwnerSet * set = [FMOwnerSet new];
//        set.ownerset = request.responseJsonObject;
//        FMDTInsertCommand * icmd = FMDT_INSERT(dbSet.ownerset);
//        [icmd add:set];
//        [icmd saveChanges];
//    } failure:^(__kindof JYBaseRequest *request) {
//        [FMCheckManager shareCheckManager];
//        NSLog(@"获取ownerSet失败");
//    }];
//}
//
//+(NSArray *)getOwnerSet{
//    FMDBSet * dbSet = [FMDBSet shared];
//    FMDTSelectCommand * scmd = FMDT_SELECT(dbSet.ownerset);
//    NSArray * arr = [scmd fetchArray];
//    if (arr.count>0) {
//        FMOwnerSet * set = arr[0];
//        return set.ownerset;
//    }
//    return [NSArray array];
//}




#pragma mark - Users
/************************* User Control ****************/
+(void)asynUsers{
    if (!KISCLOUD) {
    FMGetUsersAPI * api = [FMGetUsersAPI new];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.responseJsonObject);
        NSMutableDictionary * usersDic = [NSMutableDictionary dictionaryWithCapacity:0];
        NSMutableArray * usersArr = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary * dic in request.responseJsonObject) {
            FMUsers * user = [FMUsers yy_modelWithJSON:dic];
            [usersArr addObject:user];
            //create userDic for FMConfigInstance
            [usersDic setObject:user.username forKey:user.uuid];
        }

        FMConfigInstance.usersDic = usersDic;

        FMDTDeleteCommand * cmd7 = FMDT_DELETE([FMDBSet shared].users);
        [cmd7 saveChangesInBackground:^{
            FMDTInsertCommand * icmd = FMDT_INSERT([FMDBSet shared].users);
            [icmd addWithArray:usersArr];
            [icmd saveChangesInBackground:^{
                NSLog(@"用户同步成功");
            }];
        }];

    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"同步用户失败");
    }];
        
    }
    
    [self asyncUserHome];
}


+(void)asyncUserHome{
   
    FMAccountUsersAPI * usersApi = [FMAccountUsersAPI new];
    [usersApi startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//        NSLog(@"😈😈😈😈%@",request.responseJsonObject);
        NSDictionary * dic ;
        if (KISCLOUD) {
        NSDictionary *dataDic = request.responseJsonObject;
        dic = dataDic[@"data"];
        }else{
          dic  = request.responseJsonObject;
        }
//        NSLog(@"%lu",(unsigned long)userArr);
//        if (userArr.count>0) {
//            for (NSDictionary * dic in userArr) {
//          NSDictionary * dic = request.responseJsonObject;
       
                if (IsEquallString(dic[UUIDKey], DEF_UUID)) {
                    if ([dic[@"isAdmin"] boolValue]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:FM_USER_ISADMIN object:@(1)];
                    }else
                        [[NSNotificationCenter defaultCenter] postNotificationName:FM_USER_ISADMIN object:@(0)];
//                    FMConfigInstance.userHome = dic[@"home"];
                    //更新 UsrInfo 信息
                                    FMUserInfo * info = [FMUserInfo new];
                                    info.userId = DEF_UUID;
//                                    info.home = dic[@"home"];
//                                    info.library = dic[@"library"];
                                    FMDTUpdateObjectCommand * ucmd = FMDT_UPDATE_OBJECT([FMDBSet shared].userInfo);
                                    [ucmd add:info];
                                    [ucmd saveChanges];
//                }
            }
            NSLog(@"userhome表更新完成");
//        }
     
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"%@",request.error);
        NSLog(@"更新UsersHome失败");
    }];
}


+(NSArray *)getAllUsersUUID{
    NSMutableArray * usersArr = [NSMutableArray arrayWithCapacity:0];
    NSArray * users =  [self getAllUsers];
    for (FMUsers *user in users) {
        [usersArr addObject:user.uuid];
    }
    return usersArr;
}


+(NSArray<FMUsers *> *)getAllUsers{
    FMDBSet * set = [FMDBSet shared];
    FMDTSelectCommand * cmd = FMDT_SELECT(set.users);
    NSArray * users =  [cmd fetchArray];
    return users;
}

//添加 用户登录记录
+(void)addUserLoginInfo:(FMUserLoginInfo *)info{
    FMDBSet * set = [FMDBSet shared];
    FMDTSelectCommand * scmd = FMDT_SELECT(set.userLoginInfo);
    [scmd where:@"uuid" equalTo:info.uuid];
    if([scmd fetchArray].count){
        FMDTUpdateObjectCommand * ocmd = FMDT_UPDATE_OBJECT(set.userLoginInfo);
        [ocmd add:info];
        [ocmd saveChanges];
    }else{
        FMDTInsertCommand * icmd = FMDT_INSERT(set.userLoginInfo);
        [icmd add:info];
        [icmd saveChanges];
    }
}

//删除一条 用户登录记录
+(void)removeUserLoginInfo:(NSString *)userid{
    FMDBSet * set = [FMDBSet shared];
    FMDTDeleteCommand * dcmd = FMDT_DELETE(set.userLoginInfo);
    [dcmd where:@"uuid" equalTo:userid];
    [dcmd saveChanges];
    
    //删除上传记录
    FMDTDeleteCommand * dcmd2 = FMDT_DELETE(set.syncLogs);
    [dcmd2 where:@"userId" equalTo:userid];
    [dcmd2 saveChanges];
    
}

//查询一条用户登录记录
+(FMUserLoginInfo *)findUserLoginInfo:(NSString *)userid{
    FMDBSet * set = [FMDBSet shared];
    FMDTSelectCommand * scmd = FMDT_SELECT(set.userLoginInfo);
    NSArray * users =  [scmd fetchArray];
    if(users.count)
        return users[0];
    return nil;
}

+(NSArray  *)getAllUserLoginInfo{
    FMDBSet * set = [FMDBSet shared];
    FMDTSelectCommand * scmd = FMDT_SELECT(set.userLoginInfo);
    return [scmd fetchArray];
}

/************************************************************/

+(NSArray *)getAllDownloadFiles{
    FMDBSet * set = [FMDBSet shared];
    FMDTSelectCommand * cmd = FMDT_SELECT(set.download);
    [cmd where:@"userId" equalTo:DEF_UUID];
    return [cmd fetchArray];
}


+(void)updateDownloadWithFile:(FLDownload *)download isAdd:(BOOL)isAdd{
    FMDBSet * set = [FMDBSet shared];
    if (isAdd) {
        FMDTSelectCommand * cmd = FMDT_SELECT(set.download);
        [cmd where:@"uuid" equalTo:download.uuid];
        [cmd where:@"userId" equalTo:DEF_UUID];
        NSArray *result =  [cmd fetchArray];
        if (!result.count) {
            FMDTInsertCommand * icmd = FMDT_INSERT(set.download);
            [icmd add:download];
            [icmd saveChangesInBackground:nil];
            NSLog(@"成功添加一条记录：%@",download.name);
        }
        else{
            NSLog(@"已下载的问题，不能重复添加");
        }
    }else{
        FMDTSelectCommand * cmd = FMDT_SELECT(set.download);
        [cmd where:@"uuid" equalTo:download.uuid];
        NSArray *result = [cmd fetchArray];
        if (result.count) {
            //当 只有一个人持有的时候 删除
            if (result.count == 1) {
                [FMFileManagerInstance removeFileWithFileName:download.name andCompleteBlock:^(BOOL isSuccess) {
                    if (isSuccess) {
                        [FMDBControl _removeDownloadColum:download.uuid];
                        MyNSLog(@"%@😁%@",download.uuid,download.name);
                    }else{
                         MyNSLog(@"👎%@😁%@",download.uuid,download.name);
                        NSString * filePath = [NSString stringWithFormat:@"%@/%@",File_DownLoad_DIR,download.name];
                        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                            NSError * error = nil;
                            [[NSFileManager defaultManager]removeItemAtPath:filePath error:&error];
                            if (!error) {
                                [FMDBControl _removeDownloadColum:download.uuid];
                            }
                        }else{
                            [FMDBControl _removeDownloadColum:download.uuid];
                        }
                    }
                }];
            }else{
                [FMDBControl _removeDownloadColum:download.uuid];
            MyNSLog(@"成功删除一条记录：%@",download.name);
            }
        }else{
            MyNSLog(@"未下载，无法删除");
        }
    }
}

+(void)_removeDownloadColum:(NSString *)uuid{
    FMDBSet * set = [FMDBSet shared];
    FMDTDeleteCommand * dcmd = FMDT_DELETE(set.download);
    [dcmd where:@"uuid" equalTo:uuid];
    [dcmd where:@"userId" equalTo:DEF_UUID];
    [dcmd saveChangesInBackground:^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"deleteCompleteNoti" object:nil];
    }];
}


+ (void)siftMidiaPhotoWithResultArr:(NSMutableArray *)arr CompleteBlock:(void (^)(NSMutableArray *photoArr))completeBlock{
    NSMutableArray *alreadyUploadPhotoArray = [NSMutableArray array];
    [FMDBControl getNetPhotosSucessBlock:^(NSMutableArray *photoArr) {
        NSPredicate * filterPredicate_same = [NSPredicate predicateWithFormat:@"SELF IN %@",arr];
        NSArray * filter_no = [photoArr filteredArrayUsingPredicate:filterPredicate_same];
//          NSLog(@"😜😜😜😜😜%@",photoArr);
        [alreadyUploadPhotoArray addObjectsFromArray:filter_no];
        completeBlock(alreadyUploadPhotoArray);
    }];
}


+(void)getNetPhotosSucessBlock:(void (^)(NSMutableArray *photoArr))sucess{

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        FMMediaAPI * api = [FMMediaAPI new];
   
        [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            NSArray * userArr = request.responseJsonObject;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                @autoreleasepool {
                    NSMutableArray *photoArr = [NSMutableArray arrayWithCapacity:0];
                    for (NSDictionary *dic in userArr) {
                        @autoreleasepool {
                            FMNASPhoto *nasPhoto = [FMNASPhoto yy_modelWithJSON:dic];
                            [photoArr addObject:nasPhoto.fmhash];
                        }
                    }
                       sucess(photoArr);
                }
            });
   
        } failure:^(__kindof JYBaseRequest *request) {
            NSLog(@"载入Media失败,%@",request.error);
        }];
    });
}


@end
