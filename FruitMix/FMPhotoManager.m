//
//  FMPhotoManager.m
//  Photos
//
//  Created by JackYang on 2017/10/26.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FMPhotoManager.h"

@interface FMPhotoManager()
{
    BOOL _isdestroing;
}

@property (nonatomic, readwrite) NSMutableArray<FMAsset *> *hashwaitingQueue;

@property (nonatomic, readwrite) NSMutableArray<FMAsset *> *hashWorkingQueue;

@property (nonatomic, readwrite) NSMutableArray<FMAsset *> *hashFailQueue;

@property (nonatomic, readwrite) NSMutableArray<FMAsset *> *uploadPaddingQueue;

@property (nonatomic, readwrite) NSMutableArray<FMAsset *> *uploadingQueue;

@property (nonatomic, readwrite) NSMutableArray<FMAsset *> *uploadedQueue;

@property (nonatomic, readwrite) NSMutableArray<FMAsset *> *uploadErrorQueue;

@property (nonatomic, strong) NSMutableArray *hashwaitingNetQueue;

@property (nonatomic, readwrite) BOOL isStoped;

@property (nonatomic, readwrite) BOOL isReady;

@property (nonatomic) NSOperationQueue *startQueue;

@property (nonatomic) NSOperationQueue *scheduleQueue;

@property (nonatomic,weak) NSTimer *reachabilityTimer;

@end


@implementation FMAsset


@end

@implementation FMPhotoManager

+ (instancetype)defaultManager
{
    static FMPhotoManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _hashLimitCount = 4;
        _uploadLimitCount = 1;
        _workingModel = [[UploadWokingModel alloc]init];
        _isStoped = false;
        _isReady = false;
    }
    return self;
}

- (void)loadDataCompleteBlock:(void(^)(BOOL))callback
{
    MyNSLog(@"%lu",(unsigned long)_hashwaitingQueue.count);
    [FMDBControl getDBAllLocalPhotosWithCompleteBlock:^(NSArray<FMLocalPhoto *> *result) {
        FMLocalPhotoStore * store = [FMLocalPhotoStore shareStore];
        for (FMLocalPhoto *photo in result) {
            PHAsset * photoAsset = [store checkPhotoIsLocalWithLocalId:photo.localIdentifier];
            if (photoAsset) {
                NSString *photohash = [store getPhotoHashWithLocalId:photo.localIdentifier];
                FMAsset *asset = [FMAsset new];
                asset.asset = photoAsset;
                asset.sha256 = photohash;
                [self.hashwaitingQueue addObject:asset];
            }
        }
        callback(true);
    MyNSLog(@"%lu",(unsigned long)_hashwaitingQueue.count);
    }];

}

- (void)loadNetDataCompleteBlock:(void(^)(BOOL))callback
{
    NSString *entryuuid = PHOTO_ENTRY_UUID;
    [FMUploadFileAPI getDirEntryWithUUId:entryuuid success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray * arr ;
        if (!KISCLOUD) {
            NSDictionary * dic = responseObject;
            arr = dic[@"entries"];
        }else {
            NSDictionary * dic = responseObject;
            NSDictionary * entriesDic = dic[@"data"];
            arr = entriesDic[@"entries"];
        }
        
        for (NSDictionary *dic in arr) {
            FMNASPhoto *nasPhoto = [FMNASPhoto yy_modelWithJSON:dic];
            [self.hashwaitingNetQueue addObject:nasPhoto.fmhash];
        }
        callback(true);
        //        MyNSLog (@"NAS里的照片的所有Hash======>%@",_hashwaitingNetQueue);
        //        MyNSLog (@"NAS里的照片数量======>%lu",(unsigned long)_hashwaitingNetQueue.count);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        MyNSLog(@"%@",error);
    }];
}

- (void)saveSha256:(NSString *)sha256 withLocalId:(NSString *)localId
{
    
}

