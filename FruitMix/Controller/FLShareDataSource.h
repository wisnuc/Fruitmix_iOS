//
//  FLShareDataSource.h
//  FruitMix
//
//  Created by 杨勇 on 16/10/9.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FLShareDataSourceDelegate <NSObject>

-(void)shareDataSourceLoadingComplete:(BOOL)complete;

@end

@interface FLShareDataSource : NSObject

@property (nonatomic,weak) id<FLShareDataSourceDelegate> delegate;

@property (nonatomic) NSMutableArray * dataSource;

@end
