//
//  FMShareCell.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMShareCell.h"
#import "FMMediaShareTask.h"

@interface FMShareCell ()

@property (nonatomic) NSString * commentTag;

@end

@implementation FMShareCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotify) name:CREATE_NEW_COMMENT object:nil];
    }
    return self;
}

-(void)handleNotify{
    [self setModel:[self model]];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setModel:(id<FMMediaShareProtocol>)model{
    _model = model;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self.model.getAllContents.count>0) {
            self.commentTag = ((FMShareAlbumItem *)self.model.getAllContents[0]).digest;;
            FMGetCommentsAPI * api = [FMGetCommentsAPI apiWithPhotoHash:_commentTag];
            NSMutableArray * comments = [NSMutableArray arrayWithArray:[FMMediaShareTask mediaTask_SelectCommentWithPhotoHash:_commentTag]];
            //先显示本地
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                self.likeView.talkNumLb.text = [NSString stringWithFormat:@"%ld",(unsigned long)comments.count];
                self.talkView.commentView.noticeList = comments;
                [self.talkView.commentView displayNews];
            });
            [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
                if ([api.hashid isEqualToString:_commentTag]) {
                    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
                    for (NSDictionary * dic in request.responseJsonObject) {
                        FMComment * comment = [FMComment yy_modelWithJSON:dic];
                        [arr addObject:comment];
                    }
                    self.likeView.likeNumLb.text = @"0";
                    [comments addObjectsFromArray:arr];
                    self.talkView.commentView.noticeList = comments;
                    [self.talkView.commentView displayNews];
                    self.likeView.talkNumLb.text = [NSString stringWithFormat:@"%ld",(unsigned long)comments.count];
                }
            } failure:^(__kindof JYBaseRequest *request) {
            }];
        }
    });
    [self setNeedsLayout];
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.model = nil;
    self.shareImage.image = nil;
    self.talkView.commentView.noticeList = nil;
    self.talkView.commentView.notice.text = @"";
    self.likeView.talkNumLb.text = @"0";
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (self.model) {
        self.headView.timeLabel.text = [self getDateStringWithShareDate:[NSDate dateWithTimeIntervalSince1970:self.model.getTime/1000]];
        self.headView.nameLabel.text = [FMConfigInstance getUserNameWithUUID:self.model.author];
        self.headView.userHeadView.image = [UIImage imageForName:self.headView.nameLabel.text size:self.headView.userHeadView.bounds.size];
        self.shareImage.jy_Height = [self.delegate shareCellGetImageSize:self].height;
        if (self.model.getAllContents) {
            NSArray * content = self.model.getAllContents;
            if (content.count>0) {
//                FMShareAlbumItem *item = content[0];
//                NSString * degist = item.digest;
//                if ([PhotoManager managerCheckIfIsLocalPhoto:degist]) {
//                    [[FMGetImage defaultGetImage] getOriginalImageWithLocalhash:degist andCompleteBlock:^(UIImage *image, NSString *tag) {
//                        self.shareImage.image = image;
//                    }];
//                }else{
//                    [[FMGetImage defaultGetImage] getOriginalImageWithHash:degist andCount:0 andPressBlock:nil andCompletBlock:^(UIImage *image, NSString *tag) {
//                        self.shareImage.image = image;
//                    }];
//                }
            }
        }
    }
    self.likeView.frame = CGRectMake(0, self.shareImage.jy_Bottom, _shareImage.jy_Width, 46.5);
    self.talkView.frame = CGRectMake(0, self.likeView.jy_Bottom, self.likeView.jy_Width, self.talkView.jy_Height);
//    self.talkView.commentView.noticeList = self.model.comment;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didSelectTalkButton:)];
    [self.talkView.commentView addGestureRecognizer:tap];
//    [self.talkView.commentView displayNews];
     _shareContentView.jy_Height = _talkView.jy_Bottom + 12.5;
    _shareContentView.layer.cornerRadius = 4;
    _shareContentView.layer.masksToBounds = YES;
    
//    _shareContentView.layer.shadowColor = [[UIColor blackColor]CGColor];
//    _shareContentView.layer.shadowOffset = CGSizeMake(0, -2);
//    _shareContentView.layer.shadowRadius = 5.0;
//    _shareContentView.layer.shadowOpacity = 0.8;
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
    
    self.likeView = [FMShareLikeView fmShareLikeViewWithModel:self.model andFrame:CGRectMake(0, self.shareImage.jy_Bottom, _shareImage.jy_Width, 46.5)];
    [self.likeView.likeBtn addTarget:self action:@selector(didSelectLikeButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.likeView.talkBtn addTarget:self  action:@selector(didSelectTalkButton:) forControlEvents:UIControlEventTouchUpInside];
    [_shareContentView addSubview:self.likeView];
    
    
    self.talkView = [FMShareTalkView fmShareTalkViewWithModel:self.model andBeginPoint:CGPointMake(0, self.likeView.jy_Bottom)];
    [self.shareContentView addSubview:self.talkView];
    
    _shareContentView.jy_Height = _talkView.jy_Bottom + 12.5;
    
}



+(CGFloat)getHeightWithModel:(id<FMMediaShareProtocol>)model{
    
    CGFloat headViewH = 97/2;
    CGFloat likeViewH = 46.5;
    CGFloat talkViewH = [FMShareTalkView getHeightWithModel:model] ;
    
//    CGFloat i = model.imageW/(__kWidth-FMPadding);
//    CGFloat imageH = model.imageH/i;
//#warning 待修改的图片高度
    return  headViewH+likeViewH+talkViewH+(__kWidth/4*3)+35;
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
