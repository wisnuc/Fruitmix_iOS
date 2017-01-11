//
//  FLDataSource.h
//  FruitMix
//
//  Created by 杨勇 on 16/9/2.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLFilesModel.h"

@class FLDataSource;
@protocol FLDataSourceDelegate <NSObject>

-(void)fl_Datasource:(FLDataSource *)datasource finishLoading:(BOOL)finish;

@end

@interface FLDataSource : NSObject

@property (nonatomic) NSMutableArray * dataSource;


@property (nonatomic,weak) id<FLDataSourceDelegate> delegate;

-(instancetype)initWithFileUUID:(NSString *)uuid;

@end
