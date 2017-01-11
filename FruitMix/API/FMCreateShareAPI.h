//
//  FMCreateShareAPI.h
//  FruitMix
//
//  Created by 杨勇 on 16/9/21.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"

@interface FMCreateShareAPI : JYBaseRequest

@property (nonatomic) NSDictionary * param;

/**
 *  创建分享
 *
 *  @param maintainers 可修改人
 *  @param viewers     可查看人
 *  @param content     内容
 *  @param album       nil为不是album dic中包含albumname desipation
 *
 *  @return api instance
 */
+(instancetype)shareCreateWithMaintainers:(NSArray *)maintainers
                                  Viewers:(NSArray *)viewers
                                 Contents:(NSArray *)content
                                  IsAlbum:(NSDictionary *)album;

@end
