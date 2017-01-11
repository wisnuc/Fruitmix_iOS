//
//  FMUpdateShareTool.h
//  FruitMix
//
//  Created by 杨勇 on 16/9/21.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GetShareCompleteBlock)(NSArray * shares);

@interface FMUpdateShareTool : NSObject

+(instancetype)shareInstance;

/**
 *  更新mediafile
 */
+(void)updateMediaSharesWithCompleteBlock:(void(^)(BOOL shouldUpdate))block;

/**
 *  更新Media数据
 */
//+(void)asycMediaPhotos;
/**
 *  media需要强制更新
 */
//+(void)mediaShareNeedUpdate;

+(void)getMediaShares:(GetShareCompleteBlock)block;

@end
