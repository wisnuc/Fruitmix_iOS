//
//  FMSharesCell.m
//  FruitMix
//
//  Created by 杨勇 on 16/7/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMSharesCell.h"
#import "YYControl.h"
#import "YYGestureRecognizer.h"
#import "FMMediaShareTask.h"
#import "FMGetThumbImage.h"

#define kAlbumNameTag 12341

@implementation FMShareHeaderView

-(instancetype)initWithFrame:(CGRect)frame{
    if (frame.size.width == 0 && frame.size.height == 0) {
        frame.size.width = __kWidth - kSharesCellPaddingIMG*2;
        frame.size.height = kSharesCellHeaderHeight;
    }
    self = [super initWithFrame:frame];
//    @weakify(self);
    _avatarView = [[UIImageView alloc]initWithFrame:CGRectMake(FMSharesAvaterViewLeft, FMSharesAvaterViewTop, FMSharesAvatarViewWidth, FMSharesAvatarViewWidth)];
    _avatarView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_avatarView];
    
    _nameLabel = [UILabel new];
    _nameLabel.frame = CGRectMake(FMShareHeaderNameLabelLeft, FMSharesAvaterViewTop + 4, 100, 18);
    _nameLabel.lineBreakMode = NSLineBreakByClipping;
    _nameLabel.font = [UIFont fontWithName:Helvetica size:15];
    _nameLabel.textColor = UICOLOR_RGB(0x2a3442);
    _nameLabel.text = @"未知";
    [self addSubview:_nameLabel];

    _timeLabel = [[FMTimeLabel alloc]initWithFrame:CGRectMake(FMShareHeaderNameLabelLeft, FMSharesAvaterViewTop+18+4, self.jy_Width-50, 15)];
    _timeLabel.font = [UIFont fontWithName:DONGQING size:10];
    _timeLabel.textColor = UICOLOR_RGB(0x999999);
    _timeLabel.text = @"未知";
    [self addSubview:_timeLabel];
    return self;
}


@end


@implementation FMStatusTalkView

