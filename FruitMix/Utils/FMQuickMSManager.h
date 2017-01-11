//
//  FMQuickMSManager.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/30.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMQuickMSManager : NSObject

@property (nonatomic) BOOL isFinishd;

-(void)addLocalMeidaShareToUpload:(FMNeedUploadMediaShare *)mediaShare;

+(instancetype)shareInstancetype;

-(void)startUploadLocalMediaShare;

-(void)startToUploadPatch;
@end
