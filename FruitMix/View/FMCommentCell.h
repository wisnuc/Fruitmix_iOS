//
//  FMCommentCell.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/29.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *kCommentsKey   = @"Comments";
static NSString *kCommentKey    = @"Comment";
static NSString *kTimeKey       = @"Time";
static NSString *kLikesCountKey = @"LikesCount";

static NSString *kCellIdentifier = @"storyCellId";

@interface FMCommentCell : UITableViewCell

+ (void)setTableViewWidth:(CGFloat)tableWidth;
+ (id)storyCommentCellForTableWidth:(CGFloat)width;
+ (CGFloat)cellHeightForComment:(NSString *)comment;
- (void)configureCommentCellForComment:(FMComment *)comment;
@end
