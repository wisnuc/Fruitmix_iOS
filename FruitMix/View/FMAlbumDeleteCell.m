//
//  FMAlbumDeleteCell.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/6.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMAlbumDeleteCell.h"

@implementation FMAlbumDeleteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)deleteBtnClick:(id)sender {
    if (self.fm_delegate && [self.fm_delegate respondsToSelector:@selector(albumDeleteCell:didSelectDeleteBtn:)]) {
        [self.fm_delegate albumDeleteCell:self didSelectDeleteBtn:sender];
    }
}

@end
