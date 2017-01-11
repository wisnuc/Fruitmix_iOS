//
//  FMShareImagesCell.m
//  FruitMix
//
//  Created by 杨勇 on 16/5/3.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMShareImagesCell.h"

@interface FMShareImagesCell ()<FMShareSetItemDelegate>



@end

@implementation FMShareImagesCell{
    UIView * _countView;
    UILabel * _countLb;
    UIView * _lineView;
    UIButton * _moreImageBtn;
}

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
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (self.model) {
        self.headView.nameLabel.text = [FMConfigInstance getUserNameWithUUID:self.model.author];
        self.headView.timeLabel.text = [self getDateStringWithShareDate:[NSDate dateWithTimeIntervalSince1970:self.model.getTime/1000]];
        self.headView.userHeadView.image = [UIImage imageForName:self.headView.nameLabel.text size:self.headView.userHeadView.bounds.size];
        self.itemsView.frame = CGRectMake(0, _headView.jy_Bottom, _shareContentView.jy_Width, [FMShareSetItem getHeightWithModel:self.model]);
        self.itemsView.share = self.model;
        NSString * a = [NSString stringWithFormat:@"分享了%lu张图片",(unsigned long)self.model.getAllContents.count];
        NSRange range = NSMakeRange(0, 3);
        NSRange range2 = [a rangeOfString:@"张图片"];
//        NSRange range3 = [a rangeOfString:@"个视频"];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"分享了%lu张图片",(unsigned long)self.model.getAllContents.count]];
        [str addAttribute:NSForegroundColorAttributeName value:UICOLOR_RGB(0x9a9a9a) range:range];
        [str addAttribute:NSForegroundColorAttributeName value:UICOLOR_RGB(0x9a9a9a) range:range2];
//        [str addAttribute:NSForegroundColorAttributeName value:UICOLOR_RGB(0x9a9a9a) range:range3];
        
        _countView.frame = CGRectMake(0, self.itemsView.jy_Bottom, _itemsView.jy_Width, 46.5);
        
        _countLb.frame = CGRectMake(20, 0, _countView.jy_Width-120, _countView.jy_Height-2);
        _countLb.attributedText = str;
        
        
        if (self.model.getAllContents.count>9) {
            _moreImageBtn.hidden = NO;
            _moreImageBtn.frame = CGRectMake(_countView.jy_Width - 100, 0, 100, _countView.jy_Height-2);
            [_moreImageBtn setTitle:@"查看更多照片" forState:UIControlStateNormal];
            [_moreImageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            _moreImageBtn.titleLabel.font = [UIFont fontWithName:DONGQING size:14];
            [_moreImageBtn addTarget:self action:@selector(didSelectTalkButton:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            _moreImageBtn.hidden = YES;
        }
        
//        _lineView.frame = CGRectMake(0, _countView.jy_Height- 0.5, _countView.jy_Width, 0.5);
        
//        self.likeView.frame = CGRectMake(0, _countView.jy_Bottom, _countView.jy_Width, 46.5);
    }
    _shareContentView.jy_Height = _countView.jy_Bottom + 12.5;
}

-(void)initView{
    self.contentView.backgroundColor =  UICOLOR_RGB(0xe2e2e2);
    _shareContentView  = [[UIView alloc] initWithFrame:CGRectMake(5, 12.5, __kWidth - 10, 100)];
    _shareContentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_shareContentView];
    
    self.headView = [FMShareHeadView fmHeadViewWithModel:nil];
    [_shareContentView addSubview:self.headView];
    
    self.itemsView = [[FMShareSetItem alloc]initWithFrame:CGRectMake(0, _headView.jy_Bottom, _shareContentView.jy_Width, 200)];
    self.itemsView.fmDelegate = self;
    [_shareContentView addSubview:_itemsView];
    
    _countView = [[UIView alloc]init];
    _countView.backgroundColor = [UIColor whiteColor];
    
    UILabel * countLb = [[UILabel alloc]init];
    countLb.textColor = UICOLOR_RGB(0x404040);
    countLb.font = [UIFont fontWithName:DONGQING size:14];
    _countLb = countLb;
    [_countView addSubview:countLb];
    
    UIView * lineView = [[UIView alloc]init];
    lineView.backgroundColor = UICOLOR_RGB(0xe0e0e0);
    _lineView = lineView;
    [_countView addSubview:lineView];
    
    UIButton * moreImageBtn = [[UIButton alloc] init];
    _moreImageBtn = moreImageBtn;
    [_countView addSubview:moreImageBtn];
    
    [_shareContentView addSubview:_countView];
    
    
    
    
//    self.likeView = [FMShareLikeView fmShareLikeViewWithModel:nil andFrame:CGRectMake(0, self.itemsView.jy_Bottom, _itemsView.jy_Width, 46.5)];
//    
//    
//    
//    
//    [_likeView.likeBtn setImage:[UIImage imageNamed:@"album_praise"] forState:UIControlStateNormal];
//    [_likeView.talkBtn setImage:[UIImage imageNamed:@"album_comment"] forState:UIControlStateNormal];
//    [self.likeView.likeBtn addTarget:self action:@selector(didSelectLikeButton:) forControlEvents:UIControlEventTouchUpInside];
//    [self.likeView.talkBtn addTarget:self  action:@selector(didSelectTalkButton:) forControlEvents:UIControlEventTouchUpInside];
//    [_shareContentView addSubview:self.likeView];
    
    _shareContentView.jy_Height = _countView.jy_Bottom + 12.5;
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
//    CGFloat talkViewH = [FMShareTalkView getHeightWithModel:model];
    CGFloat itemsViewH = [FMShareSetItem getHeightWithModel:model];
    
    //    CGFloat i = model.imageW/(__kWidth-FMPadding);
    //    CGFloat imageH = model.imageH/i;
    
    return  headViewH+itemsViewH+35+46.5;
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

-(void)fmSet_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate && [self.delegate respondsToSelector:@selector(fm_collectionView:didSelectItemAtIndexPath:)]) {
        [self.delegate fm_collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}

-(NSString *)getDateStringWithShareDate:(NSDate *)date{
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy年MM月dd日hh时mm分";
//    [formatter1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSString * dateString = [formatter1 stringFromDate:date];
    return dateString;
}


@end