- (instancetype)initWithFrame:(CGRect)frame {
    if (frame.size.width == 0 && frame.size.height == 0) {
        frame.size.width = __kWidth - kSharesCellPaddingIMG*2;
        frame.size.height = 0;
    }
    @weakify(self);
    self = [super initWithFrame:frame];
    _imgCountLabel = [UILabel new];
    _imgCountLabel.textColor = UICOLOR_RGB(0x404040);
    _imgCountLabel.font = [UIFont fontWithName:DONGQING size:14];
    [self addSubview:_imgCountLabel];
    _talkBtn = [UIButton new];
    [_talkBtn setImage:[UIImage imageNamed:@"comment_share"] forState:UIControlStateNormal];
    [_talkBtn addTarget:self action:@selector(talkbtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_talkBtn];
    _talkCountLb = [UILabel new];
    _talkCountLb.textColor = UICOLOR_RGB(0x999999);
    _talkCountLb.font = [UIFont fontWithName:DONGQING size:13];
    _talkCountLb.text = @"0";
    [self addSubview:_talkCountLb];
    _moreImgBtn = [UIButton new];
    [_moreImgBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_moreImgBtn setTitle:@"查看更多" forState:UIControlStateNormal];
    [_moreImgBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _moreImgBtn.titleLabel.font = [UIFont fontWithName:DONGQING size:14];
    [self addSubview:_moreImgBtn];
    _commentView = [[FMShareScrollComment alloc] initWithFrame:CGRectMake(20, self.jy_Height-30, kSharesCellDefaultHeight - 40, 20)];
    _commentView.backgroundColor = UICOLOR_RGB(0xF0F0EB);
    [self addSubview:_commentView];
    _commentView.touchBlock = ^(FMShareScrollComment *view, YYGestureRecognizerState state, NSSet *touches, UIEvent *event) {
        if (![weak_self.cell.delegate respondsToSelector:@selector(cell:didClickImageAtIndex:)]) return;
        if (state == YYGestureRecognizerStateEnded) {
            UITouch *touch = touches.anyObject;
            CGPoint p = [touch locationInView:view];
            if (CGRectContainsPoint(view.bounds, p)) {
                [weak_self.cell.delegate cellDidClickComment:weak_self.cell];
            }
        }
    };
    
    return self;
}

-(void)moreBtnClick:(UIButton *)btn{
    if ([_cell.delegate respondsToSelector:@selector(cellDidClickReadMore:)]) {
        [_cell.delegate cellDidClickReadMore:_cell];
    }
}

-(void)talkbtnClick:(UIButton *)btn{
    if ([_cell.delegate respondsToSelector:@selector(cellDidClickComment:)]) {
        [_cell.delegate cellDidClickComment:_cell];
    }
}

-(void)setWithLayout:(FMStatusLayout *)layout{
    FMSharesCellType type = layout.cellType;
    _imgCountLabel.hidden = YES;
    _talkBtn.hidden = YES;
    _talkCountLb.hidden = YES;
    _moreImgBtn.hidden = YES;
    _commentView.hidden = YES;
    switch (type) {
        case 0:{
            self.jy_Height = FMSharesTalkViewTypePhotoH;
            _talkBtn.hidden = NO;
            _talkCountLb.hidden = NO;
            _commentView.hidden = NO;
            _talkCountLb.frame = CGRectMake(self.jy_Width - 30, 10, 30, 14);
            _talkBtn.frame =  CGRectMake(_talkCountLb.jy_Left-23/2-45/2, 7, 45/2, 45/2);
            _commentView.jy_Bottom = self.jy_Height-15;
        } break;
        case 1:{
            self.jy_Height = FMSharesTalkViewTypeSetH;
            _imgCountLabel.hidden = NO;
            _moreImgBtn.hidden = NO;
            _imgCountLabel.frame = CGRectMake(FMSharesAvaterViewLeft, 13, self.jy_Width-40, 20);
            NSString * a = [NSString stringWithFormat:@"分享了%lu张图片",(unsigned long)layout.status.getAllContents.count];
//            NSRange range = NSMakeRange(0, 3);
//            NSRange range2 = [a rangeOfString:@"张图片"];
//            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"分享了%lu张图片",(unsigned long)layout.status.getAllContents.count]];
//            [str addAttribute:NSForegroundColorAttributeName value:UICOLOR_RGB(0x9a9a9a) range:range];
//            [str addAttribute:NSForegroundColorAttributeName value:UICOLOR_RGB(0x9a9a9a) range:range2];
//            _imgCountLabel.attributedText = str;
            _imgCountLabel.text = a;
            _imgCountLabel.textColor = UICOLOR_RGB(0x9a9a9a);
            
            _moreImgBtn.frame = CGRectMake(self.jy_Width-88, 13, 88, 20);
            _moreImgBtn.hidden = layout.status.getAllContents.count <= 9;
            
        } break;
        case 2:{
            self.jy_Height = FMSharesTalkViewTypeAlbumH;
            _imgCountLabel.hidden = _moreImgBtn.hidden = _talkCountLb.hidden = _talkBtn.hidden = _commentView.hidden = YES;
        } break;
        default:{
        
        }
            break;
    }
}
@end


@implementation FMStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    if (frame.size.width == 0 && frame.size.height == 0) {
        frame.size.width = __kWidth;
        frame.size.height = 1;
    }
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    self.exclusiveTouch = YES;
    _contentView = [UIView new];
    _contentView.jy_Width = __kWidth - kSharesCellPaddingIMG*2;
    _contentView.jy_Left = kSharesCellPaddingIMG;
    _contentView.jy_Height = 1;
    _contentView.backgroundColor = UICOLOR_RGB(0xF0F0EB);
    _contentView.layer.cornerRadius = 2;
    _contentView.layer.shadowColor = [UIColor lightGrayColor].CGColor;//shadowColor阴影颜色
    _contentView.layer.shadowOffset = CGSizeMake(0.f,2.f);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
    _contentView.layer.shadowOpacity = 0.8;//阴影透明度，默认0
    _contentView.layer.shadowRadius = 3;//阴影半径，默认3
//    _contentView.layer.masksToBounds = YES;
    
    @weakify(self);
    static UIImage *topLineBG, *bottomLineBG;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        topLineBG = [UIImage imageWithSize:CGSizeMake(1, 3) drawBlock:^(CGContextRef context) {
            CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
            CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 0.8, [UIColor colorWithWhite:0 alpha:0.08].CGColor);
            CGContextAddRect(context, CGRectMake(-2, 3, 4, 4));
            CGContextFillPath(context);
        }];
        bottomLineBG = [UIImage imageWithSize:CGSizeMake(1, 3) drawBlock:^(CGContextRef context) {
            CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
            CGContextSetShadowWithColor(context, CGSizeMake(0, 0.4), 2, [UIColor colorWithWhite:0 alpha:0.08].CGColor);
            CGContextAddRect(context, CGRectMake(-2, -2, 4, 2));
            CGContextFillPath(context);
        }];
    });
    UIImageView *topLine = [[UIImageView alloc] initWithImage:topLineBG];
    topLine.jy_Width = _contentView.jy_Width;
    topLine.jy_Bottom = 0;
    topLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [_contentView addSubview:topLine];
    
    
    UIImageView *bottomLine = [[UIImageView alloc] initWithImage:bottomLineBG];
    bottomLine.jy_Width = _contentView.jy_Width;
    bottomLine.jy_Top = _contentView.jy_Height;
    bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_contentView addSubview:bottomLine];
    [self addSubview:_contentView];
    
    
    NSMutableArray *picViews = [NSMutableArray new];
    for (int i = 0; i < 9; i++) {
        YYControl *imageView = [YYControl new];
        imageView.jy_Size = CGSizeMake(100, 100);
        imageView.hidden = YES;
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = [UIColor lightGrayColor];
        imageView.exclusiveTouch = YES;
        imageView.touchBlock = ^(YYControl *view, YYGestureRecognizerState state, NSSet *touches, UIEvent *event) {
            if (![weak_self.cell.delegate respondsToSelector:@selector(cell:didClickImageAtIndex:)]) return;
            if (state == YYGestureRecognizerStateEnded) {
                UITouch *touch = touches.anyObject;
                CGPoint p = [touch locationInView:view];
                if (CGRectContainsPoint(view.bounds, p)) {
                    [weak_self.cell.delegate cell:weak_self.cell didClickImageAtIndex:i];
                }
            }
        };
        UIImageView *badge = [UIImageView new];
        badge.userInteractionEnabled = NO;
        badge.contentMode = UIViewContentModeScaleAspectFill;
        badge.hidden = YES;
        badge.image = [UIImage imageNamed:@"mask-layer"];
        
        UIImageView * biaozhiIV = [UIImageView new];
        biaozhiIV.image = [UIImage imageNamed:@"album_share"];
        [badge addSubview:biaozhiIV];
        
        UILabel * albumNamelabel = [UILabel new];
        albumNamelabel.userInteractionEnabled = NO;
        albumNamelabel.font = [UIFont fontWithName:DONGQING size:18];
        albumNamelabel.tag = kAlbumNameTag;
        albumNamelabel.textColor = [UIColor whiteColor];
        
        [badge addSubview:albumNamelabel];
        [imageView addSubview:badge];
        [picViews addObject:imageView];
        [_contentView addSubview:imageView];
        
        //约束
        [badge mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(imageView.mas_right);
            make.left.mas_equalTo(imageView.mas_left);
            make.bottom.mas_equalTo(imageView.mas_bottom);
            make.height.equalTo(@50);
        }];
        
        [biaozhiIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(badge.mas_left).with.offset(16);
            make.top.mas_equalTo(badge.mas_top).with.offset(20);
            make.width.equalTo(@20);
            make.height.equalTo(@20);
        }];
        
        [albumNamelabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(biaozhiIV.mas_right).with.offset(28);
            make.right.mas_equalTo(badge.mas_right);
            make.top.equalTo(@20);
            make.height.equalTo(@20);
        }];
    }
    _picViews = picViews;
    
    _headerView = [FMShareHeaderView new];
    [_contentView addSubview:_headerView];
    
    _talkView = [FMStatusTalkView new];
    [_contentView addSubview:_talkView];
    
    //注册通知
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotify) name:CREATE_NEW_COMMENT object:nil];
    
    return self;
}

