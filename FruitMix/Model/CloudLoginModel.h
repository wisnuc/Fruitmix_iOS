//
//  CloudLoginModel.h
//  FruitMix
//
//  Created by wisnuc-imac on 2017/9/27.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMBaseModel.h"

@interface CloudLoginModel : FMBaseModel
@property(nonatomic)NSDictionary *data;
@property(nonatomic)NSString *id;
@property(nonatomic)NSNumber* isOnline;
@property(nonatomic)NSString* name;
@end
