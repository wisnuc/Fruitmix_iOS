//
//  FLUploadFilesAPI.h
//  FruitMix
//
//  Created by wisnuc-imac on 2017/9/26.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"

@interface FLUploadFilesAPI : JYBaseRequest
@property (nonatomic) NSString * photouuid;
+(instancetype)apiWithPhotoUUID:(NSString *)photoUUID;
@end
