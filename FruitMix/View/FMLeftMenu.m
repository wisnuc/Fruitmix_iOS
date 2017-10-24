//
//  FMLeftMenu.m
//  MenuDemo
//
//  Created by 杨勇 on 16/7/1.
//  Copyright © 2016年 Lying. All rights reserved.
//

#import "FMLeftMenu.h"
#import "FMLeftMenuCell.h"
#import "FMLeftUserCell.h"
#import "FMLeftUserFooterView.h"
#import "FMGetUserInfo.h"
#import "FMPhotoDataSource.h"
#import "FMUserLoginViewController.h"
#import "FMUploadFileAPI.h"

@interface FMLeftMenu ()<UITableViewDelegate,UITableViewDataSource>
{
    NSNumber *_allCount;
}
@property (weak, nonatomic) IBOutlet UILabel *versionLb;
@property (weak, nonatomic) IBOutlet UIButton *userBtn1;
@property (weak, nonatomic) IBOutlet UIButton *userBtn2;
@property (strong, nonatomic) FMUserLoginInfo *userInfo;
@property (strong, nonatomic) UIProgressView *backUpProgressView;
@property (strong, nonatomic) UILabel *progressLabel;
@end

@implementation FMLeftMenu

-(void)awakeFromNib{
   
    [super awakeFromNib];
    
//    self.userHeaderIV.layer.cornerRadius = self.userHeaderIV.frame.size.width/2;
//    self.userHeaderIV.backgroundColor = [UIColor blackColor];
    _settingTabelView.delegate = self;
    _settingTabelView.dataSource = self;
    
    _usersTableView.dataSource = self;
    _usersTableView.delegate = self;
    _isUserTableViewShow = NO;
    
    _settingTabelView.scrollEnabled = NO;
    _settingTabelView.tableFooterView = [UIView new];
    @weaky(self);
    _usersTableView.tableFooterView = [FMLeftUserFooterView footerViewWithTouchBlock:^{
        if(weak_self.delegate){
            [weak_self.delegate LeftMenuViewClickSettingTable:-1 andTitle:@"USER_FOOTERVIEW_CLICK"];
            [weak_self checkToStart];
        }
    }];

    _userBtn1.layer.cornerRadius = 20;
    _userBtn2.layer.cornerRadius = 20;
    
    self.userHeaderIV.userInteractionEnabled = YES;
    [self.userHeaderIV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeader:)]];
    
 
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    // app名称
////    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleName"];
//    // app版本
//    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//    self.versionLb.text = [NSString stringWithFormat:@"WISNUC %@",app_Version];

    _progressLabel = [[UILabel alloc]init];
    _progressLabel.text = @"         ";
    _progressLabel.textColor = [UIColor colorWithRed:236 green:236 blue:236 alpha:1];
    _progressLabel.font = [UIFont fontWithName:@"Hiragino Sans GB" size:12];
    _progressLabel.textAlignment = NSTextAlignmentRight;
    _progressLabel.preferredMaxLayoutWidth = (self.frame.size.width -10.0 * 2);
    [_progressLabel  setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self addSubview:_progressLabel];
    [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-16);
        make.centerY.equalTo(_backupLabel.mas_centerY);
        make.height.equalTo(@40);
    }];
    
     _backUpProgressView = [[UIProgressView alloc]init];
    [self addSubview:_backUpProgressView];
    [_backUpProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_backupLabel.mas_right).offset(6);
        make.height.equalTo(@2);
        make.centerY.equalTo(_backupLabel.mas_centerY);
        make.right.equalTo(_progressLabel.mas_left).offset(-6);
    }];

     [self getUserInfo];
    
    if (KISCLOUD) {
         self.nameLabel.text = _userInfo.userName;
        NSString *avatarUrl = KAVATARURL;
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:avatarUrl] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            self.userHeaderIV.image = [self imageCirclewithImage:image];
//            MyNSLog(@"%@",NSStringFromCGSize(image.size))  ;
        }];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/cn/lookup?id=1132191394"];
    [manager.requestSerializer setValue: [NSString stringWithFormat:@"JWT %@",DEF_Token] forHTTPHeaderField:@"Authorization"];
    [manager POST:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = responseObject[@"results"];
        NSDictionary *dict = [array lastObject];
        NSString *app_Version = dict[@"version"];
        self.versionLb.text = [NSString stringWithFormat:@"WISNUC %@",app_Version];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

    NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(receiveNotification:) name:@"backUpProgressChange" object:nil];
    [notiCenter addObserver:self selector:@selector(receiveNotificationForPhotoChange:) name:@"photoChange" object:nil];
    [notiCenter addObserver:self selector:@selector(receiveNotificationForUploadOverNoti:) name:@"uploadOverNoti" object:nil];
    [notiCenter addObserver:self selector:@selector(synchronizeStationPhoto) name:@"synchronizeStationPhoto" object:nil];


     dispatch_async(dispatch_get_main_queue(), ^{

         UILabel * progressLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, __kWidth, 15)];
         progressLb.font = [UIFont systemFontOfSize:12];
         progressLb.textAlignment = NSTextAlignmentCenter;
         dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             
         });
    self.nameLabel.font = [UIFont fontWithName:DONGQING size:14];
    if (KISCLOUD) {

    }
    else{
       
    }
  
     });
    
}

