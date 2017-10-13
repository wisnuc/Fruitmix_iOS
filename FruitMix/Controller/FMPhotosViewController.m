//
//  FMPhotosViewController.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/5.
//  Copyright © 2016年 WinSun. All rights reserved.
//
//#import "CocoaSecurity.h"
//#import "FileHash.h"
//#import "NSString+JYImageType.h"
//#import "SDImageCache.h"


#import "FMPhotosViewController.h"
#import "FMPhotosCollectionViewCell.h"
#import "FMHeadView.h"
#import "IDMPhotoBrowser.h"
#import "UIScrollView+IndicatorExt.h"
#import "FMPhotoAsset.h"


#import "FMAlbumNamedController.h"
#import "UIViewController+JYControllerTools.h"

#import "VCFloatingActionButton.h"
#import "JYProcessView.h"

#import "FMPhotoDataSource.h"

#import "LCActionSheet.h"
#import "JYAlertView.h"
#import "FMPersonsCell.h"
#import "FMPersonCell.h"


#import "FMUploadFileAPI.h"

@interface FMPhotoDownloadHelper : NSObject

+(instancetype)defaultHelper;

@property (nonatomic ,copy) void (^downloadCompleteBlock)(BOOL success,UIImage * image);

@end

@implementation FMPhotoDownloadHelper

+(instancetype)defaultHelper{
    static FMPhotoDownloadHelper * helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [FMPhotoDownloadHelper new];
    });
    return helper;
}

@end


@interface FMPhotosViewController ()<FMPhotoCollectionViewDelegate,FMPhotosCollectionViewCellDelegate,FMHeadViewDelegate,IDMPhotoBrowserDelegate,floatMenuDelegate,FMPhotoDataSourceDelegate,LCActionSheetDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) FMPhotoCollectionView * collectionView;

@property (nonatomic) UIButton * photoLeftbtn;

@property (nonatomic) UIView * chooseHeadView;

//选择的照片的indexPath
@property (nonatomic) NSMutableArray * choosePhotos;

//选择了整组
@property (nonatomic) NSMutableArray * chooseSection;

@property (strong, nonatomic) VCFloatingActionButton * addButton;

@property (nonatomic ,weak ) FMPhotoDataSource * photoDataSource;

@property (nonatomic) JYProcessView * pv;

@property (nonatomic) BOOL shouldDownload;

@property (nonatomic) JYAlertView * shareView;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgeGesture;

@property (nonatomic, strong) NSMutableDictionary *cellIdentifierDic;
@end

@implementation FMPhotosViewController{
    UIButton * _leftBtn;//导航栏左边按钮
    UIButton * _rightbtn;//导航栏右边按钮
    UILabel * _countLb;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
//    [self siftPhotos];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.collectionView.fmState == FMPhotosCollectionViewCellStateNormal) {
        [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
        if (_edgeGesture) {
            [self.view removeGestureRecognizer:_edgeGesture];
            _edgeGesture = nil;
        }
    }else{
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
//    UILabel * titleLb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
//    titleLb.textAlignment = NSTextAlignmentCenter;
//    titleLb.font = [UIFont fontWithName:FANGZHENG size:18];
//    titleLb.textColor = UICOLOR_RGB(0xffffff);
//    titleLb.text = self.title;
//    self.navigationItem.titleView = titleLb;
//    [self startLoading];
    [self initView];      
    [self initData];
    [self registNotify];
    [self initMjRefresh];
//    [self asynAnyThings];

}

- (void)startLoading{
    [SXLoadingView showProgressHUD:@"加载中..."];
}

- (void)initMjRefresh{
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf refreshPhoto];
    }];
    self.collectionView.mj_header.ignoredScrollViewContentInsetTop = 8;
    // 马上进入刷新状态
//    [self.collectionView.mj_header beginRefreshing];
}

-(void)gesture:(id)sender
{
    UIScreenEdgePanGestureRecognizer *edge = sender;
   if (self.collectionView.fmState == FMPhotosCollectionViewCellStateCanChoose) {
    if (edge.edges == UIRectEdgeLeft)
    {
        [self leftBtnClick:nil];
    }
   }
}
-(void)registNotify{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataSourceFinishToLoadPhotos) name:FMPhotoDatasourceLoadFinishNotify object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initData{
    self.choosePhotos = [NSMutableArray arrayWithCapacity:0];
    self.chooseSection = [NSMutableArray arrayWithCapacity:0];
    self.photoDataSource = [FMPhotoDataSource shareInstance];
    
    if (_photoDataSource.isFinishLoading) {
        [self.collectionView reloadData];
   
    }
}

