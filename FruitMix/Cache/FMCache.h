//
//  FMCache.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/25.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>
#define Cache [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define CachePath [NSString stringWithFormat:@"%@/%@", Cache, @"FMThumbImage"]
@interface FMCache : NSObject
/**
 *  写入文件
 *
 *  @param image
 *  @param lId
 */
+(void)saveImage:(UIImage *)image WithLocalId:(NSString *)lId;
/**
 *  文件是否存在
 *
 *  @param path
 *
 *  @return
 */
+(BOOL)isFileExist:(NSString *)path;
/**
 *  拿图片
 *
 *  @param lId
 *
 *  @return
 */
+(UIImage *)getImageWithLocalId:(NSString *)lId;

+(void)savedata:(NSData *)data WithLocalId:(NSString *)lId;
@end
