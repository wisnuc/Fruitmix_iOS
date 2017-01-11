//
//  FMSharesCell.h
//  FruitMix
//
//  Created by 杨勇 on 16/7/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMTimeLabel.h"
#import "FMStatusLayout.h"
#import "FMShareScrollComment.h"

@class FMSharesCell;
@protocol FMSharesCellDelegate;
@interface FMShareHeaderView : UIView

@property (nonatomic, strong) UIImageView *avatarView; ///< 头像
@property (nonatomic, strong) UILabel *nameLabel;//用户名
@property (nonatomic, strong) FMTimeLabel *timeLabel;//发布时间
@property (nonatomic, weak) FMSharesCell * cell;

@end



@interface FMStatusTalkView : UIView

@property (nonatomic, weak) FMSharesCell * cell;
@property (nonatomic, strong) UILabel * imgCountLabel;
@property (nonatomic, strong) FMShareScrollComment * commentView;
@property (nonatomic, strong) UIButton * talkBtn;
@property (nonatomic, strong) UILabel * talkCountLb;
@property (nonatomic, strong) UIButton * moreImgBtn;//查看更多
@end


@interface FMStatusView : UIView

@property (nonatomic, strong) UIView *contentView;//容器
@property (nonatomic, strong) FMShareHeaderView *headerView;//头像及用户名区域
@property (nonatomic, strong) NSArray<UIView *> *picViews;      // 图片
@property (nonatomic, strong) FMStatusTalkView *talkView;
@property (nonatomic, weak) FMSharesCell * cell;
@property (nonatomic, strong) FMStatusLayout *layout;

@end


@interface FMSharesCell : UITableViewCell<IDMPhotoBrowserDelegate>

@property (nonatomic, weak) id<FMSharesCellDelegate> delegate;
@property (nonatomic, strong) FMStatusLayout * layout;
@property (nonatomic) FMSharesCellType cellType;//cell的类型
@property (nonatomic, strong) FMStatusView *statusView;
- (void)setLayout:(FMStatusLayout *)layout;
@end



@protocol FMSharesCellDelegate <NSObject>

@optional
/// 点击了 Cell
- (void)cellDidClick:(FMSharesCell *)cell;
/// 点击了评论
- (void)cellDidClickComment:(FMSharesCell *)cell;
/// 点击了图片
- (void)cell:(FMSharesCell *)cell didClickImageAtIndex:(NSUInteger)index;

/// 点击了 Cell 查看更多按钮
- (void)cellDidClickReadMore:(FMSharesCell *)cell;
@end