-(void)refreshPhoto{
    [_photoDataSource initPhotos];
    [SXLoadingView hideProgressHUD];
}

-(void)initView{
    self.view.backgroundColor = UICOLOR_RGB(0xe2e2e2);
    self.collectionView = [[FMPhotoCollectionView alloc]init];
  
    self.collectionView.fmDelegate = self;
    self.collectionView.userIndicator = YES;
    [self.view addSubview:self.collectionView];
    self.collectionView.fmState = FMPhotosCollectionViewCellStateNormal;
    [self.collectionView registerNib:[UINib nibWithNibName:@"FMPhotosCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"photocell"];
    [self addRightBtn];
    [self createControlbtn];
    [self addPinchGesture];
    [self updateFrame];
  
}

-(void)updateFrame{
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right);
        make.left.mas_equalTo(self.view.mas_left);
        make.top.mas_equalTo(self.view.mas_top);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    
      self.collectionView.contentInset = UIEdgeInsetsMake(FMDefaultOffset, 0, 0, 0);
}

-(void)createControlbtn{
    if(!_addButton){
         CGRect floatFrame = CGRectMake(self.view.jy_Width-80 , __kHeight - 64 - 56 - 88, 56, 56);
        NSLog(@"%f",self.view.jy_Width);
        _addButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"add_album"] andPressedImage:[UIImage imageNamed:@"icon_close"] withScrollview:_collectionView];
        _addButton.automaticallyInsets = YES;
        _addButton.imageArray = @[@"fab_share"];
        _addButton.labelArray = @[@""];
        _addButton.delegate = self;
        _addButton.hidden = YES;
        [self.view addSubview:_addButton];
    }
}

- (void)siftPhotos{
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
            [[NSUserDefaults standardUserDefaults]  synchronize];
        }];
        
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
                                    [self siftPhotos];
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

//增加捏合手势
-(void)addPinchGesture{
    UIPinchGestureRecognizer * pin = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinch:)];
    [self.collectionView addGestureRecognizer:pin];
}

//添加 导航器右边按钮
-(void)addRightBtn{
    
    
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"more_highlight"] forState:UIControlStateHighlighted];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,rightItem,nil];

//    UIBarButtonItem *negativeSpacer = [[ UIBarButtonItem alloc ]
//                                       
//                                       initWithBarButtonSystemItem : UIBarButtonSystemItemFixedSpace
//                                       
//                                       target : nil action : nil ];
    
//    negativeSpacer. width = -8;
//    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 48, 48)];
//    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    [rightBtn setTitle:@"选择" forState:UIControlStateNormal];
//    rightBtn.titleLabel.font = [UIFont fontWithName:FANGZHENG size:16];
//    rightBtn.titleLabel.textColor = UICOLOR_RGB(0xffffff);
//    _rightbtn = rightBtn;
//    self.navigationItem.rightBarButtonItems = @[negativeSpacer,[[UIBarButtonItem alloc]initWithCustomView:rightBtn]];
}

//添加 可选视图 左边按钮
-(void)addLeftBtn{
    if (!_chooseHeadView) {
        _chooseHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, -64, __kWidth, 64)];
        _chooseHeadView.backgroundColor = UICOLOR_RGB(0x03a9f4);
        UIButton * leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 16, 48, 48 )];
        UIImage * backImage = [UIImage imageNamed:@"back"];
//        UIImage * backHighlightImage = [UIImage imageNamed:@"back_grayhighlight"];
//        [backImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 1, 1) resizingMode:UIImageResizingModeStretch];
        [leftBtn setImage:backImage forState:UIControlStateNormal];
//        [leftBtn setImage:backHighlightImage forState:UIControlStateHighlighted];
        [leftBtn addTarget:self action:@selector(leftBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _leftBtn = leftBtn;
        
        UILabel * countLb = [[UILabel alloc]initWithFrame:CGRectMake(__kWidth/2 - 50, 27, 100, 30)];
        countLb.textColor = [UIColor whiteColor];
        countLb.font = [UIFont fontWithName:Helvetica size:17];
        countLb.textAlignment = NSTextAlignmentCenter;
        _countLb = countLb;
        [_chooseHeadView addSubview:countLb];
        [_chooseHeadView addSubview:leftBtn];
        [self.navigationController.view addSubview:_chooseHeadView];
    }
//    _countLb.text = @"选择照片";
    _countLb.font = [UIFont fontWithName:FANGZHENG size:16];
    [UIView animateWithDuration:0.5 animations:^{
        _chooseHeadView.transform = CGAffineTransformTranslate(_chooseHeadView.transform, 0, 64);
    }];
    [self tabBarAnimationWithHidden:YES];
    self.collectionView.frame = self.collectionView.frame;
}

