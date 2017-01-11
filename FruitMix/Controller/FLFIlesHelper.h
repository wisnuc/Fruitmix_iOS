//
//  FLFIlesHelper.h
//  FruitMix
//
//  Created by 杨勇 on 16/10/14.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLFilesModel.h"
#import "FLDownloadManager.h"
#import "FLFilesCell.h"
#import "LCActionSheet.h"

#define FLFilesStatusChangeNotify @"FLFilesStatusChangeNotify"

@interface FLFIlesHelper : NSObject

@property (nonatomic,readonly) NSMutableArray * chooseFiles;

@property (nonatomic) FLFilesModel * chooseModel;

+(instancetype)helper;

-(void)downloadChooseFiles;

-(void)configCells:(FLFilesCell * )cell withModel:(FLFilesModel *)model cellStatus:(FLFliesCellStatus)status;

-(void)addChooseFile:(FLFilesModel *)model;

-(void)removeChooseFile:(FLFilesModel *)model;

-(void)removeAllChooseFile;
//判断该文件是否已经被选择
-(BOOL)containsFile:(FLFilesModel *)model;
@end