- (UIImage *)imageCirclewithImage:(UIImage *)image{
    UIImage *originImage = image;
    UIGraphicsBeginImageContext(originImage.size);
    UIBezierPath *path =[UIBezierPath bezierPathWithOvalInRect:CGRectMake( 0, 0, image.size.width, image.size.height)];
   
    [path addClip];

    [originImage drawAtPoint:CGPointZero];
    originImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    return originImage;
}

- (void)getAllPhoto{
    [self getAllPhotoCount];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
       
    }
    return self;
}

- (IBAction)smallBtnClick:(id)sender {
    if (sender == _userBtn1) {
        [self.delegate LeftMenuViewClickUserTable:self.usersDatasource[_userBtn2.hidden?0:1]];
    }else{
        [self.delegate LeftMenuViewClickUserTable:self.usersDatasource[0]];
    }
}

-(void)setUsersDatasource:(NSMutableArray *)usersDatasource{
    
    _usersDatasource = usersDatasource;
    if (usersDatasource.count) {
        if (usersDatasource.count == 1) { //等于1
            _userBtn1.hidden = NO;
            _userBtn2.hidden = YES;
            [_userBtn1 setBackgroundImage:[UIImage imageForName:((FMUserLoginInfo *)usersDatasource[0]).userName size:_userBtn1.bounds.size] forState:UIControlStateNormal];
        }else{ // 大于 1
            _userBtn1.hidden = NO;
            _userBtn2.hidden = NO;
            [_userBtn1 setBackgroundImage:[UIImage imageForName:((FMUserLoginInfo *)usersDatasource[1]).userName size:_userBtn1.bounds.size] forState:UIControlStateNormal];
            [_userBtn2 setBackgroundImage:[UIImage imageForName:((FMUserLoginInfo *)usersDatasource[0]).userName size:_userBtn2.bounds.size] forState:UIControlStateNormal];
        }
    }else{
        _userBtn1.hidden = YES;
        _userBtn2.hidden = YES;
    }
}

-(void)checkToStart{
    if (_isUserTableViewShow) {
        [self dropDownBtnClick:_dropDownBtn];
    }
}


- (IBAction)dropDownBtnClick:(id)sender {
    _isUserTableViewShow = !_isUserTableViewShow;
    @weaky(self);
    if (_isUserTableViewShow) {
        ((UIButton *)sender).transform = CGAffineTransformMakeRotation(M_PI);
        [UIView animateWithDuration:0.3 animations:^{
            weak_self.usersTableView.alpha = 1;
            weak_self.userBtn1.alpha = 0;
            weak_self.userBtn2.alpha = 0;
//            self.usersDatasource = [NSMutableArray arrayWithArray:[FMDBControl getAllUserLoginInfo]];
            [weak_self.usersTableView reloadData];
        } completion:nil];
    }else{
        ((UIButton *)sender).transform = CGAffineTransformIdentity;
        NSMutableArray * tempArr = self.menus;
        self.menus = [NSMutableArray new];
        [_settingTabelView reloadData];
        self.menus = tempArr;
        [UIView animateWithDuration:0.3 animations:^{
            weak_self.usersTableView.alpha = 0;
            [weak_self.settingTabelView reloadData];
            weak_self.userBtn1.alpha = 1;
            weak_self.userBtn2.alpha = 1;
        } completion:^(BOOL finished) {
            NSMutableArray * tmpA = weak_self.usersDatasource;
            weak_self.usersDatasource = [NSMutableArray new];
            [weak_self.usersTableView reloadData];
            weak_self.usersDatasource = tmpA;
        }];
    }
}

- (void)tapHeader:(id)sender {
//    if(self.delegate){
//        [self.delegate LeftMenuViewClick:10 andTitle:@"个人信息"];
//    }
}


