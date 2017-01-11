//
//  FMQuickUploader.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/26.
//  Copyright © 2016年 WinSun. All rights reserved.
//

typedef void(^QuickUploaderCompleteBlock)(NSString * mediaShareId ,NSString * state);

@interface FMQuickUploader : NSObject


-(void)startWithPhotos:(NSString *)mediaShareId andCompleteBlock:(QuickUploaderCompleteBlock)block;

-(void)startWithPatch:(NSString *)patchId andCompleteBlock:(QuickUploaderCompleteBlock)block;
@end
