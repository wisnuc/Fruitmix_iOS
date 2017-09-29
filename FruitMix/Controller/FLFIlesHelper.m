//
//  FLFIlesHelper.m
//  FruitMix
//
//  Created by 杨勇 on 16/10/14.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FLFIlesHelper.h"
#import "FLLocalFIleVC.h"
#import "FLFilesVC.h"
#import "FLSecondFilesVC.h"
@interface FLFIlesHelper ()

@property (nonatomic) NSMutableArray * chooseFiles;
@property (nonatomic) NSMutableArray * chooseFilesUUID;
@property (nonatomic) TYDownloadModel * downloadModel;

@end

@implementation FLFIlesHelper

+(instancetype)helper{
    static FLFIlesHelper * helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [FLFIlesHelper new];
    });
    return helper;
}

-(void)addChooseFile:(FLFilesModel *)model{
    @synchronized (self) {
        //当没有选择过文件
        if(![self containsFile:model]){
            [self.chooseFiles addObject:model];
            [self.chooseFilesUUID addObject:model.uuid];
            if (self.chooseFiles.count == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:FLFilesStatusChangeNotify object:@(1)];
            }
        }
    }
}


-(void)removeChooseFile:(FLFilesModel *)model{
    @synchronized (self) {
        NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
        for (FLFilesModel * file in self.chooseFiles) {
            if (IsEquallString(model.uuid, file.uuid)) {
                [tempArr  addObject:file];
            }
        }
        [self.chooseFiles removeObjectsInArray:tempArr];
        [self.chooseFilesUUID removeObject:model.uuid];
        if (self.chooseFiles.count == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:FLFilesStatusChangeNotify object:@(0)];
        }
    }
}

-(BOOL)containsFile:(FLFilesModel *)model{
    return [self.chooseFilesUUID containsObject:model.uuid];
}


-(void)removeAllChooseFile{
    [self.chooseFiles removeAllObjects];
    [self.chooseFilesUUID removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:FLFilesStatusChangeNotify object:@(0)];
    
}

-(NSMutableArray *)chooseFiles{
    if (!_chooseFiles) {
        _chooseFiles = [NSMutableArray arrayWithCapacity:0];
    }
    return _chooseFiles;
}

-(NSMutableArray *)chooseFilesUUID{
    if(!_chooseFilesUUID){
        _chooseFilesUUID = [NSMutableArray arrayWithCapacity:0];
    }
    return _chooseFilesUUID;
}

-(void)downloadChooseFilesParentUUID:(NSString *)uuid{
    for (FLFilesModel * model in [FLFIlesHelper helper].chooseFiles) {
        if ([model.type isEqualToString:@"file"]) {
            [[FLDownloadManager shareManager] downloadFileWithFileModel:model parentUUID:uuid];
        }
    }
     NSString * string  = [NSString stringWithFormat:@"%ld个文件已添加到下载",(unsigned long)[FLFIlesHelper helper].chooseFiles.count];
//    MyNSLog(@"%@",string);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSString * string  = [NSString stringWithFormat:@"%ld个文件已添加到下载",(unsigned long)[FLFIlesHelper helper].chooseFiles.count];
    dispatch_async(dispatch_get_main_queue(), ^{
      [MyAppDelegate.notification displayNotificationWithMessage:string forDuration:1];
    });
    });
    [[FLFIlesHelper helper] removeAllChooseFile];
}