- (void)getAllPhotoCount{
    @weaky(self)
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
    [weak_self siftPhotosWithBlock:^(NSMutableArray *uploadArray) {
//        [FMDBControl asyncLoadPhotoToDBWithCompleteBlock:^(NSArray *addArr) {
            [FMDBControl getDBAllLocalPhotosWithCompleteBlock:^(NSArray<FMLocalPhoto *> *result) {
                   NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
                   for (FMLocalPhoto * photo  in result) {
//                       MyNSLog(@"%@",photo.degist);
                       if (photo.degist.length >0) {
                         [array addObject:photo.degist];
                       }
//                    __block BOOL isExist = NO;
//                    [array enumerateObjectsUsingBlock:^(FMLocalPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                            if ([obj.degist isEqualToString:photo.degist]) {//数组中已经存在该对象
//                                *stop = YES;
//                                isExist = YES;
//                            }
//                      }];
//                        if (!isExist) {//如果不存在就添加进去
//    
//                           [array addObject:photo];
//                       }
                    }
//

                NSSet *localPhotoHashArrSet = [NSSet setWithArray:array];
                NSMutableArray * arr = [NSMutableArray arrayWithArray:[localPhotoHashArrSet allObjects]];
                    NSNumber *number = [NSNumber numberWithUnsignedInteger:arr.count];
                    if (number) {
                        _allCount = number;
                    }else{
                        _allCount = @0;
                    }
                    NSMutableArray *uploadImageArr = [NSMutableArray arrayWithCapacity:0];
                    uploadImageArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"uploadImageArr"];
                    NSNumber *alreadyCountNumber = [NSNumber numberWithInt:0];
            
//                    NSNumber *addCountNumber = [[NSUserDefaults standardUserDefaults]objectForKey:@"addCount"];
//                    if (addCountNumber==nil) {
                    alreadyCountNumber = [NSNumber numberWithUnsignedInteger:uploadImageArr.count];
//                    }else{
//                        alreadyCountNumber = addCountNumber;
//                    }
                    float progress = [alreadyCountNumber floatValue]/[_allCount floatValue];
                    NSDecimalNumber *progressDecimalNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",[self notRounding:progress afterPoint:2]]];
                    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithString:@"100"];
                    NSDecimalNumber *mutiplyDecimal;
                    if ([progressDecimalNumber compare:[NSDecimalNumber zero]] == NSOrderedSame || [[NSDecimalNumber notANumber] isEqualToNumber:progressDecimalNumber]) {
                        mutiplyDecimal = [NSDecimalNumber zero];
                    }else{
                        mutiplyDecimal = [progressDecimalNumber decimalNumberByMultiplyingBy:decimalNumber];
                    }
                    if ([NSThread isMainThread] ) {
//                        if ([alreadyCountNumber unsignedIntegerValue]/[_allCount unsignedIntegerValue]>=1) {
//                            self.backUpProgressView.progress = 1;
//                            self.backupLabel.text = [NSString stringWithFormat:@"已备份100%%"];
//                            self.progressLabel.text = [NSString stringWithFormat:@"%@/%@",_allCount,_allCount];
//                        }else{
                            self.backupLabel.text = [NSString stringWithFormat:@"已备份%@%%",mutiplyDecimal];
                            self.backUpProgressView.progress = progress;
                            //                        NSNumber * number = [NSNumber numberWithUnsignedInteger:uploadImageArr.count];
                            self.progressLabel.text = [NSString stringWithFormat:@"%@/%@",alreadyCountNumber,_allCount];
//                        }
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
//                            if ([alreadyCountNumber unsignedIntegerValue]/[_allCount unsignedIntegerValue]>=1) {
//                                self.backUpProgressView.progress = 1;
//                                self.backupLabel.text = [NSString stringWithFormat:@"已备份100%%"];
//                                self.progressLabel.text = [NSString stringWithFormat:@"%@/%@",_allCount,_allCount];
//                            }else{
                                self.backupLabel.text = [NSString stringWithFormat:@"已备份%@%%",mutiplyDecimal];
                                self.backUpProgressView.progress = progress;
                                //                            NSNumber * number = [NSNumber numberWithUnsignedInteger:uploadImageArr.count];
                                self.progressLabel.text = [NSString stringWithFormat:@"%@/%@",alreadyCountNumber,_allCount];
//                            }
                        });
                    }
                    MyNSLog(@"已上传：%@/本地照片总数:%@",self.progressLabel.text,_allCount);
            }];
        }];
//    }];
});
}

