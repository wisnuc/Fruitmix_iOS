//
//  FMCommentCell.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/29.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMCommentCell.h"

@interface FMCommentCell ()
@property (weak, nonatomic) IBOutlet UIImageView *commentAuthorIcon;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLikesCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;

@property (nonatomic) FMComment *comment;
@end

static CGFloat kPaddingDist = 8.0f;
static CGFloat kDefaultCommentCellHeight = 40.0f;
static CGFloat kTableViewWidth = -1;
static CGFloat kStandardButtonSize = 40.0f;
static CGFloat kStandardLabelHeight = 20.0f;

#define kCommentCellFont  [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:14]

@implementation FMCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews
{
    NSString *comment = self.comment.text;
    CGFloat cellHeight = [FMCommentCell heightForComment:comment];
    CGRect frame = self.commentLabel.frame;
    frame.size.height = cellHeight;
    self.commentLabel.frame = frame;
    
    frame = self.commentDateLabel.frame;
    frame.origin.x = self.commentAuthorIcon.frame.origin.x + self.commentAuthorIcon.frame.size.width + kPaddingDist;
    frame.origin.y = self.commentLabel.frame.origin.y + self.commentLabel.frame.size.height + kPaddingDist;
    self.commentDateLabel.frame = frame;
    
    frame = self.commentsLikesCountLabel.frame;
    frame.origin.x = self.likeButton.frame.origin.x - kPaddingDist - self.commentsLikesCountLabel.frame.size.width;
    frame.origin.y = self.commentDateLabel.frame.origin.y;
    self.commentsLikesCountLabel.frame = frame;
    
    frame = self.likeButton.frame;
    frame.origin.y = self.contentView.frame.origin.y + self.contentView.frame.size.height - frame.size.height - kPaddingDist;
    self.likeButton.frame = frame;
    [super layoutSubviews];
}

#pragma mark -
#pragma mark Interface

+ (void)setTableViewWidth:(CGFloat)tableWidth
{
    kTableViewWidth = tableWidth;
}

+ (id)storyCommentCellForTableWidth:(CGFloat)width
{
    FMCommentCell *cell = [[FMCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    
    CGRect cellFrame = cell.frame;
    cellFrame.size.width = width;
    cell.frame = cellFrame;
    
    //Left AuthorIconView
    UIImageView *authOrIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingDist, kPaddingDist, kStandardButtonSize, kStandardButtonSize)];
    authOrIconView.image = [UIImage imageNamed:@"head-portrait"];
    authOrIconView.contentMode = UIViewContentModeScaleAspectFill;
    authOrIconView.layer.cornerRadius = kStandardButtonSize/2;
    authOrIconView.layer.masksToBounds = YES;
    [cell addSubview:authOrIconView];
    cell.commentAuthorIcon = authOrIconView;
    
    //Like Button
//    UIButton *likeButton = [[UIButton alloc] initWithFrame:CGRectMake(cell.bounds.size.width - (kPaddingDist + kStandardButtonSize), kPaddingDist, kStandardButtonSize, 38)];
//    [likeButton setImage:[UIImage imageNamed:@"likeIcon"] forState:UIControlStateNormal];
//    [cell addSubview:likeButton];
//    cell.likeButton = likeButton;
    
    
    //Comment Label
    CGRect labelRect = CGRectMake(authOrIconView.frame.origin.x + authOrIconView.frame.size.width + kPaddingDist,
                                  authOrIconView.frame.origin.y,
                                  kTableViewWidth - authOrIconView.jy_Right - 3*kPaddingDist,
                                  kStandardLabelHeight);
    UILabel *commentlabe = [[UILabel alloc] initWithFrame:labelRect];
    commentlabe.font = kCommentCellFont;
    commentlabe.textColor = [UIColor darkGrayColor];
    commentlabe.textAlignment = NSTextAlignmentLeft;
    commentlabe.numberOfLines = 0;
    commentlabe.lineBreakMode = NSLineBreakByWordWrapping;
    commentlabe.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cell.commentLabel = commentlabe;
    [cell addSubview:commentlabe];
    
    //commentDateLabel;
    UILabel *commentDatelabe = [[UILabel alloc] initWithFrame:CGRectMake(commentlabe.frame.origin.x, commentlabe.frame.origin.y + commentlabe.frame.size.height + kPaddingDist, commentlabe.frame.size.width, commentlabe.frame.size.height)];
    commentDatelabe.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:10];
    commentDatelabe.textColor = [UIColor grayColor];
    commentDatelabe.textAlignment = NSTextAlignmentLeft;
    cell.commentDateLabel = commentDatelabe;
    [cell addSubview:commentDatelabe];
    
    return cell;
}

+ (CGFloat)cellHeightForComment:(NSString *)comment
{
    return kDefaultCommentCellHeight + [FMCommentCell heightForComment:comment];
}

+ (CGFloat)heightForComment:(NSString *)comment
{
    CGFloat height = 0.0;
    CGFloat commentlabelWidth = kTableViewWidth - 1 * (kStandardButtonSize + kPaddingDist);
    CGRect rect = [comment boundingRectWithSize:(CGSize){commentlabelWidth, MAXFLOAT}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:kCommentCellFont}
                                        context:nil];
    height = rect.size.height;
    return height;
}

- (void)configureCommentCellForComment:(FMComment *)comment
{
    self.comment = comment;
    NSString * username = [FMConfigInstance getUserNameWithUUID:comment.creator];
    self.commentAuthorIcon.image = [UIImage imageForName:username size:self.commentAuthorIcon.bounds.size];
    NSString * com = [NSString stringWithFormat:@"%@:%@",username,comment.text];
    NSRange range = [com   rangeOfString:username];
    NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc] initWithString:com];
    [attStr addAttribute:NSForegroundColorAttributeName value:UICOLOR_RGB(0xf57c00) range:range];
    
    
    self.commentLabel.attributedText = attStr;
    self.commentDateLabel.text = [self getDateStringWithShareDate:[NSDate dateWithTimeIntervalSince1970:comment.datatime/1000]];
//    self.commentsLikesCountLabel.text = comment[kLikesCountKey];
    
    [self setNeedsLayout];
}
-(NSString *)getDateStringWithShareDate:(NSDate *)date{
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy年MM月dd日 HH:mm:ss";
    NSString * dateString = [formatter1 stringFromDate:date];
    return dateString;
}



@end
