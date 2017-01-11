//
//  FMNeedUploadMediaShare.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/26.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMDTObject.h"
#import "FMMediaShareProtocol.h"
#define LOCAL_MEDIA_SHARE @"local_mediashare"

@interface FMNeedUploadMediaShare : FMDTObject<FMMediaShareProtocol>

@property (nonatomic) NSString * uuid;

@property (nonatomic) NSString * netShareId;//net id  in nas


@property (nonatomic) NSNumber * isAlbum; //是否为album

@property (nonatomic) NSArray * contents;

@property (nonatomic) NSArray * viewers;

@property (nonatomic) NSArray * maintainers;

@property (nonatomic) NSString * author;

@property (nonatomic) NSDictionary * album;

//hash
@property (nonatomic) NSArray * netPhotos;
//hash
@property (nonatomic) NSArray * localPhotos;

@property (nonatomic) long long uploadTime;

@property (nonatomic) long long createDate;

/**
 *  has nil 、uploaded 、failed 、 notfound 、 jumpvideo
 */
@property (nonatomic) NSString * state;

-(NSArray *)getUploadContents;
@end