- (void)getAllPhotoCountWithBlock:(void(^)(NSNumber * allCount))block{
    [FMDBControl getDBAllLocalPhotosWithCompleteBlock:^(NSArray<FMLocalPhoto *> *result) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        for (FMLocalPhoto * photo  in result) {
            if (photo.degist.length>0) {
                [array addObject:photo.degist];
            }
//            __block BOOL isExist = NO;
//            [array enumerateObjectsUsingBlock:^(FMLocalPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                if ([obj.degist isEqualToString:photo.degist]) {//数组中已经存在该对象
//                    *stop = YES;
//                    isExist = YES;
//                }
//            }];
//            if (!isExist) {//如果不存在就添加进去
//                [array addObject:photo];
//            }
        }
        
        NSSet *localPhotoHashArrSet = [NSSet setWithArray:array];
        NSMutableArray * arr = [NSMutableArray arrayWithArray:[localPhotoHashArrSet allObjects]];
        MyNSLog(@"%lu",(unsigned long)arr.count)
        //        NSMutableArray * tmp = [NSMutableArray arrayWithCapacity:0];
        //        NSMutableArray *localPhotoHashArr = [NSMutableArray arrayWithCapacity:0];
        //        for (FMLocalPhoto * p in result) {
        //            [tmp addObject:p.localIdentifier];
        //            if(p.degist.length >0){
        //                [localPhotoHashArr addObject:p.degist];
        //            }
        //        }
        //        NSSet *localPhotoHashArrSet = [NSSet setWithArray:localPhotoHashArr];
        //        NSMutableArray * arr = [NSMutableArray arrayWithArray:[localPhotoHashArrSet allObjects]];
        NSNumber *number = [NSNumber numberWithUnsignedInteger:arr.count];
        if (number !=nil) {
            _allCount = number;
            block(number);
        }else{
            _allCount = @0;
        }
     
    }];
}