//tabbar 动画
-(void)tabBarAnimationWithHidden:(BOOL)hidden{
    RDVTabBarController * tabBar = self.rdv_tabBarController;
    if (hidden) {
        CGPoint point = self.collectionView.contentOffset;
        [self.collectionView setContentOffset:point animated:NO];
        //重置把手位置
         [tabBar setTabBarHidden:YES animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.collectionView.frame = self.collectionView.frame;
        });
    }else{
        [tabBar setTabBarHidden:NO animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGPoint point = self.collectionView.contentOffset;
            [self.collectionView setContentOffset:point animated:NO];
            //重置把手位置
           self.collectionView.frame = self.collectionView.frame;
        });
    }
}


#pragma mark - handle

-(void)rightBtnClick:(id)sender{
    LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:nil
                                                             delegate:nil
                                                    cancelButtonTitle:@"取消"
                                                otherButtonTitleArray:@[@"选择照片"]];
    actionSheet.clickedHandle = ^(LCActionSheet *actionSheet, NSInteger buttonIndex){
        if (buttonIndex == 1) {
            self.collectionView.mj_header.hidden = YES;
            self.collectionView.fmState = FMPhotosCollectionViewCellStateCanChoose;
            [self.collectionView reloadData];
            _rightbtn.userInteractionEnabled = NO;
            [self addLeftBtn];
            _addButton.hidden = NO;
            if (!_edgeGesture) {
                _edgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(gesture:)];
                // 指定左边缘滑动
                _edgeGesture.edges = UIRectEdgeLeft;
                [self.view addGestureRecognizer:_edgeGesture];
                // 如果ges的手势与collectionView手势都识别的话,指定以下代码,代表是识别传入的手势
                [self.collectionView.panGestureRecognizer requireGestureRecognizerToFail:_edgeGesture];
           }
        }
    };
    actionSheet.scrolling          = YES;
    actionSheet.buttonHeight       = 60.0f;
    actionSheet.visibleButtonCount = 3.6f;
    [actionSheet show];
}

-(void)leftBtnClick:(id)sender{
    [_collectionView.mj_header setHidden:NO];
    [UIView animateWithDuration:0.5 animations:^{
        _chooseHeadView.transform = CGAffineTransformTranslate(_chooseHeadView.transform, 0, -64);
    }];
    _rightbtn.userInteractionEnabled = YES;
    self.collectionView.fmState = FMPhotosCollectionViewCellStateNormal;
    //clean操作记录
    [self removeAllSelectData];
    [self.collectionView reloadData];
    _addButton.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self tabBarAnimationWithHidden:NO];
    });
    if (_edgeGesture) {
        [self.view removeGestureRecognizer:_edgeGesture];
        _edgeGesture = nil;
    }
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.collectionView reloadData];
//    });
}

#pragma mark - floatMenuDelegate

-(void)didSelectMenuOptionAtIndex:(NSInteger)row{
//    switch (row) {
//        case 0:{
//            //下载
//            if (self.choosePhotos.count == 0) {
//                [SXLoadingView showAlertHUD:@"请先选择照片" duration:1];
//            }else{
//                //downLoading...
//                [self clickDownloadWithShare:NO andCompleteBlock:nil];
//            }
//        }
//            break;
//        case 1:{
//            //创建图集
//            if (self.choosePhotos.count == 0) {
//                [SXLoadingView showAlertHUD:@"请先选择照片" duration:1];
//            }else{
//                LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:@"请选择"
//                                                                         delegate:self
//                                                                cancelButtonTitle:@"取消"
//                                                            otherButtonTitleArray:@[@"创建新的相册",@"添加到已有相册"]];
//                actionSheet.scrolling          = YES;
//                actionSheet.buttonHeight       = 60.0f;
//                actionSheet.visibleButtonCount = 3.6f;
//                [actionSheet show];
//            }
//        }
//            break;
//        case 2:{
            NSLog(@"创建Share");
            [self clickShareBtn];
//        }
//            break;
//        default:
//            break;
//    }
}

-(void)clickDownloadWithShare:(BOOL)share andCompleteBlock:(void(^)(NSArray * images))block{
    NSArray * chooseItems = [self.choosePhotos copy];
    if (!_pv)
        _pv = [JYProcessView processViewWithType:ProcessTypeLine];
    _pv.descLb.text = share?@"正在准备照片":@"正在下载文件";
    _pv.subDescLb.text = [NSString stringWithFormat:@"%lu个项目 ",(unsigned long)chooseItems.count];
    [_pv show];
    _shouldDownload = YES;
    _pv.cancleBlock = ^(){
        _shouldDownload = NO;
    };
    [self downloadItems:chooseItems withShare:share andCompleteBlock:block];
    [self leftBtnClick:_leftBtn];
}

