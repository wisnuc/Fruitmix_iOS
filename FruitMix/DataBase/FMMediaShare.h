//
//  FMMediaShare.h
//  FruitMix
//
//  Created by 杨勇 on 16/5/26.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMDTObject.h"
#import "FMMediaShareProtocol.h"

@interface FMMediaShare : FMDTObject<FMMediaShareProtocol>


@property (nonatomic) NSString * digest;

@property (nonatomic) NSString * doctype;
@property (nonatomic) NSString * docversion;

@property (nonatomic) NSString * uuid;
@property (nonatomic) NSString * author;
@property (nonatomic) NSNumber * sticky;

@property (nonatomic) long long mtime;
@property (nonatomic) long long ctime;

@property (nonatomic) NSDictionary * album;//相册名 相册描述

@property (nonatomic) NSArray * contents;
@property (nonatomic) NSArray * viewers;
@property (nonatomic) NSArray * maintainers;

@property (nonatomic) NSNumber * isAlbum; //是否为album

-(BOOL)isEqualToMediaShare:(FMMediaShare *)share;

@end
