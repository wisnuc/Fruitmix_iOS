//
//  FMFileManager.m
//  FruitMix
//
//  Created by 杨勇 on 16/11/3.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMFileManager.h"

@implementation FMFileManager{
    NSFileManager * _filemanager;
}


+(instancetype)shareManager{
    static FMFileManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [FMFileManager new];
    });
    return manager;
}

-(instancetype)init{
    if (self = [super init]) {
        _filemanager = [NSFileManager defaultManager];
    }
    return self;
}

-(void)removeFileWithFileName:(NSString *)fileName andCompleteBlock:(void(^)(BOOL isSuccess))block{
    @synchronized (self) {
        NSString * filePath = [NSString stringWithFormat:@"%@/%@",File_DownLoad_DIR,fileName];
        if ([_filemanager fileExistsAtPath:filePath]) {
            NSError * error = nil;
            [_filemanager removeItemAtPath:filePath error:&error];
            if (error){
                MyNSLog(@"删除失败 %@",error);
                block(NO);
            }else{
                MyNSLog(@"删除 %@ 成功",fileName);
                block(YES);
            }
        }else{
             block(NO);
        }
    }
}

-(void)removeFileAtPath:(NSString *)filePath{
    @synchronized (self) {
        if ([_filemanager fileExistsAtPath:filePath]) {
            NSError * error = nil;
            [_filemanager removeItemAtPath:filePath error:&error];
            if (error)
                NSLog(@"删除失败 \n FilePath:%@ \n ERROR: %@",filePath,error);
        }
    }
}

@end