-(void)downloadItems:(NSArray *)items withShare:(BOOL)isShare andCompleteBlock:(void(^)(NSArray * images))block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            __block float complete = 0.f;
            __block int successCount = 0;
            __block int finish = 0;
            FMPhotoDownloadHelper  * helper = [FMPhotoDownloadHelper defaultHelper];
            __weak typeof(helper) weakHelper = helper;
            __block NSUInteger allCount = items.count;
            @weaky(self);
            NSMutableArray * tempDownArr = [NSMutableArray arrayWithCapacity:0];
            helper.downloadCompleteBlock = ^(BOOL success ,UIImage *image){
                complete ++;finish ++;
                if (successCount) successCount++;
                CGFloat progress =  complete/allCount;
                if (image && isShare) [tempDownArr addObject:image];
                [weak_self.pv setValueForProcess:progress];
                if (items.count > complete) {
                    if (_shouldDownload) {
                        [weak_self downloadItem:items[finish] withShare:isShare withCompleteBlock:weakHelper.downloadCompleteBlock];
                    }
                }else{
                    _shouldDownload = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weak_self.pv dismiss];
                        if (!isShare)
                            [MyAppDelegate.notification displayNotificationWithMessage:@"下载完成" forDuration:0.5f];
                        if (block) block([tempDownArr copy]);
                    });
                }
            };
            if (_shouldDownload) {
                [self downloadItem:items[0] withShare:isShare withCompleteBlock:weakHelper.downloadCompleteBlock];
            }
        }
    });
}

-(void)downloadItem:(id<IDMPhoto>)item withShare:(BOOL)share withCompleteBlock:(void(^)(BOOL isSuccess,UIImage * image))block{
    if ([item isKindOfClass:[FMNASPhoto class]]) {
        [FMGetImage getFullScreenImageWithPhotoHash:[item getPhotoHash]
                                   andCompleteBlock:^(UIImage *image, NSString *tag)
         {
             if (image) {
                 if(!share){
                     [[PhotoManager shareManager]saveImage:image andCompleteBlock:^(BOOL isSuccess) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                            block(isSuccess,image);
                         });
                     }];
                 }else{
                     dispatch_async(dispatch_get_main_queue(), ^{
                         block(YES,image);
                     });
                 }
             }else
                 dispatch_async(dispatch_get_main_queue(), ^{
                     block(NO,nil);
                 });
        }];
    }else{
        FMLocalPhotoStore * store = [FMLocalPhotoStore shareStore];
        PHAsset * asset = [store checkPhotoIsLocalWithLocalId:[(FMPhotoAsset *)item localId]];
        if (asset) {
            if (!share) {
                [PhotoManager getImageDataWithPHAsset:asset andCompleteBlock:^(NSString *filePath) {
                    UIImage * image;
                    if (filePath && (image = [UIImage imageWithContentsOfFile:filePath])) {
                        [[PhotoManager shareManager]saveImage:image andCompleteBlock:^(BOOL isSuccess) {
                            [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];//删除image
                            block(isSuccess,image);
                        }];
                    }else block(NO,nil);
                }];
            }else{
                [[FMGetImage defaultGetImage] getOriginalImageWithAsset:asset andCompleteBlock:^(UIImage *image, NSString *tag) {
                    block(YES,image);
                }];
                
            }
        }else block(NO,nil);
    }
}

//LC delegate
- (void)actionSheet:(LCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {//创建新相册
        FMAlbumNamedController * vc = [[FMAlbumNamedController alloc]init];
        vc.namedState = NamedUseInPhoto;
        vc.photoArr = [self.choosePhotos copy];
        [self leftBtnClick:_leftBtn];
        [self presentViewController:vc animated:YES completion:^{
        }];
    }else{//添加到已有相册 //index == 2 无效 不处理
        
    }
}

