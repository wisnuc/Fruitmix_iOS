//
//  FMGetCommentsAPI.h
//  FruitMix
//
//  Created by 杨勇 on 16/5/26.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"

@interface FMGetCommentsAPI : JYBaseRequest

@property (nonatomic) NSString * hashid;

+(FMGetCommentsAPI *)apiWithPhotoHash:(NSString *)hash;

@end