- (void)siftPhotosWithBlock:(void(^)(NSMutableArray *uploadArray))completeBlock{
    @weaky(self)
    NSString *entryuuid = PHOTO_ENTRY_UUID;
    if (entryuuid ==0) {
        __block BOOL sift = YES;
        [FMUploadFileAPI getDriveInfoCompleteBlock:^(BOOL successful) {
            if (successful) {
                [FMUploadFileAPI getDirectoriesForPhotoCompleteBlock:^(BOOL successful) {
                    if (successful) {
                        [FMUploadFileAPI creatPhotoDirEntryCompleteBlock:^(BOOL successful) {
                            if (successful) {
                                NSString *entryuuid = PHOTO_ENTRY_UUID;
                                [FMUploadFileAPI getDirEntryWithUUId:entryuuid success:^(NSURLSessionDataTask *task, id responseObject) {
                                    if (sift) {
                                    NSArray * arr ;
                                    if (!KISCLOUD) {
                                        NSDictionary * dic =  responseObject;
                                        arr = dic[@"entries"];
                                    }else {
                                        NSDictionary * dic =  responseObject;
                                        NSDictionary * entriesDic = dic[@"data"];
                                        arr = entriesDic[@"entries"];
                                    }
                                    NSMutableArray * photoArrHash = [NSMutableArray arrayWithCapacity:0];
                                    
                                    for (NSDictionary *dic in arr) {
                                        FMNASPhoto *nasPhoto = [FMNASPhoto yy_modelWithJSON:dic];
                                        [photoArrHash addObject:nasPhoto.fmhash];
                                    }
//                                    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                        [FMDBControl getDBAllLocalPhotosWithCompleteBlock:^(NSArray<FMLocalPhoto *> *result) {
                                            NSMutableArray *localPhotoHashArr = [NSMutableArray arrayWithCapacity:0];
                                            for (FMLocalPhoto * p in result) {
                                                if (p.degist.length >0) {
                                                    [localPhotoHashArr addObject:p.degist];
                                                }
                                            }
                                            //                MyNSLog(@"%u",localPhotoHashArr.count);
                                            NSSet *photoArrHashSet = [NSSet setWithArray:photoArrHash];
                                            NSSet *localPhotoHashArrSet = [NSSet setWithArray:localPhotoHashArr];
                                            
                                            NSPredicate * filterPredicate_same = [NSPredicate predicateWithFormat:@"SELF IN %@",[localPhotoHashArrSet allObjects]];
                                            NSArray * filter_no = [[photoArrHashSet allObjects] filteredArrayUsingPredicate:filterPredicate_same];
                                            NSMutableArray * siftPhotoArrHash  = [NSMutableArray arrayWithCapacity:0];
                                            [siftPhotoArrHash addObjectsFromArray:filter_no];
                                            //            NSLog(@"😜😜😜😜😜%ld",(long)filter_no.count);
                                            [[NSUserDefaults standardUserDefaults] setObject:siftPhotoArrHash forKey:@"uploadImageArr"];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                            if (siftPhotoArrHash) {
                                                completeBlock(siftPhotoArrHash);
                                                sift = NO;
                                            }
                                            MyNSLog(@"请求NAS 照片返回%@",responseObject);
                                            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"siftPhoto" object:nil];
                                            //            [[NSNotificationCenter defaultCenter] postNotificationName:@"siftPhotoForLeftMenu" object:nil];
                                        }];
                                    }
//                                    });
                                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                    NSHTTPURLResponse * rep = (NSHTTPURLResponse *)task.response;
                                    MyNSLog(@"%ld",(long)rep.statusCode);
                                    if (rep.statusCode &&rep.statusCode== 404) {
                                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PHOTO_ENTRY_UUID_STR];
                                        if ([NSThread isMainThread]) {
                                          [weak_self performSelector:@selector(siftPhotosWithBlock:) withObject:completeBlock];
                                        }else{
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                             [weak_self performSelector:@selector(siftPhotosWithBlock:) withObject:completeBlock];
                                        });
                                        }
                                    }
                                }];
                            }
                        }];
                    }
                }];
            }
        }];
    }else{
    [FMUploadFileAPI getDirEntryWithUUId:entryuuid success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray * arr ;
        if (!KISCLOUD) {
            NSDictionary * dic =  responseObject;
            arr = dic[@"entries"];
        }else {
            NSDictionary * dic =  responseObject;
            NSDictionary * entriesDic = dic[@"data"];
            arr = entriesDic[@"entries"];
        }
        NSMutableArray * photoArrHash = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *dic in arr) {
            FMNASPhoto *nasPhoto = [FMNASPhoto yy_modelWithJSON:dic];
            [photoArrHash addObject:nasPhoto.fmhash];
        }
//        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            [FMDBControl getDBAllLocalPhotosWithCompleteBlock:^(NSArray<FMLocalPhoto *> *result) {
                NSMutableArray *localPhotoHashArr = [NSMutableArray arrayWithCapacity:0];
                for (FMLocalPhoto * p in result) {
                    if (p.degist.length >0) {
                        [localPhotoHashArr addObject:p.degist];
                    }
                }
                MyNSLog(@"%u",localPhotoHashArr.count);
                NSSet *photoArrHashSet = [NSSet setWithArray:photoArrHash];
                NSSet *localPhotoHashArrSet = [NSSet setWithArray:localPhotoHashArr];
                
                NSPredicate * filterPredicate_same = [NSPredicate predicateWithFormat:@"SELF IN %@",[localPhotoHashArrSet allObjects]];
                NSArray * filter_no = [[photoArrHashSet allObjects] filteredArrayUsingPredicate:filterPredicate_same];
                NSMutableArray * siftPhotoArrHash  = [NSMutableArray arrayWithCapacity:0];
                [siftPhotoArrHash addObjectsFromArray:filter_no];
                //            NSLog(@"😜😜😜😜😜%ld",(long)filter_no.count);
                [[NSUserDefaults standardUserDefaults] setObject:siftPhotoArrHash forKey:@"uploadImageArr"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (siftPhotoArrHash) {
                    completeBlock(siftPhotoArrHash);
                }
                MyNSLog(@"请求NAS 照片返回%@",responseObject);
            }];
//        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSHTTPURLResponse * rep = (NSHTTPURLResponse *)task.response;
        NSLog(@"%ld",(long)rep.statusCode);
        if (rep.statusCode == 404) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:PHOTO_ENTRY_UUID_STR];
            if ([NSThread isMainThread]) {
                [weak_self performSelector:@selector(siftPhotosWithBlock:) withObject:completeBlock];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weak_self performSelector:@selector(siftPhotosWithBlock:) withObject:completeBlock];
                });
            }
          }
        }];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self getUserInfo];
     self.bonjourLabel.text = _userInfo.bonjour_name;
    if (!KISCLOUD) {
        self.nameLabel.text = [FMConfigInstance getUserNameWithUUID:DEF_UUID];
        self.userHeaderIV.image = [UIImage imageForName:self.nameLabel.text size:self.userHeaderIV.bounds.size];
    }
//    [cell.contentView addSubview:progressLb];
//    progressLb.hidden = !_displayProgress;

}
-(NSString *)notRounding:(float)price afterPoint:(int)position{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
//    [ouncesDecimal release];
    return [NSString stringWithFormat:@"%@",roundedOunces];
}
//static NSInteger overCount = 0;
- (void)receiveNotification:(NSNotification *)noti{
    @weaky(self)
//    if (_allCount == nil) {
        [self getAllPhotoCountWithBlock:^(NSNumber *allCount) {
            if (allCount!=nil) {
                [weak_self asyncPhoto];
            }
        }];
//        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0/*延迟执行时间*/ * NSEC_PER_SEC));
//        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
//                    });
//    }else{
//        [weak_self asyncPhoto];
//    }
    
}