//创建分享
-(void)clickShareBtn{
    if (self.choosePhotos.count>0) {
        
//        _shareView = [JYAlertView jy_AlertViewCreateWithDelegate:self andDataSource:self];
//        [_shareView show];
        
//        LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:@"请选择"
//                                                        cancelButtonTitle:@"取消"
//                                                                  clicked:^(LCActionSheet *actionSheet, NSInteger buttonIndex) {
//                                                                      if(buttonIndex == 1) [self shareToLocalUser];
//                                                                      else if(buttonIndex == 2)
        [self shareToOtherApp];
//                                                                  }
//                                                        otherButtonTitles:@"分享给所有人",@"分享到第三方应用", nil];
//        actionSheet.scrolling          = YES;
//        actionSheet.buttonHeight       = 60.0f;
//        actionSheet.visibleButtonCount = 3.6f;
//        [actionSheet show];
    }
    else
        [SXLoadingView showAlertHUD:@"请先选择照片" duration:1];
}

//本地分享
-(void)shareToLocalUser{
    [SXLoadingView showProgressHUD:@"正在准备照片数据"];
    NSMutableArray * contents = [NSMutableArray arrayWithCapacity:0];
    for (id<IDMPhoto> photo in self.choosePhotos) {
        NSString * digest = [photo getPhotoHash];
        if (IsNilString(digest) && [photo isKindOfClass:[FMPhotoAsset class]]) {
            digest = [(FMPhotoAsset *)photo getPhotoHashSync];
        }
        [contents addObject:digest];
    }
    
    [SXLoadingView hideProgressHUD];
    
    FMCreateShareAPI * api = [FMCreateShareAPI shareCreateWithMaintainers:[FMDBControl getAllUsersUUID] Viewers:[FMDBControl getAllUsersUUID] Contents:contents IsAlbum:nil];
    [MyAppDelegate.notification displayNotificationWithView:[FMNotifyView notifyViewWithMessage:@"发送中..."] completion:^{}];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        [SXLoadingView showAlertHUD:@"分享成功" duration:1];
    } failure:^(__kindof JYBaseRequest *request) {
        [SXLoadingView showAlertHUD:@"分享失败" duration:1];
    }];
    
    [self leftBtnClick:_leftBtn];
    //                [FMUpdateDocumentTool mediaShareNeedUpdate];//需要刷新mediaShare
    [[NSNotificationCenter defaultCenter] postNotificationName:FM_NEED_UPDATE_UI_NOTIFY object:nil];
    [self.rdv_tabBarController setSelectedIndex:0];
}

//其他分享
-(void)shareToOtherApp{
    //准备照片
    @weaky(self);
    [self clickDownloadWithShare:YES andCompleteBlock:^(NSArray *images) {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:images applicationActivities:nil];
        //初始化回调方法
        UIActivityViewControllerCompletionWithItemsHandler myBlock = ^(NSString *activityType,BOOL completed,NSArray *returnedItems,NSError *activityError)
        {
            NSLog(@"activityType :%@", activityType);
            if (completed)
            {
                NSLog(@"share completed");
            }
            else
            {
                NSLog(@"share cancel");
            }
            
        };
        
        // 初始化completionHandler，当post结束之后（无论是done还是cancel）该blog都会被调用
        activityVC.completionWithItemsHandler = myBlock;
        
        //关闭系统的一些activity类型 UIActivityTypeAirDrop 屏蔽aridrop
        activityVC.excludedActivityTypes = @[];
        
        [weak_self presentViewController:activityVC animated:YES completion:nil];
    }];
}


//捏合响应
-(void)handlePinch:(UIPinchGestureRecognizer *)pin{
    if (pin.state == UIGestureRecognizerStateBegan) {
        if(pin.scale > 1.0f){
            [self.collectionView changeFlowLayoutIsBeSmall:NO];
        }else{
            [self.collectionView changeFlowLayoutIsBeSmall:YES];
        }
        [self.collectionView reloadData];
    }
}

#pragma mark - Util
/********************************************************************************************************/
/*************************************       Util      **************************************************/
/********************************************************************************************************/
//清楚所有选中的照片
-(void)removeAllSelectData{
    [self.chooseSection removeAllObjects];
    [self.choosePhotos removeAllObjects];
}

//是否为全选了整个区
-(BOOL)isSectionShouldSelect:(NSUInteger)section{
    NSArray *  items = [self.photoDataSource.dataSource objectAtIndex:section];
    BOOL isShouldSelect = YES;
    for (FMPhoto * photo in items) {
        if(![self.choosePhotos containsObject:photo]){
            if (![photo isKindOfClass:[FMNASPhoto class]]) {
                isShouldSelect = NO;
                break;
            }
        }
    }
    return isShouldSelect;
}
/********************************************************************************************************/
/*************************************     delegate    **************************************************/
/********************************************************************************************************/
#pragma mark - FMPhotoCollectionViewDelegate

