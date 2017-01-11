//
//  FMStatusLayout.m
//  FruitMix
//
//  Created by 杨勇 on 16/7/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMStatusLayout.h"

@implementation FMStatusLayout

- (instancetype)initWithStatus:(id<FMMediaShareProtocol>)status{
    if(!status) return nil;
    self = [super init];
    _status = status;
    [self layout];
    return self;
}


- (void)layout {
    [self _layout];
}

- (void)_layout{
    _marginTop = kSharesCellTopMargin;
    _headerHeight = kSharesCellHeaderHeight;
    _picHeight = 0;
    _talkViewHeight = 0;
    _marginBottom = kSharesCellTopMargin;
    [self _layoutPics];
    
    _height = _marginTop+_headerHeight+_talkViewHeight+_marginBottom+_picHeight;
    
    
}

- (void)_layoutPics {
    _picSize = CGSizeZero;
    _picHeight = 0;
    if ([self.status.isAlbum boolValue]){
        _picHeight = kSharesCellDefaultHeight;
        _picSize = CGSizeMake(kSharesCellContentWidth, _picHeight);
        _talkViewHeight = FMSharesTalkViewTypeAlbumH;
        _cellType = FMSharesTypeAlbum;
    }else{
        CGSize picSize = CGSizeZero;
        CGFloat picHeight = 0;
        CGFloat len1_3 = (kSharesCellContentWidth - kSharesCellPaddingPic*2 ) / 3;
        switch (self.status.getAllContents.count) {
            case 0: case 1: {
                _cellType = FMSharesTypePhoto;
                _talkViewHeight = FMSharesTalkViewTypePhotoH;
                picHeight = kSharesCellDefaultHeight;
                picSize = CGSizeMake(kSharesCellContentWidth, picHeight);
            } break;
            case 2:case 3:{
                _cellType = FMSharesTypeSet;
                _talkViewHeight = FMSharesTalkViewTypeSetH;
                picSize = CGSizeMake(len1_3, len1_3);
                picHeight = len1_3;
            } break;
            case 4: case 5: case 6:{
                _cellType = FMSharesTypeSet;
                _talkViewHeight = FMSharesTalkViewTypeSetH;
                picSize = CGSizeMake(len1_3, len1_3);
                picHeight = len1_3 * 2 + kSharesCellPaddingPic;
            } break;
            default:{//7.8.9 more
                _cellType = FMSharesTypeSet;
                _talkViewHeight = FMSharesTalkViewTypeSetH;
                picSize = CGSizeMake(len1_3, len1_3);
                picHeight = len1_3 * 3 + kSharesCellPaddingPic * 2;
            } break;
        }
        _picSize = picSize;
        _picHeight = picHeight;
    }
}

@end
