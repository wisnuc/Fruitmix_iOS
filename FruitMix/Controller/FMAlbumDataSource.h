//
//  FMAlbumDataSource.h
//  FruitMix
//
//  Created by 杨勇 on 16/9/23.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FMAlbumDataSourceDelegate <NSObject>

-(void)albumDataSourceDidChange;

@end

@interface FMAlbumDataSource : NSObject

@property (nonatomic) id<FMAlbumDataSourceDelegate> delegate;

@property (nonatomic) NSMutableArray * dataSource;

//share or private
+(void)updateAlbum:(id<FMMediaShareProtocol>)album andComPleteBlock:(void(^)(BOOL success,BOOL isShare))block;

//删除 share
+(void)deleteAlbum:(id<FMMediaShareProtocol>)album andComPleteBlock:(void(^)(BOOL success))block;

//修改内容
+(void)editContentsAlbum:(id<FMMediaShareProtocol>)album adds:(NSArray *)adds removes:(NSArray *)removes andComPleteBlock:(void(^)(BOOL success))block;

+(void)createAlbumWithMaintainers:(NSArray *)maintainers Viewers:(NSArray *)viewers Contents:(NSArray *)contents IsAlbum:(NSDictionary *)album andComPleteBlock:(void(^)(BOOL success))block;

//编辑相册
+(void)updateAlbum:(id<FMMediaShareProtocol>)album andAlbum:(NSDictionary *)albumDic andIsPublic:(BOOL)isPublic andCanAdd:(BOOL)canAdd andComPleteBlock:(void (^)(BOOL success))block;
@end