-(void)handleNotify{
    [self setupCommentsWithHash:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setLayout:(FMStatusLayout *)layout{
    _layout = layout;
    
    CGFloat top = 0;
    self.jy_Height = layout.height;
    
    _contentView.jy_Top = layout.marginTop;
    _contentView.jy_Height = layout.height - layout.marginTop - layout.marginBottom;
    
    
    _headerView.jy_Height = layout.headerHeight;
    _headerView.nameLabel.text = [FMConfigInstance getUserNameWithUUID:layout.status.author];
    _headerView.avatarView.image = [UIImage imageForName:_headerView.nameLabel.text size:_headerView.avatarView.bounds.size];
    _headerView.timeLabel.date = [NSDate dateWithTimeIntervalSince1970:layout.status.getTime/1000];
    top += _headerView.jy_Bottom;
    if (layout.picHeight == 0 ) {
        [self _hideImageViews];
    }else
        [self _setImageViewWithTop:top];
    
    [_talkView setWithLayout:layout];
    _talkView.jy_Bottom = self.jy_Bottom - 2*kSharesCellTopMargin;
}

- (void)_hideImageViews {
    for (UIImageView *imageView in _picViews) {
        imageView.hidden = YES;
    }
}

- (void)_setImageViewWithTop:(CGFloat)imageTop{
    CGSize picSize = _layout.picSize;
    NSArray *pics =  _layout.status.getAllContents;
    BOOL isAlbum = [_layout.status.isAlbum boolValue];
    
    int picsCount = (int)pics.count;
    for (int i = 0; i < 9; i++) {
        YYControl *imageView = (YYControl *)_picViews[i];
        if ((i >= picsCount && !(i==0 &&isAlbum))||(isAlbum && i > 0)) {
            [imageView.layer yy_cancelCurrentImageRequest];
            imageView.hidden = YES;
        }
        else {
            CGPoint origin = {0};
            if (isAlbum) {
                origin.x = 0;
                origin.y = imageTop;
            }else{
                switch (picsCount) {
                    case 0: case 1: {
                        origin.x = 0;
                        origin.y = imageTop;
                    } break;
                    case 4: {
                        origin.x = (i % 2) * (picSize.width + kSharesCellPaddingPic);
                        origin.y = imageTop + (int)(i / 2) * (picSize.height + kSharesCellPaddingPic);
                    } break;
                    default: {
                        origin.x = (i % 3) * (picSize.width + kSharesCellPaddingPic);
                        origin.y = imageTop + (int)(i / 3) * (picSize.height + kSharesCellPaddingPic);
                    } break;
                }
            }
            imageView.frame = (CGRect){.origin = origin, .size = picSize};
            imageView.hidden = NO;
            [imageView.layer removeAnimationForKey:@"contents"];
            
            UIImageView * badge = [[imageView subviews]firstObject];
            if (i==0) {
                if (isAlbum ) {
                    badge.hidden = NO;
                    for (UIView * view in badge.subviews) {
                        if (view.tag == kAlbumNameTag) {
                            NSDictionary * dic = _layout.status.album;
                            NSString * nameAndCount = [NSString stringWithFormat:@"%@·%ld张",dic[TitleKey],(unsigned long)_layout.status.getAllContents.count];
                            [(UILabel *)view setText:nameAndCount];
                        }
                    }
                }else{
                    badge.hidden = YES;
                    //显示评论
                    FMShareAlbumItem * item = pics[i];
                    [self setupCommentsWithHash:item.digest];
                }
                
            }else{
                badge.hidden = YES;
            }
            
            imageView.block = nil;
            imageView.image = [UIImage imageNamed:@"photo_placeholder"];
            //赋值图片
            if (!(picsCount == 0 && isAlbum)) {
                FMShareAlbumItem * item = pics[i];
                NSString * digest =  item.digest;
                imageView.imgTag = digest;
                if(item.thumbImage){
                    imageView.image = item.thumbImage;
                }else{
                    @weakify(imageView);
                    imageView.block = ^(UIImage *image, NSString *tag) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (IsEquallString(tag, weak_imageView.imgTag)) {
                                item.thumbImage = image;
                                weak_imageView.image = image;
                            }
                        });
                    };
                    if(picsCount == 1 || isAlbum){
                        [FMGetImage getFullScreenImageWithPhotoHash:digest andCompleteBlock:imageView.block andIsAlbumCover:YES];
                    }else {
                        [FMGetThumbImage getThumbImageWithAsset:item andCompleteBlock:imageView.block];
                    }
                }
            }
        }
    }
}

