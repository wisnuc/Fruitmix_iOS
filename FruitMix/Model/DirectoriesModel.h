//
//  DirectoriesModel.h
//  FruitMix
//
//  Created by wisnuc on 2017/8/18.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DirectoriesModel : NSObject
@property (nonatomic,copy) NSString *uuid;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *parent;
@property (nonatomic) long long mtime;
@property (nonatomic)NSString *tag;
@property (nonatomic,copy) NSString *type;

@end
