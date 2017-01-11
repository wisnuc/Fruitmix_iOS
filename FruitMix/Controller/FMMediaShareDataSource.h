//
//  FMMediaShareDataSource.h
//  FruitMix
//
//  Created by 杨勇 on 16/9/20.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ShareDataSourceDelegate <NSObject>

-(void)shareDataSourceDidUpdate;

@end

@interface FMMediaShareDataSource : NSObject

@property (nonatomic,weak) id<ShareDataSourceDelegate> delegate;

@property (nonatomic) NSMutableArray * dataSource;

+(instancetype)sharedDataSource;

//TODO  update dataSource
-(void)refreshData;
@end