-(UICollectionViewCell *)fm_CollectionView:(FMPhotoCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"photocell";
    
//    [_cellIdentifierDic objectForKey:[NSString stringWithFormat:@"%@", indexPath]];
    
//    if(identifier == nil){
//        
//        identifier = [NSString stringWithFormat:@"selectedBtn%@", [NSString stringWithFormat:@"%@", indexPath]];
//        [_cellIdentifierDic setObject:identifier forKey:[NSString  stringWithFormat:@"%@",indexPath]];
//        
//        UINib *nib = [UINib nibWithNibName:@"FMPhotosCollectionViewCell" bundle: [NSBundle mainBundle]];
//        [_collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
//    }
    FMPhotosCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
//    if(!cell){
//        
//    }
  
    NSArray * datas = [self.photoDataSource.dataSource objectAtIndex:indexPath.section];
    // 请求图片
    cell.fmDelegate = self;
    cell.state = collectionView.fmState;
    id<IDMPhoto> asset = datas[indexPath.row];
    cell.asset = asset;
    if (collectionView.indicator) {
        collectionView.indicator.slider.timeLabel.text = [self getMouthDateStringWithPhoto:[asset getPhotoCreateTime]];
    }
    if ([self.choosePhotos indexOfObject:asset] != NSNotFound) {
        cell.isChoose = YES;
    }else{
        cell.isChoose = NO;
    }
    return cell;
}

-(NSInteger)fm_CollectionView:(FMPhotoCollectionView *)collectinView numberOfRowInSection:(NSUInteger)num{
    NSArray * datas = [self.photoDataSource.dataSource objectAtIndex:num];
    return datas.count;
}

-(NSInteger)fm_CollectionViewNumberOfSectionInView:(FMPhotoCollectionView *)collectinView{
    return _photoDataSource.dataSource.count;
}

//headView
- (FMHeadView *)fm_CollectionView:(FMPhotoCollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    FMHeadView * headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView" forIndexPath:indexPath];
    NSDate * date = [self.photoDataSource.timeArr objectAtIndex:indexPath.section];
//    NSLog(@"%@",date);
    headView.headTitle = [NSDate getDateStringWithPhoto:date];
    headView.fmState = _collectionView.fmState;
    //判断该区是否选中状态
    BOOL isChooseSection = NO;
    for (NSIndexPath * inPath in self.chooseSection) {
        if (inPath.section == indexPath.section) {
            isChooseSection = YES;
            break;
        }
    }
    headView.isChoose = isChooseSection;
    headView.fmIndexPath = indexPath;
    headView.fmDelegate = self;
    return headView;
}

-(void)fm_CollectionView:(FMPhotoCollectionView *)collectinView didSelectedIndexPath:(NSIndexPath *)indexPath{
    
    FMPhotosCollectionViewCell *cell = (FMPhotosCollectionViewCell *)[collectinView cellForItemAtIndexPath:indexPath];
    
    //在数据源找到对象
    NSArray * datas = [self.photoDataSource.dataSource objectAtIndex:indexPath.section];
    id<IDMPhoto> photo = datas[indexPath.row];
    if(self.collectionView.fmState == FMPhotosCollectionViewCellStateNormal){
        //当前选中的是第多少张图
        NSInteger index = indexPath.row;
        for (int i = 0; i < indexPath.section; i ++) {
            index += [self.collectionView numberOfItemsInSection:i];
        }
        
        NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
        for (NSArray * arr1 in self.photoDataSource.dataSource) {
            [arr addObjectsFromArray:arr1];
        }
        
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:arr animatedFromView:cell];
        [browser setInitialPageIndex:index];
        browser.delegate = self;
        browser.displayActionButton = NO;
        browser.displayArrowButton = YES;
        browser.displayCounterLabel = YES;
        browser.usePopAnimation = YES;
        browser.scaleImage = cell.fmPhotoImageView.image;
        browser.displayToolbar = NO;
        browser.photoBrowserType = JYPhotoBrowserTypePhoto;
        [self.rdv_tabBarController presentViewController:browser animated:YES completion:nil];
    }
    else if(self.collectionView.fmState == FMPhotosCollectionViewCellStateCanChoose){
        
//        if([photo isKindOfClass:[FMNASPhoto class]] && ![((FMNASPhoto *)photo).permittedToShare boolValue]){
//            [SXLoadingView showAlertHUD:@"非本人照片，不能操作" duration:0.5];
//            return ;
//        }
        
        if ([self.choosePhotos indexOfObject:photo] == NSNotFound) {
            [self.choosePhotos addObject:photo];
            [cell setChooseWithAnimation:YES];
            //如果该组全选, 则全选section
            if ([self isSectionShouldSelect:indexPath.section]) {
                NSIndexPath * inxPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
                [self.chooseSection addObject:inxPath];
                [self.collectionView reloadData];
            }
        }
        else{
            [self.choosePhotos removeObject:photo];
            [cell setChooseWithAnimation:NO];
            //如果该组是全选状态 则取消全选状态
            for (NSIndexPath * inPath in self.chooseSection) {
                if (inPath.section == indexPath.section) {
                    [self.chooseSection removeObject:inPath];
                    [self.collectionView reloadData];
                    break;
                }
            }
        }
        _countLb.text = [NSString stringWithFormat:@"已选%ld张",(unsigned long)self.choosePhotos.count];
        if (self.choosePhotos.count < 1) {
            [self leftBtnClick:nil];
        }
    }
}