- (void)schedule
{
    if (!_workingModel.hashWorkingQueue) {
        _workingModel.hashWorkingQueue = [NSMutableArray arrayWithArray:self.hashWorkingQueue];
    }
    
//    if (_reachabilityTimer) {
//        [_reachabilityTimer invalidate];
//        _reachabilityTimer = nil;
//    }
    
     @weaky(self)
   __block RACDisposable *handler = [RACObserve(self.workingModel, hashWorkingQueue) subscribeNext:^(id x) {
//       if (_scheduleQueue) {
//           return ;
//       }
       if (_isStoped) {
           [handler dispose];
           return;
       }
       
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            MyNSLog(@"%@", [NSThread currentThread]);
         
            if (self.workingModel.hashWorkingQueue.count == 0) {
                if (_uploadingQueue.count>0) {
                    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:
                                           NSMakeRange(0,_uploadLimitCount)];
                    NSArray *resultArray = [_uploadingQueue objectsAtIndexes:indexes];
                    [[self.workingModel mutableArrayValueForKey:@"hashWorkingQueue"] addObjectsFromArray:resultArray];
                    [_uploadingQueue removeObjectsAtIndexes:indexes];
//                    MyNSLog(@"%@",_uploadingQueue);
                }else if(_uploadingQueue.count == 0 &&_uploadErrorQueue.count>0){
                    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:
                                           NSMakeRange(0,_uploadLimitCount)];
                    NSArray *resultArray = [_uploadErrorQueue objectsAtIndexes:indexes];
                    [[self.workingModel mutableArrayValueForKey:@"hashWorkingQueue"] addObjectsFromArray:resultArray];
                    [_uploadErrorQueue removeObjectsAtIndexes:indexes];
                    MyNSLog(@"%@",_workingModel.hashWorkingQueue);
                }else if (_uploadingQueue.count == 0 &&_uploadErrorQueue.count==0 &&self.workingModel.hashWorkingQueue.count == 0){
                     [weak_self stop];
                    if (!_reachabilityTimer) {

                        _reachabilityTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(reStart) userInfo:nil repeats:YES];
                        [[NSRunLoop currentRunLoop]run];
                    }
                }
            }else if(_workingModel.hashWorkingQueue.count == _uploadLimitCount){
                for (FMAsset *asset in _workingModel.hashWorkingQueue) {
                    [PhotoManager getImageDataWithPHAsset:asset.asset andCompleteBlock:^(NSString *filePath) {
                        [weak_self uplodingWithFilePath:filePath CompleteBlock:^(NSError *error, NSString *hash) {
                            if (error) {
                                [self.uploadErrorQueue addObject:asset];
                                if (self.workingModel.hashWorkingQueue) {
                         
                                    [[self.workingModel mutableArrayValueForKey:@"hashWorkingQueue"] removeAllObjects];
                                }
                                MyNSLog(@"🌶");
                            }else{
                                MyNSLog(@"上传成功");
                                if (self.workingModel.hashWorkingQueue) {
                                   [[self.workingModel mutableArrayValueForKey:@"hashWorkingQueue"] removeAllObjects];
                                }
                                
                                [[NSNotificationCenter defaultCenter]postNotificationName:@"backUpProgressChange" object:nil];
                                if (self.uploadedQueue) {
                                    [self.uploadedQueue addObject:asset];
                                }
                              
                                if(_uploadingQueue != nil && _uploadErrorQueue!=nil &&self.workingModel.hashWorkingQueue !=nil
                                   && _uploadingQueue.count == 0 &&_uploadErrorQueue.count==0 &&self.workingModel.hashWorkingQueue.count == 0){
                                    MyNSLog(@"全部上传完成");
                                    [weak_self stop];
                            
                                    if (!_reachabilityTimer) {
                                        _reachabilityTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(reStart) userInfo:nil repeats:YES];
                                         [[NSRunLoop currentRunLoop]run];
                                    }
                                }
                            }
                        }];
                    }];
                }
            }
//        }];
        });
//        [_scheduleQueue addOperation:operation];
//        MyNSLog(@"%@",x);
    }];
//    [self.workingModel addObserver:self forKeyPath:@"hashWorkingQueue" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionPrior context:nil];
}

- (void)readyCompleteBlock:(void(^)(BOOL))callback{
//    MyNSLog(@"%@,%@,%@,%@,%@,%@,%@,%@", _uploadingQueue ,
//            _hashwaitingQueue ,
//            _hashWorkingQueue ,
//            _workingModel.hashWorkingQueue ,
//            _hashWorkingQueue ,
//            _hashwaitingNetQueue ,
//            _uploadErrorQueue ,
//            _uploadedQueue);
     @weaky(self)
    if (!_startQueue) {
        _startQueue = [[NSOperationQueue alloc] init];
    }
    if (_isReady) {
        callback(YES);
        return;
    }
    [self.hashwaitingNetQueue removeAllObjects];
    [self.hashwaitingQueue removeAllObjects];
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        RACSignal* netPhotoSignal=[RACSignal createSignal:^RACDisposable *(id subscriber){
            [weak_self loadNetDataCompleteBlock:^(BOOL succee) {
                [subscriber sendNext:@"2"];
            }];
            return [RACDisposable disposableWithBlock:^{
        
            }];
        }];
        
        RACSignal* loaclPhotoSignal=[RACSignal createSignal:^RACDisposable *(id subscriber) {
            
            [weak_self loadDataCompleteBlock:^(BOOL succeed) {
                
                [subscriber sendNext:@"1"];
            }];
            return [RACDisposable disposableWithBlock:^{
            
            }];
        }];
        
        RACSignal * zipSignal = [netPhotoSignal zipWith:loaclPhotoSignal];
        NSMutableArray *arrForUpload = [NSMutableArray arrayWithCapacity:0];
        [zipSignal subscribeNext:^(id x) {
            for (FMAsset *asset in _hashwaitingQueue) {
                if (![self.hashwaitingNetQueue containsObject:asset.sha256]) {
                    [arrForUpload addObject:asset];
                }
            }
            [weak_self putUploadingQueue:arrForUpload completeBlock:callback];
        }];
    }];
    [_startQueue addOperation:operation];

}