-(void)setupCommentsWithHash:(NSString *)hash{
    
    //清空
    self.talkView.commentView.noticeList = nil;
    self.talkView.commentView.notice.text = @"";
    self.talkView.talkCountLb.text = @"0";
#warning change for comments
    
//    if (_layout.status.getAllContents.count>0) {
//        if (IsNilString(hash)) {
//            hash = [(FMShareAlbumItem *)_layout.status.getAllContents[0] digest];
//        }
//            FMGetCommentsAPI * api = [FMGetCommentsAPI apiWithPhotoHash:hash];
//            NSMutableArray * comments = [NSMutableArray arrayWithArray:[FMMediaShareTask mediaTask_SelectCommentWithPhotoHash:hash]];
//            [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
//                if ([api.hashid isEqualToString:hash]) {
//                    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
//                    for (NSDictionary * dic in request.responseJsonObject) {
//                        FMComment * comment = [FMComment yy_modelWithJSON:dic];
//                        [arr addObject:comment];
//                    }
//                    [comments addObjectsFromArray:arr];
//                    self.talkView.commentView.noticeList = comments;
//                    [self.talkView.commentView displayNews];
//                    self.talkView.talkCountLb.text = [NSString stringWithFormat:@"%ld",(unsigned long)comments.count];
//                }
//            } failure:^(__kindof JYBaseRequest *request) {
//            }];
//        }
}

@end

@implementation FMSharesCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.contentView.backgroundColor = UICOLOR_RGB(0xe2e2e2);
    _statusView = [FMStatusView new];
    _statusView.cell = self;
    _statusView.headerView.cell = self;
    _statusView.talkView.cell = self;
    [self.contentView addSubview:_statusView];
    return self;
}

- (void)prepareForReuse {
    // ignore
}

- (void)setLayout:(FMStatusLayout *)layout{
    _layout = layout;
    self.cellType = layout.cellType;
    self.jy_Height = layout.height;
    self.contentView.jy_Height = layout.height;
    _statusView.layout = layout;
}

- (UIView *)photoBrowser:(IDMPhotoBrowser *)photoBrowser needAnimationViewWillDismissAtPageIndex:(NSUInteger)index{
    if(index>=self.statusView.picViews.count){
        return nil;
    }
    return self.statusView.picViews[index];
}

@end