- (void)downloadAloneFilesWithModel:(FLFilesModel *)model parentUUID:(NSString *)uuid Progress:(TYDownloadProgressBlock)progress State:(TYDownloadStateBlock)state 
{
    NSLog(@"%@",[JYRequestConfig sharedConfig].baseURL);
    NSString * filePath = [NSString stringWithFormat:@"%@/%@",File_DownLoad_DIR,model.name];
    NSString * exestr = [filePath lastPathComponent];
    NSString *urlString;
//    /drives/{driveUUID}/dirs/{dirUUID}/entries/{entryUUID}
    if (KISCLOUD) {
        NSString *sourceUrlString = [NSString stringWithFormat:@"/drives/%@/dirs/%@/entries/%@",DRIVE_UUID,uuid,model.uuid];
        NSString *urlStringBase64 = [sourceUrlString base64EncodedString];
        urlString= [NSString stringWithFormat:@"%@stations/%@/pipe?resource=%@&method=GET&name=%@",[JYRequestConfig sharedConfig].baseURL,KSTATIONID,urlStringBase64,exestr];
    }else{
        urlString= [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries/%@?name=%@",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID,uuid,model.uuid,exestr];
    }
    NSString *encodedString = [urlString URLEncodedString];
    TYDownloadModel * downloadModel = [[TYDownloadModel alloc] initWithURLString:encodedString filePath:filePath];
    _downloadModel = downloadModel;
    downloadModel.jy_fileName = model.name;
    downloadModel.size = model.size;
//    NSMutableArray *downloadedArr = [NSMutableArray arrayWithArray:[FMDBControl getAllDownloadFiles]];
    TYDownLoadDataManager *manager = [TYDownLoadDataManager manager];
    for (TYDownloadModel * downloadModelIn in [TYDownLoadDataManager manager].downloadingModels) {
        if ([downloadModelIn.downloadURL isEqualToString:downloadModel.downloadURL]) {
            [SXLoadingView showProgressHUDText:[NSString stringWithFormat:@"%@正在下载",downloadModel.fileName]  duration:1];
            return;
        }
    }
    
    for (TYDownloadModel * downloadModelIn in [TYDownLoadDataManager manager].waitingDownloadModels) {
        if ([downloadModelIn.downloadURL isEqualToString:downloadModel.downloadURL]) {
            [SXLoadingView showProgressHUDText:[NSString stringWithFormat:@"%@正在等待下载",downloadModel.fileName]  duration:1];
            return;
        }
    }
    
//    for (FLDownload * downloadModelIn in downloadedArr) {
//        if ([downloadModelIn.name isEqualToString:downloadModel.fileName]) {
//            [SXLoadingView showProgressHUDText:[NSString stringWithFormat:@"%@已下载完成",downloadModel.fileName] duration:1];
//            return;
//        }
//    }
  
    [manager startWithDownloadModel:downloadModel progress:progress state:state];
     [[NSNotificationCenter defaultCenter] postNotificationName:FLDownloadFileChangeNotify object:nil];
}



- (void)cancleDownload{
    if (_downloadModel) {
         TYDownloadModel * tymodel  = _downloadModel;
        [[TYDownLoadDataManager manager] cancleWithDownloadModel:tymodel];
    }
}

-(void)configCells:(FLFilesCell * )cell withModel:(FLFilesModel *)model cellStatus:(FLFliesCellStatus)status viewController:(UIViewController *)viewController parentUUID:(NSString *)uuid{
    cell.nameLabel.text = model.name;
    cell.sizeLabel.text = [NSString fileSizeWithFLModel:model];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([model.type isEqualToString:@"file"]) {
        cell.f_ImageView.image = [UIImage imageNamed:@"file_icon"];
        cell.timeLabel.text = [self getTimeWithTimeSecond:model.mtime/1000];
    }else{
        cell.f_ImageView.image = [UIImage imageNamed:@"folder_icon"];
        cell.timeLabel.text = [self getTimeWithTimeSecond:model.mtime/1000];
        cell.sizeLabel.hidden = YES;
    }
    cell.downBtn.hidden = ((status == FLFliesCellStatusNormal)?![model.type isEqualToString:@"file"]:YES);
    
    
    if ([self containsFile:model]) {
        cell.f_ImageView.hidden = YES;
        cell.layerView.image = [UIImage imageNamed:@"check_circle_select"];
    }else{
        if ([model.type isEqualToString:@"file"]) {
            cell.f_ImageView.hidden = NO;
            cell.layerView.image = [UIImage imageNamed:@"check_circle"];
        }
    }
    
   
    @weaky(self);
    if ([model.type isEqualToString:@"file"]) {
    
        cell.clickBlock = ^(FLFilesCell * cell){
            cell.downBtn.userInteractionEnabled = YES;
            weak_self.chooseModel = model;
            NSString *downloadString  = @"下载该文件";
            NSMutableArray *downloadedArr = [NSMutableArray arrayWithArray:[FMDBControl getAllDownloadFiles]];
            
            for (FLDownload * downloadModelIn in downloadedArr) {
                if ([downloadModelIn.name isEqualToString:model.name]) {
                    downloadString = @"重新下载";
                }
            }
            
            for (TYDownloadModel * downloadModelIn in [TYDownLoadDataManager manager].downloadingModels) {
                if ([downloadModelIn.fileName isEqualToString:model.name]) {
                    downloadString = nil;
                    cell.downBtn.userInteractionEnabled = NO;
                }
            }
            
            for (TYDownloadModel * downloadModelIn in [TYDownLoadDataManager manager].waitingDownloadModels) {
                if ([downloadModelIn.fileName isEqualToString:model.name]) {
                    downloadString = nil;
                    cell.downBtn.userInteractionEnabled = NO;
                }
            }
           
    
            NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
            if (downloadString) {
                [arr addObject:downloadString];
            }
            LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:nil
                                                                     delegate:nil
                                                            cancelButtonTitle:@"取消"
                                                        otherButtonTitleArray:arr];
            actionSheet.clickedHandle = ^(LCActionSheet *actionSheet, NSInteger buttonIndex){
                if (buttonIndex == 1) {
                    if ([downloadString isEqualToString:@"重新下载"]) {
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"JYDownloadCache/%@",model.name]];
                        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                            NSString * filePath = [NSString stringWithFormat:@"%@/%@",File_DownLoad_DIR,model.name];
                            NSString * exestr = [filePath lastPathComponent];
                            NSString *urlString;
                            //    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
                            if (KISCLOUD) {
                                NSString *sourceUrlString = [NSString stringWithFormat:@"/drives/%@/dirs/%@/entries/%@",DRIVE_UUID,uuid,model.uuid];
                                NSString *urlStringBase64 = [sourceUrlString base64EncodedString];
                                urlString= [NSString stringWithFormat:@"%@stations/%@/pipe?resource=%@&method=GET&name=%@",[JYRequestConfig sharedConfig].baseURL,KSTATIONID,urlStringBase64,exestr];
                            }else{
                                urlString= [NSString stringWithFormat:@"%@drives/%@/dirs/%@/entries/%@?name=%@",[JYRequestConfig sharedConfig].baseURL,DRIVE_UUID,uuid,model.uuid,exestr];
                            }
                            NSString *encodedString = [urlString URLEncodedString];
                            TYDownloadModel * downloadModel = [[TYDownloadModel alloc] initWithURLString:encodedString filePath:filePath];
//                            [[TYDownLoadDataManager manager]deleteFileWithDownloadModel:downloadModel];
                            NSMutableArray * arrayTemp = downloadedArr;
                            
                            NSArray * array = [NSArray arrayWithArray: arrayTemp];
                            for (FLDownload * downloadModelIn in array) {
//                                [downloadedArr removeObject:downloadModelIn];
                                if ([downloadModelIn.name isEqualToString:model.name]) {
                                    [FMDBControl  updateDownloadWithFile:downloadModelIn isAdd:NO];
                                }
                            }
                        }else{
                            NSMutableArray * arrayTemp = downloadedArr;
                            NSArray * array = [NSArray arrayWithArray: arrayTemp];
                            for (FLDownload * downloadModelIn in array) {
//                                  [downloadedArr removeObject:downloadModelIn];
                                if ([downloadModelIn.name isEqualToString:model.name]) {
                                    [FMDBControl  updateDownloadWithFile:downloadModelIn isAdd:NO];
                                }
                            }
                        }
                    }
                  
                    [[FLDownloadManager shareManager] downloadFileWithFileModel:model parentUUID:uuid];
                    [MyAppDelegate.notification displayNotificationWithMessage:[NSString stringWithFormat:@"%@已添加到下载列表",model.name] forDuration:0.5];
                    
                    if (viewController) {
                        FLLocalFIleVC *downloadVC = [[FLLocalFIleVC alloc]init];
                        [viewController.navigationController pushViewController:downloadVC animated:YES];
                    }
                }else if(buttonIndex == 2) {
                    if ([viewController isEqual:[FLFilesVC class]]) {
                        [(FLFilesVC *)viewController shareFiles];
                    }else{
                        [(FLSecondFilesVC *)viewController shareFiles];
                    }
                }
            };
            actionSheet.scrolling          = YES;
            actionSheet.buttonHeight       = 60.0f;
            actionSheet.visibleButtonCount = 3.6f;
            [actionSheet show];
        };
    }
    
    cell.longpressBlock =^(FLFilesCell * cell){
        if (status == FLFliesCellStatusNormal) {
            if ([model.type isEqualToString:@"file"])
                [weak_self addChooseFile:model];
        }
    };
    
    cell.status = status;
}

-(NSString *)getTimeWithTimeSecond:(long long)second{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter * formater = [NSDateFormatter new];
    formater.dateFormat = @"yyyy年MM月dd日 hh:mm:ss";
    NSString * dateString = [formater stringFromDate:date];
    return dateString;
}


@end