- (void)start
{
    __weak typeof(self) weakSelf = self;
    _isStoped = false;
//    if (_uploadingQueue.count>0) {
//        [self schedule];
//        return;
//    }
   
//    if (_isReady) {
//      [weakSelf schedule];
//        return;
//    }
    
    if (_isReady) {
       [weakSelf schedule];
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            if ([self respondsToSelector:@selector(start)]) {
                [self performSelector:@selector(start) withObject:nil];
            }
        });
    }
}

- (void)stop
{
    if (_startQueue) {
        [_startQueue cancelAllOperations];
        _startQueue = nil;
    }
//    [_uploadingQueue removeAllObjects];
//    [_hashwaitingQueue removeAllObjects];
//    [_hashWorkingQueue removeAllObjects];
//    [_workingModel.hashWorkingQueue removeAllObjects];
//    [_hashwaitingNetQueue removeAllObjects];
    _isStoped = true;
    [self schedule];
    if (_reachabilityTimer) {
        [_reachabilityTimer invalidate];
        _reachabilityTimer = nil;
    }
   
}

- (void)destroy
{
    _isReady = false;
    _uploadingQueue = nil;
    _hashwaitingQueue = nil;
    _hashWorkingQueue = nil;
     _hashwaitingNetQueue = nil;
     _uploadErrorQueue = nil;
    _uploadedQueue = nil;
//    [_uploadingQueue removeAllObjects];
//    [_hashwaitingQueue removeAllObjects];
//    [_hashWorkingQueue removeAllObjects];
    [_workingModel.hashWorkingQueue removeAllObjects];
    _workingModel.hashWorkingQueue = nil;
//    [_hashwaitingNetQueue removeAllObjects];
//    [_uploadErrorQueue removeAllObjects];
//    [_uploadedQueue removeAllObjects];
}

- (void)reStart{
    if (_reachabilityTimer) {
        [_reachabilityTimer invalidate];
        _reachabilityTimer = nil;
    }
//    @weaky(self)
    [self destroy];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"uploadOverNoti" object:nil];
    [self start];
}

- (void)uplodingWithFilePath:(NSString *)filePath CompleteBlock:(void(^)(NSError *, NSString *))callback{
    __block NSString *hashString;
    [FMUploadFileAPI uploadDirEntryWithFilePath:filePath Name:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        hashString = [FileHash sha256HashOfFileAtPath:filePath];
        callback(nil,hashString);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        hashString = [FileHash sha256HashOfFileAtPath:filePath];
        callback(error,hashString);
    } otherFailure:^(NSString *null) {
        
    }];
}

- (void)hashWorkerWithFilePath:(NSString *)filePath CompleteBlock:(void(^)(NSError *, NSString *))callback
{
  
}

- (void)putUploadingQueue:(NSMutableArray<FMAsset *> *)uploadingQueue completeBlock:(void(^)(BOOL))callback{
    NSMutableArray * imageArr = [NSMutableArray arrayWithArray:uploadingQueue];
    for (FMAsset *asset  in uploadingQueue) {
        __block BOOL isExist = NO;
        //                    MyNSLog(@"%@",[NSDictionary superclass]);
        [imageArr enumerateObjectsUsingBlock:^(FMAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.sha256 isEqual:asset.sha256]) {//数组中已经存在该对象
                *stop = YES;
                isExist = YES;
            }
        }];
        if (!isExist) {//如果不存在就添加进去
            [imageArr addObject:asset];
        }
    }
    
    self.uploadingQueue = imageArr;
    _isReady = true;
    callback(YES);
 
    //    MyNSLog(@"%lu",(unsigned long)imageArr.count);
}

- (void)dealloc{
  
}

-(NSMutableArray<FMAsset *> *)hashwaitingQueue{
    if (!_hashwaitingQueue) {
        _hashwaitingQueue= [NSMutableArray arrayWithCapacity:0];
    }
    return _hashwaitingQueue;
}

- (NSMutableArray *)hashwaitingNetQueue{
    if (!_hashwaitingNetQueue) {
        _hashwaitingNetQueue= [NSMutableArray arrayWithCapacity:0];
    }
    return _hashwaitingNetQueue;
}

- (NSMutableArray<FMAsset *> *)uploadingQueue{
    if (!_uploadingQueue) {
        _uploadingQueue= [NSMutableArray<FMAsset *> arrayWithCapacity:0];
    }
    return _uploadingQueue;
}

- (NSMutableArray<FMAsset *> *)hashWorkingQueue{
    if (!_hashWorkingQueue) {
        _hashWorkingQueue= [NSMutableArray<FMAsset *> arrayWithCapacity:0];
    }
    return _hashWorkingQueue;
}

- (NSMutableArray<FMAsset *> *)uploadedQueue{
    if (!_uploadedQueue) {
        _uploadedQueue= [NSMutableArray<FMAsset *> arrayWithCapacity:0];
    }
    return _uploadedQueue;
}
@end