- (void)asyncPhoto{
    NSMutableArray *uploadImageArr = [NSMutableArray array];
    uploadImageArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"uploadImageArr"];
    NSNumber *alreadyCountNumber;
    NSNumber *addCountNumber = [[NSUserDefaults standardUserDefaults]objectForKey:@"addCount"];
    if (addCountNumber==nil) {
        alreadyCountNumber = [NSNumber numberWithUnsignedInteger:uploadImageArr.count];
    }else{
        alreadyCountNumber = addCountNumber;
    }
    float progress = [alreadyCountNumber floatValue]/[_allCount floatValue];
    NSDecimalNumber *progressDecimalNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",[self notRounding:progress afterPoint:2]]];
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithString:@"100"];
    
    NSDecimalNumber *mutiplyDecimal;
    if ([progressDecimalNumber compare:[NSDecimalNumber zero]] == NSOrderedSame || [[NSDecimalNumber notANumber] isEqualToNumber:progressDecimalNumber]) {
        mutiplyDecimal = [NSDecimalNumber zero];
    }else{
        mutiplyDecimal = [progressDecimalNumber decimalNumberByMultiplyingBy:decimalNumber];
    }
//      MyNSLog(@"线程：%@",[NSThread currentThread]);
    if ([NSThread isMainThread] ) {
//        if ([alreadyCountNumber unsignedIntegerValue]/[_allCount unsignedIntegerValue]>=1) {
//            self.backUpProgressView.progress = 1;
//            self.backupLabel.text = [NSString stringWithFormat:@"已备份100%%"];
//            self.progressLabel.text = [NSString stringWithFormat:@"%@/%@",_allCount,_allCount];
//        }else{
            self.backupLabel.text = [NSString stringWithFormat:@"已备份%@%%",mutiplyDecimal];
            self.backUpProgressView.progress = progress;
            //                NSNumber * number = [NSNumber numberWithUnsignedInteger:uploadImageArr.count];
            self.progressLabel.text = [NSString stringWithFormat:@"%@/%@",alreadyCountNumber,_allCount];
//        }
//
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([alreadyCountNumber unsignedIntegerValue]/[_allCount unsignedIntegerValue]>=1) {
//                self.backUpProgressView.progress = 1;
//                self.backupLabel.text = [NSString stringWithFormat:@"已备份100%%"];
//                self.progressLabel.text = [NSString stringWithFormat:@"%@/%@",_allCount,_allCount];
//            }else{
                self.backupLabel.text = [NSString stringWithFormat:@"已备份%@%%",mutiplyDecimal];
                self.backUpProgressView.progress = progress;
                //                NSNumber * number = [NSNumber numberWithUnsignedInteger:uploadImageArr.count];
                
                self.progressLabel.text = [NSString stringWithFormat:@"%@/%@",alreadyCountNumber,_allCount];
//            }
        });
  
    }
       MyNSLog(@"已上传：%@/本地照片总数:%@",self.progressLabel.text,_allCount);
}

- (void)receiveNotificationForPhotoChange:(NSNotification *)noti{
    [self receiveNotification:nil];
}

- (void)receiveNotificationForUploadOverNoti:(NSNotification *)noti{
    [self getAllPhotoCountWithBlock:^(NSNumber *allCount) {
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1/*延迟执行时间*/ * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [self overUploadAction];
        });
    }];
//      [FMUserLoginViewController siftPhotoFromNetwork];
   
//    [self synchronizeStationPhoto];
}

- (void)overUploadAction{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSMutableArray *uploadImageArr = [NSMutableArray array];
//            uploadImageArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"uploadImageArr"];
              NSNumber *addCountNumber = [[NSUserDefaults standardUserDefaults]valueForKey: @"addCount"];
                float progress = [addCountNumber floatValue]/[_allCount floatValue];
                //                 NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
                NSDecimalNumber *progressDecimalNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",[self notRounding:progress afterPoint:2]]];
                NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithString:@"100"];
        
                NSDecimalNumber *mutiplyDecimal;
                if ([progressDecimalNumber compare:[NSDecimalNumber zero]] == NSOrderedSame || [[NSDecimalNumber notANumber] isEqualToNumber:progressDecimalNumber]) {
                    mutiplyDecimal = [NSDecimalNumber zero];
                }else{
                    mutiplyDecimal = [progressDecimalNumber decimalNumberByMultiplyingBy:decimalNumber];
                }
