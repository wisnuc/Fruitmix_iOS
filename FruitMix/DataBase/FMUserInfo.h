//
//  FMUserInfo.h
//  FruitMix
//
//  Created by 杨勇 on 16/12/30.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMDTObject.h"

@interface FMUserInfo : FMDTObject

@property (nonatomic) NSString * userId; //User UUID

@property (nonatomic) NSString * deviceId; //Device ID

@property (nonatomic) NSString * home; // Home ID

@property (nonatomic) NSString * library; //Libruary ID

@end
