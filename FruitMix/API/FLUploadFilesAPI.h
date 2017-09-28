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
@property (nonatomic) NSString *photoName;
@property (nonatomic) NSString *sha256;
@property (nonatomic) NSInteger size;
+(instancetype)apiWithPhotoUUID:(NSString *)photoUUID PhotoName:(NSString *)photoName Hash:(NSString *)sha256 Size:(NSInteger)size;
@end
