//
//  FMShareSetCell.m
//  FruitMix
//
//  Created by 杨勇 on 16/5/3.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMShareSetCell.h"

@implementation FMShareSetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)prepareForReuse{
    self.setImage.image = nil;
}

@end
