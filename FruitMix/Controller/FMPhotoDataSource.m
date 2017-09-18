//
//
//  FMPhotoDataSource.m
//  FruitMix
//
//  Created by 杨勇 on 16/8/24.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMPhotoDataSource.h"
#import "FMUploadFileAPI.h"

@implementation FMPhotoDataSource{
    NSMutableSet * _photosLocalIds;
    NSMutableArray * _localphotoDigest;
    CFAbsoluteTime  _start;
    CFAbsoluteTime _end;
}

+(instancetype)shareInstance{
    //不能使用 单例 姑且挂到 appdelegate 上
    if(!MyAppDelegate.photoDatasource){
        MyAppDelegate.photoDatasource = [FMPhotoDataSource new];
    }
    return MyAppDelegate.photoDatasource;
}

-(void)dealloc{
    [self.netphotoArr removeAllObjects];
    [self.dataSource removeAllObjects];
    [self.imageArr removeAllObjects];
    [self.timeArr removeAllObjects];
}

-(instancetype)init{
    if (self = [super init]) {
        self.imageArr = [NSMutableArray arrayWithCapacity:0];
        self.timeArr = [NSMutableArray arrayWithCapacity:0];
//        self.dataSource = [NSMutableArray arrayWithCapacity:0];
        _photosLocalIds = [NSMutableSet set];
        _localphotoDigest = [NSMutableArray arrayWithCapacity:0];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLibruaryChange) name:PHOTO_LIBRUARY_CHANGE_NOTIFY object:nil];
        [self initPhotos];
    }
    return self;
}

-(void)handleLibruaryChange{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self initPhotosIsRefrash];
    });
}

-(void)initPhotos{
//    PHFetchOptions * option = [[PHFetchOptions alloc]init];
//    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    _start = CFAbsoluteTimeGetCurrent();
    // do something
    

    [FMDBControl getDBPhotosWithCompleteBlock:^(NSArray<FMLocalPhoto *> *result){
        NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
        for (FMLocalPhoto * photo in result) {
            [_photosLocalIds addObject:photo.localIdentifier];//记录本地图的ids
             FMPhotoAsset * asset = [FMPhotoAsset new];
             asset.localId = photo.localIdentifier;
             asset.degist = photo.degist;
             asset.createtime = photo.createDate;
            
            if (asset.degist.length)
                [_localphotoDigest addObject:asset.degist];
             [arr addObject:asset];
        }
        self.imageArr = arr;
        [self sequencePhotosAndCompleteBlock:^{
            //搜索网络数据
            [self getNetPhotos];
        }];
    }];
}

-(void)getNetPhotos{
    @weaky(self)
    NSLog(@"当前 UUID: %@ ",DEF_UUID);

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        FMMediaAPI * api = [FMMediaAPI new];
        [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
            [weak_self analysisPhotos:request.responseJsonObject];
//            [weak_self siftPhotos];
//            NSLog(@"respose👌: %@ ",request.responseJsonObject);
        } failure:^(__kindof JYBaseRequest *request) {
            NSLog(@"载入Media失败,%@",request.error);
        }];
    });
}

