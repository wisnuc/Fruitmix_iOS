//
//  FMPostNewShareAPI.h
//  FruitMix
//
//  Created by 杨勇 on 16/5/5.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"

@interface FMPostNewShareAPI : JYBaseRequest

@property (nonatomic) NSDictionary * param;

-(instancetype)initWithContents:(id)contents
                       andAlbum:(NSString *)isAlbum
                 andMaintainers:(NSArray *)arr
                     andViewers:(NSArray *)viewers
                        andTags:(NSArray *)tags;
/**
 *  创建分享照片
 *
 */
+(void)fm_PostPhotosWithArray:(NSArray *)arr;
/**
 *  创建可分享相册
 *
 */
+(void)fm_PostAlbumWithArray:(NSArray *)arr andName:(NSString *)name andDesc:(NSString *)desc andIsPublic:(BOOL)isPublic andCanEdit:(BOOL)canEdit;

@end
