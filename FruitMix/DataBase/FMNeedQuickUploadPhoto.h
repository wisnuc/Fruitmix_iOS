//
//  FMNeedQuickUploadPhoto.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/26.
//  Copyright © 2016年 WinSun. All rights reserved.
//



#import "FMDTObject.h"

FOUNDATION_EXPORT NSString * const NOT_FOUND;
FOUNDATION_EXPORT NSString * const FAILED;
FOUNDATION_EXPORT NSString * const UPLOADED;
FOUNDATION_EXPORT NSString * const JUMP_VIDEO;
FOUNDATION_EXPORT NSString * const UNUPLOAD;



@interface FMNeedQuickUploadPhoto : FMDTObject

@property (nonatomic) NSString * needUploadDigest;

@property (nonatomic) NSString * needUploadLocalId;

@property (nonatomic) NSString * needUploadShareId;

/**
 *  has nil 、uploaded 、failed 、 notfound 、 jumpvideo
 */
@property (nonatomic) NSString * state;

@end