- (void)siftPhotos{
    @weaky(self)
    NSString *entryuuid = PHOTO_ENTRY_UUID;
    [FMUploadFileAPI getDirEntryWithUUId:entryuuid success:^(NSURLSessionDataTask *task, id responseObject) {
        //                    NSLog(@"%@",responseObject);
        NSDictionary * dic = responseObject;
        NSMutableArray * photoArrHash = [NSMutableArray arrayWithCapacity:0];
        
        NSArray * arr = [dic objectForKey:@"entries"];
        for (NSDictionary *dic in arr) {
            FMNASPhoto *nasPhoto = [FMNASPhoto yy_modelWithJSON:dic];
            [photoArrHash addObject:nasPhoto.fmhash];
        }
         dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [FMDBControl getDBAllLocalPhotosWithCompleteBlock:^(NSArray<FMLocalPhoto *> *result) {
            NSMutableArray *localPhotoHashArr = [NSMutableArray arrayWithCapacity:0];
            for (FMLocalPhoto * p in result) {
                if (p.degist.length >0) {
                    [localPhotoHashArr addObject:p.degist];
                }
            }
            NSSet *photoArrHashSet = [NSSet setWithArray:photoArrHash];
            NSSet *localPhotoHashArrSet = [NSSet setWithArray:localPhotoHashArr];
            
            NSPredicate * filterPredicate_same = [NSPredicate predicateWithFormat:@"SELF IN %@",[localPhotoHashArrSet allObjects]];
            NSArray * filter_no = [[photoArrHashSet allObjects] filteredArrayUsingPredicate:filterPredicate_same];
            NSMutableArray * siftPhotoArrHash  = [NSMutableArray arrayWithCapacity:0];
            [siftPhotoArrHash addObjectsFromArray:filter_no];
//            NSLog(@"😜😜😜😜😜%ld",(long)filter_no.count);
            [[NSUserDefaults standardUserDefaults] setObject:siftPhotoArrHash forKey:@"uploadImageArr"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            MyNSLog(@"请求NAS 照片返回%@",responseObject);
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"siftPhoto" object:nil];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"siftPhotoForLeftMenu" object:nil];
        }];
        
         });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSHTTPURLResponse * rep = (NSHTTPURLResponse *)task.response;
        NSLog(@"%ld",(long)rep.statusCode);
        
        if (rep.statusCode == 404) {
            [FMUploadFileAPI getDriveInfoCompleteBlock:^(BOOL successful) {
                if (successful) {
                    [FMUploadFileAPI getDirectoriesForPhotoCompleteBlock:^(BOOL successful) {
                        if (successful) {
                            [FMUploadFileAPI creatPhotoDirEntryCompleteBlock:^(BOOL successful) {
                                if (successful) {
                                    [weak_self siftPhotos];
                                }
                            }];
                        }
                    }];
                }
            }];
            //
        }
        
    }];
    
}


-(void)analysisPhotos:(id)response{
    NSArray * userArr = response;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @autoreleasepool {
            NSMutableArray * photoArr = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *dic in userArr) {
                @autoreleasepool {
//                    NSLog(@"😁%@",dic);
//                    if (contentArr.count>0) {
//                        NSString *photoHash = contentArr[0];
                    FMNASPhoto *nasPhoto = [FMNASPhoto yy_modelWithJSON:dic];
//                        if(!IsNilString(photoHash) && ![_localphotoDigest containsObject:photoHash])
                    [photoArr addObject:nasPhoto];
                }
            }
            if (photoArr.count) {
                self.netphotoArr = photoArr;
//               [_imageArr addObjectsFromArray:photoArr];
                
                for (IDMPhoto * photo  in photoArr) {
                    __block BOOL isExist = NO;
                    [_imageArr enumerateObjectsUsingBlock:^(IDMPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([[obj getPhotoHash] isEqual:[photo getPhotoHash]]) {//数组中已经存在该对象
                            *stop = YES;
                            isExist = YES;
                        }
                    }];
                    if (!isExist) {//如果不存在就添加进去
                        [_imageArr addObject:photo];
                    }
                }
                [self initPhotosIsRefrash];
            }
        }
        
    });
    //Cache 到数据库
//    [FMDBControl asynNASPhoto:[photoArr copy] andCompleteBlock:^{
//        NSLog(@"cache nasPhoto 数据完成");
//    }];
}

-(void)initPhotosIsRefrash{
    @synchronized (self) {
        @weaky(self);
        NSCondition *condition = [[NSCondition alloc] init];
        [condition lock];
        NSLog(@"来了");
        [FMDBControl getDBPhotosWithCompleteBlock:^(NSArray<FMLocalPhoto *> *result) {
            NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
            for (FMLocalPhoto * photo in result) {
           if(![_photosLocalIds containsObject:photo.localIdentifier]){
                    [_photosLocalIds addObject:photo.localIdentifier];
                    FMPhotoAsset * asset = [FMPhotoAsset new];
                    asset.localId = photo.localIdentifier;
                    asset.degist = photo.degist;
                    asset.createtime = photo.createDate;
                    [arr addObject:asset];
                }
            }
            [condition signal];
            [weak_self.imageArr addObjectsFromArray: arr];
            [weak_self sequencePhotosAndCompleteBlock:nil];
            NSLog(@"走了");
        }];
        [condition wait];
        [condition unlock];
    }
}

