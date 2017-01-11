//
//  FMStatusLayout.h
//  FruitMix
//
//  Created by 杨勇 on 16/7/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

// 宽高
#define kSharesCellTopMargin 5     // cell 顶部灰色留白
//#define kShareCellTop
#define kSharesCellHeaderHeight 72   // cell header高度
#define kSharesCellNamePaddingLeft 14 // cell 名字和 avatar 之间留白
#define kSharesCellContentWidth (__kWidth - 2 * kSharesCellPaddingIMG) // cell 内容宽度
#define kSharesCellDefaultHeight kSharesCellContentWidth/3*2 //默认的图片区域高度
#define kSharesCellPaddingPic 2     // cell 多张图片中间留白

#define kSharesCellPaddingIMG 8

#define FMSharesAvatarViewWidth 40 // 用户头像
#define FMSharesAvaterViewLeft 16
#define FMSharesAvaterViewTop 16

#define FMShareHeaderNameLabelLeft FMSharesAvaterViewLeft+FMSharesAvatarViewWidth+8


#define FMSharesTalkViewTypeSetH 46 
#define FMSharesTalkViewTypeAlbumH 16
#define FMSharesTalkViewTypePhotoH 60;


typedef enum : NSUInteger {
    FMSharesTypePhoto = 0,
    FMSharesTypeSet,
    FMSharesTypeAlbum,
} FMSharesCellType;

@interface FMStatusLayout : NSObject

- (instancetype)initWithStatus:(id<FMMediaShareProtocol>)status;
- (void)layout; ///< 计算布局

//以下是数据
@property (nonatomic, strong) id<FMMediaShareProtocol> status;

@property (nonatomic ,assign) FMSharesCellType cellType;

//以下是布局结果

// 顶部留白
@property (nonatomic, assign) CGFloat marginTop; //顶部灰色留白

//顶部用户头像，用户名，用户发布时间
@property (nonatomic, assign) CGFloat headerHeight;

// 图片
@property (nonatomic, assign) CGFloat picHeight; //图片高度，0为没图片
@property (nonatomic, assign) CGSize picSize;

// 工具栏
@property (nonatomic, assign) CGFloat talkViewHeight; // 工具栏

// 下边留白
@property (nonatomic, assign) CGFloat marginBottom; //下边留白

// 总高度
@property (nonatomic, assign) CGFloat height;

@end
