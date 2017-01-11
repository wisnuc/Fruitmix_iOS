//
//  FMShareAlbumCell.m
//  FruitMix
//
//  Created by 杨勇 on 16/5/3.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMShareAlbumCell.h"

@interface FMShareAlbumCell ()
@property (nonatomic) UIImageView * coverImageView;

@property (nonatomic) UIImageView * biaozhiIV;
@end

@implementation FMShareAlbumCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
    }
    return self;
}

- (void)setModel:(id<FMMediaShareProtocol>)model{
    _model = model;
    [self setNeedsLayout];
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.shareImage.image = nil;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (self.model) {
        self.headView.nameLabel.text = [FMConfigInstance getUserNameWithUUID:self.model.author];
        self.headView.timeLabel.text = [self getDateStringWithShareDate:[NSDate dateWithTimeIntervalSince1970:self.model.getTime/1000]];
        self.headView.userHeadView.image = [UIImage imageForName:self.headView.nameLabel.text size:self.headView.userHeadView.bounds.size];
        self.shareImage.jy_Height = [self.delegate shareCellGetImageSize:self].height;
        if (self.model.getAllContents.count>0) {
            //取出相册第一张当封面
//            NSString * digest = ((FMShareAlbumItem *)self.model.getAllContents[0]).digest;
//            if ([PhotoManager managerCheckIfIsLocalPhoto:digest]) {
//                [[FMGetImage defaultGetImage] getOriginalImageWithLocalhash:digest andCompleteBlock:^(UIImage *image, NSString *tag) {
//                    self.shareImage.image = image;
//                }];
//            }else{
//                [[FMGetImage defaultGetImage] getOriginalImageWithHash:digest andCount:0 andPressBlock:nil andCompletBlock:^(UIImage *image, NSString *tag) {
//                    self.shareImage.image = image;
//                }];
//            }
        }
    }
    
    _coverImageView.frame = CGRectMake(0, _shareImage.jy_Height - 50, _shareImage.jy_Width, 50);
    _coverImageView.image = [UIImage imageNamed:@"mask-layer"];
    _biaozhiIV.frame = CGRectMake(10, self.shareImage.jy_Height-30, 20, 20);
    _biaozhiIV.image = [UIImage imageNamed:@"album_share"];

#warning handle tags
//    if (_model.tags.count) {
//        NSDictionary * dic = _model.tags[0];
//        NSString * nameAndCount = [NSString stringWithFormat:@"%@·%ld张",dic[@"albumname"],(unsigned long)self.model.getAllContents.count];
//        self.nameAndCountLb.text = nameAndCount;
//        self.nameAndCountLb.frame = CGRectMake(40, self.shareImage.jy_Height-30, self.shareImage.jy_Width - 40, 20);
//    }
    
//    self.likeView.frame = CGRectMake(0, self.shareImage.jy_Bottom, _shareImage.jy_Width, 46.5);
    _shareContentView.jy_Height = _shareImage.jy_Bottom + 12.5;
}

-(NSString *)getDateStringWithShareDate:(NSDate *)date{
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy年MM月dd日hh时mm分";
//    [formatter1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString * dateString = [formatter1 stringFromDate:date];
    return dateString;
}
-(void)initView{
    
    self.contentView.backgroundColor =  UICOLOR_RGB(0xe2e2e2);
    _shareContentView  = [[UIView alloc] initWithFrame:CGRectMake(5, 12.5, __kWidth - 10, 100)];
    _shareContentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_shareContentView];
    
    self.headView = [FMShareHeadView fmHeadViewWithModel:nil];
    [_shareContentView addSubview:self.headView];
    
    self.shareImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, _headView.jy_Bottom, _shareContentView.jy_Width, 200)];
    self.shareImage.contentMode = UIViewContentModeScaleAspectFill;
    self.shareImage.clipsToBounds = YES;
    [_shareContentView addSubview:_shareImage];
    
    //添加遮盖
    UIImageView * imageView = [[UIImageView alloc]init];
    [self.shareImage addSubview:imageView];
    _coverImageView = imageView;
    
    _biaozhiIV = [[UIImageView alloc]init];
    [self.shareImage addSubview:_biaozhiIV];
    
    self.nameAndCountLb = [[UILabel alloc]initWithFrame:CGRectMake(20, self.shareImage.jy_Height-30, self.shareImage.jy_Width - 20, 20)];
    self.nameAndCountLb.font = [UIFont fontWithName:DONGQING size:18];
    self.nameAndCountLb.textColor = [UIColor whiteColor];
    [self.shareImage addSubview:self.nameAndCountLb];
    
//    self.likeView = [FMShareLikeView fmShareLikeViewWithModel:nil andFrame:CGRectMake(0, self.shareImage.jy_Bottom, _shareImage.jy_Width, 46.5)];
//    [_likeView.likeBtn setImage:[UIImage imageNamed:@"album_praise"] forState:UIControlStateNormal];
//    [_likeView.talkBtn setImage:[UIImage imageNamed:@"album_comment"] forState:UIControlStateNormal];
//    [self.likeView.likeBtn addTarget:self action:@selector(didSelectLikeButton:) forControlEvents:UIControlEventTouchUpInside];
//    [self.likeView.talkBtn addTarget:self  action:@selector(didSelectTalkButton:) forControlEvents:UIControlEventTouchUpInside];
//    [_shareContentView addSubview:self.likeView];
    
    _shareContentView.jy_Height = _shareImage.jy_Bottom + 12.5;
    _shareContentView.layer.cornerRadius = 4;
    _shareContentView.layer.masksToBounds = YES;
    
//    _shareContentView.layer.shadowColor = [[UIColor blackColor]CGColor];
//    _shareContentView.layer.shadowOffset = CGSizeMake(0, -2);
//    _shareContentView.layer.shadowRadius = 5.0;
//    _shareContentView.layer.shadowOpacity = 0.8;
}



+(CGFloat)getHeightWithModel:(id<FMMediaShareProtocol>)model{
    
    CGFloat headViewH = 97/2;
//    CGFloat likeViewH = 46.5;
    //    CGFloat i = model.imageW/(__kWidth-FMPadding);
    //    CGFloat imageH = model.imageH/i;
    return  headViewH+(__kWidth/4*3)+35;
}

#pragma mark - FMShareLikeViewDelegate
-(void)didSelectLikeButton:(UIButton *)button{
    NSLog(@"woxihuan");
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareCell:didSelectLikeBtn:)]) {
        [self.delegate shareCell:self didSelectLikeBtn:button];
    }
}

-(void)didSelectTalkButton:(UIButton *)button{
    NSLog(@"我想说话");
    if (self.delegate && [self.delegate respondsToSelector:@selector(shareCell:didSelectTalkBtn:)]) {
        [self.delegate shareCell:self didSelectTalkBtn:button];
    }
}
@end