#pragma mark - FMHeadViewDelegate

//选择了全选整个区的按钮
- (void)FMHeadView:(FMHeadView *)headView isChooseBtn:(BOOL)isChoose{
//    NSLog(@"选择了 第 %ld 区",headView.fmIndexPath.section);
    if (self.collectionView.fmState == FMPhotosCollectionViewCellStateCanChoose) {
        NSUInteger section = headView.fmIndexPath.section;
        NSArray * items = [self.photoDataSource.dataSource objectAtIndex:section];
        int i = 0;
        if (isChoose) {
            //添加选中该区所有图片
            for (FMPhoto * photo in items) {
                if ([self.photoDataSource.netphotoArr containsObject:photo]) {
                    FMNASPhoto * p = (FMNASPhoto *)photo;
//                    if(![p.permittedToShare boolValue])
//                        continue;
                }
                if ([self.choosePhotos indexOfObject:photo] == NSNotFound) {
                    [self.choosePhotos addObject:photo];
                    i++;
                }
            }
            if (i>0) {
                [self.chooseSection addObject:headView.fmIndexPath];
            }
        }else{
            [self.chooseSection removeObject:headView.fmIndexPath];
            //删除选中该区所有照片
            [self.choosePhotos removeObjectsInArray:items];
        }
        _countLb.text = [NSString stringWithFormat:@"已选%ld张",(unsigned long)self.choosePhotos.count];
        if (self.choosePhotos.count < 1) {
            [self leftBtnClick:nil];
        }

        [self.collectionView reloadData];
    }
}


#pragma mark - FMPhotosCollectionViewCellDelegate
//点击了选择按钮
-(void)FMPhotosCollectionViewCellDidChoose:(FMPhotosCollectionViewCell *)cell{
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    [self fm_CollectionView:self.collectionView didSelectedIndexPath:indexPath];
    
}
//响应了长按手势
-(void)FMPhotosCollectionViewCellDidLongPress:(FMPhotosCollectionViewCell *)cell{
    if (self.collectionView.fmState == FMPhotosCollectionViewCellStateCanChoose) {
        return;
    }
     self.collectionView.mj_header.hidden = YES;
//    self.collectionView.mj_header.hidden = YES;
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    FMPhotoAsset * asset = self.photoDataSource.dataSource[indexPath.section][indexPath.row]; 
    
  
    self.collectionView.fmState = FMPhotosCollectionViewCellStateCanChoose;
    [self.collectionView reloadData];
    _rightbtn.userInteractionEnabled = NO;
    [self addLeftBtn];
    _addButton.hidden = NO;
      _countLb.text = [NSString stringWithFormat:@"已选1张"];
    BOOL shouldChoose = YES;
//    if ([self.photoDataSource.netphotoArr containsObject:asset]) {
//        FMNASPhoto * p = (FMNASPhoto *)asset;
//        shouldChoose = [p.permittedToShare boolValue];
//    }
    
    if (shouldChoose) {
        [self.choosePhotos addObject:asset];
    }
    [self.collectionView reloadData];
    if (!_edgeGesture) {
        _edgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(gesture:)];
        // 指定左边缘滑动
        _edgeGesture.edges = UIRectEdgeLeft;
        [self.view addGestureRecognizer:_edgeGesture];
        // 如果ges的手势与collectionView手势都识别的话,指定以下代码,代表是识别传入的手势
        [self.collectionView.panGestureRecognizer requireGestureRecognizerToFail:_edgeGesture];
    }
}

#pragma mark - IDMPhotoBrowserDelegate

-(void)photoBrowser:(IDMPhotoBrowser *)photoBrowser didShowPhotoAtIndex:(NSUInteger)index{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self getIndexPathWithIndex:index];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
//        });
    });
}