//               overCount ++;
//                MyNSLog(@"%d",overCount);
                if ([NSThread isMainThread] ) {
//                    if ([addCountNumber integerValue]/[_allCount unsignedIntegerValue]>=1) {
//                        self.backUpProgressView.progress = 1;
//                        self.backupLabel.text = [NSString stringWithFormat:@"已备份100%%"];
//                        self.progressLabel.text = [NSString stringWithFormat:@"%@/%@",_allCount,_allCount];
////                        if ([PhotoManager shareManager].canUpload) {
////                            [PhotoManager shareManager].canUpload = NO;
////                            [[PhotoManager shareManager].uploadarray removeAllObjects];
////                            [PhotoManager shareManager].canUpload = YES;
////                        }
//                    }else{
                        self.backupLabel.text = [NSString stringWithFormat:@"已备份%@%%",mutiplyDecimal];
                        self.backUpProgressView.progress = progress;
//                        NSNumber * number = [NSNumber numberWithInteger:[addCountNumber integerValue]];
                        self.progressLabel.text = [NSString stringWithFormat:@"%@/%@",addCountNumber,_allCount];
//                    }
                      MyNSLog(@"已上传：%@/本地照片总数:%@",self.progressLabel.text,_allCount);
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if ([addCountNumber integerValue]/[_allCount unsignedIntegerValue]>=1) {
//                            self.backUpProgressView.progress = 1;
//                            self.backupLabel.text = [NSString stringWithFormat:@"已备份100%%"];
//                            self.progressLabel.text = [NSString stringWithFormat:@"%@/%@",_allCount,_allCount];
////                            if ([PhotoManager shareManager].canUpload) {
////                                [PhotoManager shareManager].canUpload = NO;
////                                [[PhotoManager shareManager].uploadarray removeAllObjects];
////                                [PhotoManager shareManager].canUpload = YES;
////                            }
//                        }else{
                            self.backupLabel.text = [NSString stringWithFormat:@"已备份%@%%",mutiplyDecimal];
                            self.backUpProgressView.progress = progress;
//                            NSNumber * number = [[NSNumber numberWithInteger:[addCountNumber integerValue] ];

                            self.progressLabel.text = [NSString stringWithFormat:@"%@/%@",addCountNumber,_allCount];
//                        }
                          MyNSLog(@"已上传：%@/本地照片总数:%@",self.progressLabel.text,_allCount);
                    });
                }
    });

}


