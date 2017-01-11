//
//  FLShareModel.h
//  FruitMix
//
//  Created by 杨勇 on 16/10/9.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLShareModel : NSObject

@property (nonatomic) NSString * uuid;

@property (nonatomic) NSString * type;

@property (nonatomic) NSArray * owner;

@property (nonatomic) NSArray * writelist;

@property (nonatomic) NSArray * readlist;

@property (nonatomic) NSString * root;

@property (nonatomic) NSString * name;

@property (nonatomic) BOOL  isFile;

@end