-(void)sequencePhotosAndCompleteBlock:(void(^)())block{
       dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSComparator cmptr = ^(IDMPhoto * photo1, IDMPhoto * photo2){
            NSDate * tempDate = [[photo1 getPhotoCreateTime]laterDate:[photo2 getPhotoCreateTime]];
            if ([tempDate isEqualToDate:[photo1 getPhotoCreateTime]]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            if ([tempDate isEqualToDate:[photo2 getPhotoCreateTime]]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        };
        [self.imageArr sortUsingComparator:cmptr];
        @weaky(self);
        [self getTimeArrAndPhotoGroupArrWithCompleteBlock:^(NSMutableArray *tGroup, NSMutableArray *pGroup) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weak_self.timeArr = tGroup;
                weak_self.dataSource = pGroup;
                
                weak_self.isFinishLoading = YES;
                [[NSNotificationCenter defaultCenter]postNotificationName:FMPhotoDatasourceLoadFinishNotify object:nil];
                if (block) block();
                if (_delegate && [_delegate respondsToSelector:@selector(dataSourceFinishToLoadPhotos)]) {
                    [_delegate dataSourceFinishToLoadPhotos];
                }
            });
        }];
    });
}

-(void)getTimeArrAndPhotoGroupArrWithCompleteBlock:(SortSuccessBlock)block{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @autoreleasepool {
            NSMutableArray * tArr = [NSMutableArray array];//时间组
            NSMutableArray * pGroupArr = [NSMutableArray array];//照片组数组
            if (self.imageArr.count>0) {
                IDMPhoto * photo = self.imageArr[0];
                NSMutableArray * photoDateGroup1 = [NSMutableArray array];//第一组照片
                [photoDateGroup1 addObject:photo];
                [pGroupArr addObject:photoDateGroup1];
                [tArr addObject:[photo getPhotoCreateTime]];
                
                NSArray * array = [NSArray arrayWithArray: self.imageArr];
                for (IDMPhoto * photoNull in array) {
                    if ([photoNull getPhotoCreateTime]==nil){
                        [self.imageArr removeObject:photoNull];
                    }
                }
                NSMutableArray * photoDateGroup2 = photoDateGroup1;//最近的一组
                for (int i = 1 ; i < self.imageArr.count; i++) {
                    @autoreleasepool {
//                        IDMPhoto * photoUp =  self.imageArr[i];
//                        IDMPhoto * photoDown = self.imageArr[i-1];
////                         NSLog(@"%@😁%@",[photoUp getPhotoHash],[photoDown getPhotoHash]);
//                        if ([self isSamePhotoHash:[photoUp getPhotoHash] photoHash2:[photoDown getPhotoHash]]) {
//                            [self.imageArr removeObject:photoUp];
//                        }

                        IDMPhoto * photo1 =  self.imageArr[i];
                        IDMPhoto * photo2 = self.imageArr[i-1];
                        if ([self isSameDay:[photo1 getPhotoCreateTime] date2:[photo2 getPhotoCreateTime]]) {
                            [photoDateGroup2 addObject:photo1];
                        }
                        else{
                            [tArr addObject:[photo1 getPhotoCreateTime]];
                            photoDateGroup2 = nil;
                            photoDateGroup2 = [NSMutableArray array];
                            [photoDateGroup2 addObject:photo1];
                            [pGroupArr addObject:photoDateGroup2];
                        }
                    }
                }
            }
            //主线程
            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"%@",pGroupArr);
                _end = CFAbsoluteTimeGetCurrent();
                
//                NSLog(@"时间：========>%f", _end - _start);
                block(tArr,pGroupArr);
            });
        }
    });
}

- (BOOL)isSamePhotoHash:(NSString *)photoHash1 photoHash2:(NSString *)photoHash2

{
    if ([photoHash1 isEqualToString:photoHash2]) {
       return YES;
    }else{
       return NO;
    }
}

- (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2

{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlag = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDateComponents *comp1 = [calendar components:unitFlag fromDate:date1];
    
    NSDateComponents *comp2 = [calendar components:unitFlag fromDate:date2];
    
    return (([comp1 day] == [comp2 day]) && ([comp1 month] == [comp2 month]) && ([comp1 year] == [comp2 year]));
    
}

-(NSString *)getDateStringWithPhoto:(NSDate *)date{
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy-MM-dd";
    [formatter1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString * dateString = [formatter1 stringFromDate:date];
    return dateString;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}
@end
