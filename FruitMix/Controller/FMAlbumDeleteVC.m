//
//  FMAlbumDeleteVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/6.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMAlbumDeleteVC.h"
#import "FMAlbumDeleteCell.h"
#import "FMAlbumAddPhotosVC.h"
#import "FMMediaShareTask.h"
#import "FMGetThumbImage.h"

#import "FMAlbumDataSource.h"

@interface FMAlbumDeleteVC ()<UICollectionViewDelegate,UICollectionViewDataSource,FMAlbumDeleteCellDetegate>

@property (nonatomic) UICollectionView * collectionView;

@property (nonatomic) NSMutableArray * dataSource;

@property (nonatomic) NSMutableArray * cpSource;

@property (nonatomic) NSMutableArray * replaceArr;

@property (nonatomic) NSMutableArray * addArr;

@property (nonatomic) UIButton * controlBtn;

@end

@implementation FMAlbumDeleteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithArray:self.album.getAllContents];
        _cpSource = [NSMutableArray arrayWithCapacity:0];
        for (id<IDMPhoto>  item in _dataSource) {
            [_cpSource addObject:item.getPhotoHash];
        }
    }
    return _dataSource;
}

-(NSMutableArray *)replaceArr{
    if (!_replaceArr) {
        _replaceArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _replaceArr;
}

-(NSMutableArray *)addArr{
    if (!_addArr) {
        _addArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _addArr;
}

-(void)initView{
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection=UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 11, 0);
    layout.minimumLineSpacing = 2;
    layout.minimumInteritemSpacing = 2;
    layout.itemSize = CGSizeMake((__kWidth- 4)/3, (__kWidth- 4)/3);
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, __kWidth, __kHeight-64) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:@"FMAlbumDeleteCell" bundle:nil] forCellWithReuseIdentifier:@"deletecell"];
    [self.collectionView reloadData];
    [self createControlbtn];
    [self addBtns];
}

-(void)createControlbtn{
    if (!_controlBtn) {
        _controlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _controlBtn.showsTouchWhenHighlighted = YES;
        [_controlBtn setImage:[UIImage imageNamed:@"add_album"] forState:UIControlStateNormal];
        _controlBtn.frame = CGRectMake(self.view.jy_Width-80 , self.view.jy_Height - 120-32-64, 64, 64);
        _controlBtn.layer.cornerRadius = 32;
        _controlBtn.layer.masksToBounds = YES;
        [_controlBtn addTarget:self action:@selector(_controlBtnChick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_controlBtn];
    }
}

-(void)addBtns{
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 48, 48)];
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont fontWithName:FANGZHENG size:16];
    rightBtn.titleLabel.textColor = UICOLOR_RGB(0xffffff);
    UIBarButtonItem *negativeSpacer = [[ UIBarButtonItem alloc ]
                                       initWithBarButtonSystemItem : UIBarButtonSystemItemFixedSpace
                                       target : nil action : nil ];
    negativeSpacer. width = -8;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,[[UIBarButtonItem alloc]initWithCustomView:rightBtn]];
}

-(void)removeSamePhoto{
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
    for (NSString * hash in self.replaceArr) {
        if ([self.addArr containsObject:hash]) {
            [arr addObject:hash];
        }
    }
    [self.replaceArr removeObjectsInArray:arr];
    [self.addArr removeObjectsInArray:arr];
    arr = nil;
}

-(void)rightBtnClick:(id)sender{
    [SXLoadingView showProgressHUD:@"正在更新"];
    //去重
    [self removeSamePhoto];
    
    [FMAlbumDataSource editContentsAlbum:self.album adds:self.addArr removes:self.replaceArr andComPleteBlock:^(BOOL success) {
        if (success) {
            [MyAppDelegate.notification displayNotificationWithView:[FMNotifyView notifyViewWithMessage:@"操作成功"] forDuration:1];
            //        [FMUpdateDocumentTool mediaShareNeedUpdate];//需要刷新mediaShare
            [[NSNotificationCenter defaultCenter] postNotificationName:FM_NEED_UPDATE_UI_NOTIFY object:nil];
            [self backToWater];
        }else{
            [SXLoadingView hideProgressHUD];
            [MyAppDelegate.notification displayNotificationWithView:[FMNotifyView notifyViewWithMessage:@"操作失败"] forDuration:1];
        }
    }];
    
    
//    NSMutableArray * tempReplaceArr = [NSMutableArray arrayWithCapacity:0];
//    for (FMShareAlbumItem * item in self.replaceArr) {
//        [tempReplaceArr addObject:item.digest];
//    }
//    
//    NSMutableArray * tempAddArr = [NSMutableArray arrayWithCapacity:0];
//    for (id<IDMPhoto> item in self.addArr) {
//        [tempAddArr addObject:[item getPhotoHash]];
//    }
//    
//    if([FMMediaShareTask mediaShareIsLocal:self.album.uuid]){
//        [FMMediaShareTask mediaTask_DeleteWithShareId:self.album.uuid andDeleteArr:tempReplaceArr];
//        //不管是否为Local 都塞到local;
//        [FMMediaShareTask mediaTask_AddWithShareId:self.album.uuid andAddLocalArr:tempAddArr andNetArr:nil];
//       [self backToWater];
//    }
//    else{
//        [FMMediaShareTask Patch_GetPhotoNotLocalWithShareId:self.album.uuid andPhotos:tempReplaceArr andCompletBlock:^(NSArray *localArr, NSArray *netArr) {
//            FMMediaPatchAPI * api = [FMMediaPatchAPI new];
//            //remove
//            for (FMShareAlbumItem * item in self.replaceArr) {
//                if([netArr containsObject:item.digest]){
//                    NSMutableDictionary * contents = [[NSMutableDictionary alloc]init];
//                    [contents setValue:item.digest forKey:@"digest"];
//                    [api addPatchType:PatchTypeRemove andPath:self.album.uuid andValue:contents];
//                }
//            }
//            //删除本地数据
//            [FMMediaShareTask mediaTask_DeleteWithShareId:self.album.uuid andDeleteArr:localArr];
//            
//            //Add
//            NSArray * canAddArr = [self getCanAddArr];
//            for (FMShareAlbumItem * item in canAddArr) {
//                NSMutableDictionary * contents = [[NSMutableDictionary alloc]init];
//                [contents setValue:item.digest forKey:@"digest"];
//                [contents setValue:@"media" forKey:@"type"];
//                [api addPatchType:PatchTypeAdd andPath:self.album.uuid andValue:contents];
//            }
//            if (api.patchArr.count>0) {
//                [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//                    [MyAppDelegate.notification displayNotificationWithMessage:@"操作成功" forDuration:1];
////                    [FMUpdateDocumentTool mediaShareNeedUpdate];//需要刷新mediaShare
//                    [[NSNotificationCenter defaultCenter] postNotificationName:FM_NEED_UPDATE_UI_NOTIFY object:nil];
//                    [self backToWater];
//                } failure:^(__kindof JYBaseRequest *request) {
//                    NSLog(@"失败：%@",request.error);
//                    [MyAppDelegate.notification displayNotificationWithMessage:@"操作失败" forDuration:1];
//                    [self backToWater];
//                }];
//            }else{
//                [self backToWater];
//            }
//        }];
//    }
}

