//
//  FMAlbumSwipeCell.m
//  FruitMix
//
//  Created by 杨勇 on 16/8/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMAlbumSwipeCell.h"
#import "UIColor+fm_color.h"

@interface FMAlbumSwipeCell ()
@property (nonatomic) UIImageView * maskLayer;
@end

@implementation FMAlbumSwipeCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self){
        _isShare = YES;
        //initUI
        _albumFaceImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _lockView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _maskLayer = [[UIImageView alloc] initWithFrame:CGRectZero];
        _albumNameAndNumLb = [[UILabel alloc]initWithFrame:CGRectZero];
        _descriptionlb = [[UILabel alloc]initWithFrame:CGRectZero];
        _timeLb = [[UILabel alloc] initWithFrame:CGRectZero];
        
    }
    
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];    
    _albumFaceImageView.frame = CGRectMake(0, 0, __kWidth * 0.43, 110);
    _albumFaceImageView.contentMode = UIViewContentModeScaleAspectFill;
    _albumFaceImageView.clipsToBounds = YES;
    [self.jy_contentView addSubview:_albumFaceImageView];
    
    
    _maskLayer.frame = CGRectMake(0, _albumFaceImageView.jy_Height - 7 - 41/2, _albumFaceImageView.jy_Width, 41/2 + 7);
    _maskLayer.image = [UIImage imageNamed:@"mask-layer"];
    [_albumFaceImageView addSubview:_maskLayer];
    
    _lockView.frame = CGRectMake(7, _albumFaceImageView.jy_Height - 7 - 41/2, 18, 41/2);
    _lockView.image = [UIImage imageNamed:@"share_photo"];
    [_albumFaceImageView addSubview:_lockView];
    
    _albumNameAndNumLb.frame = CGRectMake(_albumFaceImageView.jy_Width + 12, 27, self.jy_contentView.jy_Width - _albumFaceImageView.jy_Width - 15, 16);
    _albumNameAndNumLb.font = [UIFont systemFontOfSize:16];
    _albumNameAndNumLb.numberOfLines = 1;
    [self.jy_contentView addSubview:_albumNameAndNumLb];
    
    _descriptionlb.frame = CGRectMake(_albumNameAndNumLb.jy_Left, _albumNameAndNumLb.jy_Bottom + 5, _albumNameAndNumLb.jy_Width, 16);
    _descriptionlb.numberOfLines = 1;
    _descriptionlb.textColor = UICOLOR_RGB(0x666666);
    _descriptionlb.font = [UIFont systemFontOfSize:14];
    [self.jy_contentView addSubview:_descriptionlb];
    
    _timeLb.frame = CGRectMake(_descriptionlb.jy_Left, _descriptionlb.jy_Bottom + 8, _descriptionlb.jy_Width, 15);
    _timeLb.font = [UIFont systemFontOfSize:12];
    _timeLb.textColor = UICOLOR_RGB(0x666666);
    [self.jy_contentView addSubview:_timeLb];
    
    
    if (!_hasDesc) {
        _albumNameAndNumLb.jy_Top = 27+5;
        _descriptionlb.hidden = YES;
        _timeLb.jy_Top = _albumNameAndNumLb.jy_Bottom + 14;
    }else{
        _albumNameAndNumLb.frame = CGRectMake(_albumFaceImageView.jy_Width + 12, 27, self.jy_contentView.jy_Width - _albumFaceImageView.jy_Width - 15, 15);
        _descriptionlb.hidden = NO;
        _timeLb.frame = CGRectMake(_descriptionlb.jy_Left, _descriptionlb.jy_Bottom + 8, _descriptionlb.jy_Width, 15);
    }
        
    if (self.isShare) {
        _lockView.hidden = NO;
    }else{
        _lockView.hidden = YES;
    }
}


@end
