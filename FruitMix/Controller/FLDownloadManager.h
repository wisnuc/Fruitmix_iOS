//
//  FLDownloadManager.h
//  FruitMix
//
//  Created by 杨勇 on 16/10/11.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLFilesModel.h"
#import "TYDownLoadModel.h"
#import "TYDownloadUtility.h"
#import "TYDownLoadDataManager.h"

#define FLDownloadFileChangeNotify @"FLDownloadFileChangeNotify"



@interface FLDownloadManager : NSObject

+(instancetype)shareManager;
-(void)downloadFileWithFileModel:(FLFilesModel *)model;

@end