-(void)backToWater{
    [SXLoadingView hideProgressHUD];
    if (self.block) {
        self.block(self.dataSource);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//拿到可以Patch 的照片
//-(NSMutableArray * )getCanAddArr{
//    NSMutableArray * add = [NSMutableArray arrayWithCapacity:0];
//    NSMutableArray * localPatch = [NSMutableArray arrayWithCapacity:0];
//    for (id photo in self.addArr) {
//        if ([photo isKindOfClass:[FMPhotoAsset class]]) {
//            NSString * photoDigest = [(FMPhotoAsset *)photo getPhotoHash];
//            if (IsNilString(photoDigest)) {
//                PHFetchOptions *option = [[PHFetchOptions alloc] init];
//                PHFetchResult * result = [PHAsset fetchAssetsWithLocalIdentifiers:@[((FMPhotoAsset *)photo).localId] options:option];
//                if (result.count) {
//                    photoDigest = [PhotoManager getSha256WithAsset:result[0]];
//                }else
//                    continue;
//                
//            }
//            [localPatch addObject:photoDigest];
//        }else{
//            FMShareAlbumItem * item = [[FMShareAlbumItem alloc]init];
//            FMNASPhoto * p = (FMNASPhoto *)photo;
//            item.digest = [p getPhotoHash];
//            item.createtime = [p getPhotoCreateTime];
//            item.shareid = self.album.uuid;
//            [add addObject:item];
//        }
//    }
//    //如果有本地照片
//    if (localPatch.count) {
//        //添加到patch表 等待patch
//        [FMMediaShareTask mediaTask_AddWithShareId:self.album.uuid andAddLocalArr:localPatch andNetArr:nil];
//    }
//    return add;
//}


//加号响应事件
-(void)_controlBtnChick:(UIButton *)sender{
    FMAlbumAddPhotosVC * vc = [[FMAlbumAddPhotosVC alloc]init];
    NSMutableArray * historyArr = [NSMutableArray arrayWithCapacity:0];
    for (id<IDMPhoto> item in self.dataSource) {
        [historyArr addObject:[item getPhotoHash]];
    }
    vc.addSuccessblock = ^(NSArray * addArr){
        for (id<IDMPhoto> item in addArr) {
            [self.addArr addObject:[item getPhotoHash]];
        }
        
        [self.dataSource addObjectsFromArray:addArr];
        [self.collectionView reloadData];
    };
    vc.share = self.album;
    vc.historyPhotosArr = historyArr;
    [self.navigationController pushViewController:vc animated:YES];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FMAlbumDeleteCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"deletecell" forIndexPath:indexPath];
    id<IDMPhoto> item = self.dataSource[indexPath.row];
    cell.imageTag = [item getPhotoHash];
    cell.fm_delegate = self;
    [self cell:cell getImageWithItem:item];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(void)cell:(FMAlbumDeleteCell *)cell getImageWithItem:(id<IDMPhoto>)item{
    [FMGetThumbImage getThumbImageWithAsset:item andCompleteBlock:^(UIImage *image, NSString *tag) {
        cell.albumImage.image = image;
    }];
//     getThumbImageWithPhotoHash:hash andCompleteBlock:^(UIImage *image, NSString *tag) {
//        cell.albumImage.image = image;
//    }];
}

-(void)albumDeleteCell:(FMAlbumDeleteCell *)cell didSelectDeleteBtn:(UIButton *)btn{
    if (_dataSource.count == 0) {
        return;
    }
    @synchronized (self) {
        [self.collectionView performBatchUpdates:^{
            NSIndexPath * indexPath = [_collectionView indexPathForCell:cell];
            id<IDMPhoto> share = self.dataSource[indexPath.row];
            
            if ([self.cpSource containsObject:share.getPhotoHash]) {
                [self.replaceArr addObject:share.getPhotoHash];
            }
            else if([self.addArr containsObject:share.getPhotoHash]){
                [self.addArr removeObject:share.getPhotoHash];
            }
//            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
//            dispatch_after(time, dispatch_get_main_queue(), ^{
            [_dataSource removeObjectAtIndex:indexPath.row];
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
//            });
            
        } completion:nil];
    }
}

@end
