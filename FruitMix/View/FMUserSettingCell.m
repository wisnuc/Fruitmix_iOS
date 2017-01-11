//
//  FMUserSettingCell.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/18.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMUserSettingCell.h"

@implementation FMUserSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setState:(FMUserSettingCellState)state{
    _state = state;
    _emailLb.hidden = !state;
    _deleteBtn.hidden = !state;
}

- (IBAction)deleteBtnClick:(id)sender {
}

@end
