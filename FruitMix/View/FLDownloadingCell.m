//
//  FLDownloadingCell.m
//  FruitMix
//
//  Created by 杨勇 on 16/10/11.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FLDownloadingCell.h"

@implementation FLDownloadingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.cancelButton setEnlargeEdgeWithTop:6 right:12 bottom:6 left:6];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)cancelClick:(id)sender {
    if (self.clickBlock) {
        @weaky(self);
        _clickBlock(weak_self);
    }
}

@end
