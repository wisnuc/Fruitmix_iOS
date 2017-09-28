//
//  FLDownloadManager.m
//  FruitMix
//
//  Created by 杨勇 on 16/10/11.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FLDownloadManager.h"
#import "FLDownload.h"

@interface FLDownloadManager ()<TYDownloadDelegate>

@end

@implementation FLDownloadManager

+(instancetype)shareManager{
    static FLDownloadManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FLDownloadManager alloc]init];
        [TYDownLoadDataManager manager].delegate = manager;
    });
    return manager;
}

-(void)downloadFileWithFileModel:(FLFilesModel *)model parentUUID:(NSString *)uuid{
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
//    _downloadModel = downloadModel;
    downloadModel.jy_fileName = model.name;
    downloadModel.size = model.size;
    NSMutableArray *downloadedArr = [NSMutableArray arrayWithArray:[FMDBControl getAllDownloadFiles]];
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
    
    for (FLDownload * downloadModelIn in downloadedArr) {
        if ([downloadModelIn.name isEqualToString:downloadModel.fileName]) {
            [SXLoadingView showProgressHUDText:[NSString stringWithFormat:@"%@已下载完成",downloadModel.fileName] duration:1];
            return;
        }
    }
    [[TYDownLoadDataManager manager] startWithDownloadModel:downloadModel];
    [[NSNotificationCenter defaultCenter] postNotificationName:FLDownloadFileChangeNotify object:nil];
}

-(void)downloadModel:(TYDownloadModel *)downloadModel didChangeState:(TYDownloadState)state filePath:(NSString *)filePath error:(NSError *)error{
    if(state == TYDownloadStateCompleted || state == TYDownloadStateNone){
        if (state == TYDownloadStateCompleted) {
            FLDownload * download = [FLDownload new];
            download.name = downloadModel.jy_fileName;
           MyNSLog(@"😝%@",downloadModel.jy_fileName);
            NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
            formatter1.dateFormat = @"yyyy-MM-dd hh:mm:ss";
            [formatter1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            NSString * dateString = [formatter1 stringFromDate:[NSDate date]];
            download.downloadtime = dateString;
            download.uuid = downloadModel.fileName;
            download.userId = FMConfigInstance.userUUID;
            [FMDBControl updateDownloadWithFile:download isAdd:YES];
          [[NSNotificationCenter defaultCenter] postNotificationName:FLDownloadFileChangeNotify object:nil];
        }
        
    }
}
- (void)cancleWithDownloadModel:(TYDownloadModel *)downloadModel{
    
      [ [TYDownLoadDataManager manager] cancleWithDownloadModel:downloadModel];
}

-(void)downloadModel:(TYDownloadModel *)downloadModel didUpdateProgress:(TYDownloadProgress *)progress{
    
}
@end
