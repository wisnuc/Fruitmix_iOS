//
//  FMNeedUploadComments.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/26.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMDTObject.h"
#import "FMCommentsProtocol.h"

@interface FMNeedUploadComments : FMDTObject<FMCommentsProtocol>

@property (nonatomic) NSString * shareid;

@property (nonatomic) NSString * photoDigest;

@property (nonatomic) NSString * text;

@property (nonatomic) NSString * creator;

@property (nonatomic) long long createDate;

@property (nonatomic) long long uploadTime;

@property (nonatomic) NSString * commentId;
@end
