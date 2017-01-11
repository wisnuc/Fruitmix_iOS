//
//  FMComment.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/27.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMDTObject.h"
#import "FMCommentsProtocol.h"

@interface FMComment : FMDTObject<FMCommentsProtocol>

@property (nonatomic) NSString * creator;
@property (nonatomic) long long datatime;
//@property (nonatomic) NSString * receiver;
//@property (nonatomic) NSString * hostmediafilehashid;
//@property (nonatomic) NSString * createtime;

@property (nonatomic) NSString * shareid;

@property (nonatomic) NSString * text;//内容

@end
