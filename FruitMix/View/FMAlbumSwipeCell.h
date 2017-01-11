//
//  FMAlbumSwipeCell.h
//  FruitMix
//
//  Created by 杨勇 on 16/8/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"

@interface FMAlbumSwipeCell : MGSwipeTableCell


@property (nonatomic) UIImageView * albumFaceImageView;//封面图
@property (nonatomic) UIImageView * lockView;//上锁图
@property (nonatomic) UILabel * albumNameAndNumLb; //album 的名字和数量label
@property (nonatomic) UILabel * descriptionlb;
@property (nonatomic) UILabel * timeLb;

@property (nonatomic) BOOL isShare;

@property (nonatomic) BOOL hasDesc;

@property (nonatomic) NSString * imgTag;
@end
