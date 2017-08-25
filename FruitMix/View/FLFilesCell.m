//
//  FLFilesCell.m
//  FruitMix
//
//  Created by 杨勇 on 16/10/14.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FLFilesCell.h"


@implementation FLFilesCell

-(void)awakeFromNib{
    [super awakeFromNib];
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handlelongPress:)];
    longPress.minimumPressDuration = 0.5f;
    [self.contentView addGestureRecognizer:longPress];
    [self.downBtn setEnlargeEdgeWithTop:6 right:12 bottom:6 left:6];
}



-(void)layoutSubviews{
    [super layoutSubviews];
    self.layerView.layer.cornerRadius = 20;
}
- (void)handlelongPress:(id)sender {
    if (self.longpressBlock) {
        @weaky(self);
        _longpressBlock(weak_self);
    }

}

-(void)setStatus:(FLFliesCellStatus)status{
    _status = status;
    self.layerView.hidden = _status ? NO: YES;
    [self setNeedsLayout];
}

-(void)prepareForReuse{
    self.timeLabel.text = @"";
}

- (IBAction)downBtnclick:(id)sender {
    if (self.clickBlock) {
        @weaky(self);
        _clickBlock(weak_self);
    }
}

@end
