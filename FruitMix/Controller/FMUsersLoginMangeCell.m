//
//  FMUsersLoginMangeCell.m
//  FruitMix
//
//  Created by JackYang on 2017/2/23.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMUsersLoginMangeCell.h"

@implementation FMUsersLoginMangeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)deleteBtnClick:(id)sender {

    if (_deleteBtnClick) {
        _deleteBtnClick(sender);
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