- (void)synchronizeStationPhoto{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [FMDBControl getDBAllLocalPhotosWithCompleteBlock:^(NSArray<FMLocalPhoto *> *result) {
            NSSet *localPhotoHashSetArr = [NSSet setWithArray:result];
            NSMutableArray * arr = [NSMutableArray arrayWithArray:[localPhotoHashSetArr allObjects]];
//            MyNSLog(@"%lu",(unsigned long)arr.count);
            _allCount = [NSNumber numberWithUnsignedInteger:arr.count];
            NSMutableArray * tmp = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *localPhotoHashArr = [NSMutableArray arrayWithCapacity:0];
            for (FMLocalPhoto * p in result) {
                [tmp addObject:p.localIdentifier];
                if(p.degist.length >0){
                    [localPhotoHashArr addObject:p.degist];
                }
            }
            NSSet *localPhotoHashArrSet = [NSSet setWithArray:localPhotoHashArr];
            NSMutableArray *uploadImageArr = [NSMutableArray array];
            uploadImageArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"uploadImageArr"];
            NSInteger allPhotos = [localPhotoHashArrSet allObjects].count;
            FMDBSet * dbSet = [FMDBSet shared];
            FMDTSelectCommand * scmd  = FMDT_SELECT(dbSet.syncLogs);
            [scmd where:@"userId" equalTo:DEF_UUID];
            [scmd where:@"localId" containedIn:tmp];
            [scmd fetchArrayInBackground:^(NSArray *results) {
                float progress = (float)uploadImageArr.count/(float)allPhotos;
                //                 NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown scale:0 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
                NSDecimalNumber *progressDecimalNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",[self notRounding:progress afterPoint:2]]];
                NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithString:@"100"];
                
                NSDecimalNumber *mutiplyDecimal;
                if ([progressDecimalNumber compare:[NSDecimalNumber zero]] == NSOrderedSame || [[NSDecimalNumber notANumber] isEqualToNumber:progressDecimalNumber]) {
                    mutiplyDecimal = [NSDecimalNumber zero];
                }else{
                    mutiplyDecimal = [progressDecimalNumber decimalNumberByMultiplyingBy:decimalNumber];
                }
                if ([NSThread isMainThread] ) {
                    if ((NSInteger)uploadImageArr.count/allPhotos>=1) {
                        self.backUpProgressView.progress = 1;
                        self.backupLabel.text = [NSString stringWithFormat:@"已备份100%%"];
                        self.progressLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)allPhotos,(long)allPhotos];
                    }else{
                        self.backupLabel.text = [NSString stringWithFormat:@"已备份%@%%",mutiplyDecimal];
                        self.backUpProgressView.progress = progress;
                        
                        self.progressLabel.text = [NSString stringWithFormat:@"%ld/%ld",(unsigned long)uploadImageArr.count,(long)allPhotos];
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ((NSInteger)uploadImageArr.count/allPhotos>=1) {
                            self.backUpProgressView.progress = 1;
                            self.backupLabel.text = [NSString stringWithFormat:@"已备份100%%"];
                            self.progressLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)allPhotos,(long)allPhotos];
                            if ([PhotoManager shareManager].canUpload) {
                                [PhotoManager shareManager].canUpload = NO;
                                [[PhotoManager shareManager].uploadarray removeAllObjects];
                                [PhotoManager shareManager].canUpload = YES;
                            }
                        }else{
                            self.backupLabel.text = [NSString stringWithFormat:@"已备份%@%%",mutiplyDecimal];
                            self.backUpProgressView.progress = progress;
                            
                            self.progressLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)uploadImageArr.count,(long)allPhotos];
                        }
                    });
                }
                MyNSLog(@"已上传：%ld/本地照片总数:%ld",(long)uploadImageArr.count,(long)allPhotos);
            }];
            
        }];
    });
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(tableView == _settingTabelView)
        return 2;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == _settingTabelView){
        if (section == 0) {
            return 1;
        }
        return self.menus.count - 1;
    }else
        return self.usersDatasource.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _settingTabelView) {
        FMLeftMenuCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FMLeftMenuCell" owner:nil options:nil] lastObject];
        if (indexPath.section == 0) {
            cell.leftLine.backgroundColor = [UIColor blackColor];
            [cell setData:_menus[indexPath.row] andImageName:_imageNames[indexPath.row]];
        }else{
            [cell setData:_menus[indexPath.row + 1] andImageName:_imageNames[indexPath.row + 1]];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else{
        FMLeftUserCell * cell =  [[[NSBundle mainBundle] loadNibNamed:@"FMLeftUserCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        FMUserLoginInfo * info =  self.usersDatasource[indexPath.row];
        cell.userNameLb.text = info.userName;
        cell.deviceNameLb.text = info.bonjour_name;
        cell.userHeader.image = [UIImage imageForName:info.userName size:cell.userHeader.bounds.size];
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == _settingTabelView){
        if(self.delegate){
            [self.delegate LeftMenuViewClickSettingTable:indexPath.section == 0? indexPath.row:indexPath.row+1 andTitle:indexPath.section == 0? self.menus[indexPath.row]:self.menus[indexPath.row+1]];
        }
    }else{
        if(self.delegate){
            [self.delegate LeftMenuViewClickUserTable:self.usersDatasource[indexPath.row]];
            [self checkToStart];
        }
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 8;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == _settingTabelView){
        if(indexPath.section == 0 )
            return 72;
        return  [FMLeftMenuCell height];
    }else{
        return [FMLeftUserCell height];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    double delay = (indexPath.row*indexPath.row) * 0.004;  //Quadratic time function for progressive delay
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.95, 0.95);
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(0,(tableView == _settingTabelView?1:-1)*(indexPath.row+1)*CGRectGetHeight(cell.contentView.frame));
    cell.transform = CGAffineTransformConcat(scaleTransform, translationTransform);
    cell.alpha = 0.f;
    
    [UIView animateWithDuration:0.6/2 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         cell.transform = CGAffineTransformIdentity;
         cell.alpha = 1.f;
         
     } completion:nil];
}

- (void)getUserInfo{
    MyNSLog(@"%@",DEF_UUID);
  _userInfo = [FMDBControl findUserLoginInfo:DEF_UUID];
//    NSMutableArray * arr = [FMGetUserInfo getUsersInfo];
//    for (FMUserLoginInfo * info in arr) {
//        _userInfo = info;
//        NSLog(@"%@",_userInfo);
//    }
}

- (void)dealloc
{
    // 移除当前对象监听的事件
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UILabel *)backupLabel{
    if (!_backupLabel) {
        
    }
    return _backupLabel;
}


@end