//-(UIImage *)photoBrowser:(IDMPhotoBrowser *)photoBrowser needThumbnailAtIndex:(NSUInteger)index{
//    NSIndexPath * indexPath = [self getIndexPathWithIndex:index];
//    UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:indexPath];
//    return ((FMPhotosCollectionViewCell * )cell).fmPhotoImageView.image;
//}

-(NSIndexPath *)getIndexPathWithIndex:(NSUInteger)index{
    NSInteger  sections = [self.collectionView numberOfSections];
    NSInteger _index = index;
    NSIndexPath * indexPath = nil;
    UICollectionViewCell * cell = nil;
    for (int i = 0; i<sections; i++) {
        NSInteger j = [self.collectionView numberOfItemsInSection:i];
        if( j < (_index+1)){
            _index -= j;
        }
        else{
            indexPath = [NSIndexPath indexPathForRow:_index inSection:i];
            break;
        }
    }
    if (indexPath) {
        cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        if (!cell){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                [self.collectionView layoutIfNeeded];
            });
        }
    }
    return indexPath;
}


- (UIView *)photoBrowser:(IDMPhotoBrowser *)photoBrowser needAnimationViewWillDismissAtPageIndex:(NSUInteger)index{
    NSIndexPath * indexPath = [self getIndexPathWithIndex:index];
    UICollectionViewCell * cell = nil;
    if (indexPath) {
        cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        if (cell) {
            return ((FMPhotosCollectionViewCell *)cell).fmPhotoImageView;
        }else{
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            [self.collectionView layoutIfNeeded];
            cell = [self.collectionView cellForItemAtIndexPath:indexPath];
            if (cell) {
                return ((FMPhotosCollectionViewCell *)cell).fmPhotoImageView;
            }
        }
    }
    return nil;
}


-(NSDate *)getFormatDateWithDate:(NSDate *)date{
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    [formatter1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString * dateString = [formatter1 stringFromDate:date];
    NSDate * dateB = [formatter1 dateFromString:dateString];
    return dateB;
}


-(NSString *)getDateStringWithPhoto:(NSDate *)date{
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy-MM-dd";
    [formatter1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString * dateString = [formatter1 stringFromDate:date];
    return dateString;
}

-(NSString *)getMouthDateStringWithPhoto:(NSDate *)date{
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy年MM月";
    [formatter1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString * dateString = [formatter1 stringFromDate:date];
//    NSLog(@"%@",dateString);
    if (IsEquallString(dateString, @"1970年01月")) {
        dateString = @"未知时间";
    }
    return dateString;
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
     [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
    for (NSArray * arr in self.photoDataSource.dataSource) {
        for (id<IDMPhoto> photo in arr) {
            [photo unloadUnderlyingImage];
        }
    }
}

#pragma DataSouce delegate
static BOOL waitingForReload = NO;
-(void)dataSourceFinishToLoadPhotos{
    
    if (!_shouldDownload) {
        waitingForReload = NO;
        [self.collectionView reloadData];
        [self.collectionView.mj_header endRefreshing];
  
    }else{
        if (waitingForReload)
            return;
        waitingForReload = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            waitingForReload = NO;
            [self dataSourceFinishToLoadPhotos];
        });
    }
}

#pragma UITableViewdelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FMPersonsCell * cell = [[FMPersonsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([FMPersonsCell class]) Count:1 getCellsBlock:^UICollectionViewCell *(NSIndexPath *indexP, UICollectionViewCell *ce) {
        FMPersonCell * personcell = (FMPersonCell *)ce;
//        if(indexPath.row == 0){
//            personcell.groupImage.image = [UIImage imageNamed:@"all"];
//            personcell.nameLab.text = @"所有人";
//        }else{
//            personcell.groupImage.image = [UIImage imageNamed:@"open_in"];
//            personcell.nameLab.text = @"其他应用";
//        }
        return personcell;
    }];
    @weaky(self);
    cell.selectItemBlock = ^(NSInteger index){
        [weak_self checkItemWithIndexPath:[NSIndexPath indexPathForRow:index inSection:indexPath.row]];
    };
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}


//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, __kWidth, 40)];
//    label.font = [UIFont systemFontOfSize:14.0f];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.text = @"请选择分享方式";
//    return label;
//}

-(void)checkItemWithIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.section == 0) {
//        [self shareToLocalUser];
//    }else{
        [self shareToOtherApp];
//    }
//    [_shareView dismiss];
}

//-(void)asynAnyThings{
//
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [FMDBControl asynUsers];
//    });
//
//}

//- (FMPhotoDataSource *)photoDataSource{
//    if (!_photoDataSource) {
//        _photoDataSource = []
//    }
//    return _photoDataSource;
//}

@end
