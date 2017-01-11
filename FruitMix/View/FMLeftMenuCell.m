//
//  FMLeftMenuCell.m
//  FruitMix
//
//  Created by 杨勇 on 16/11/16.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMLeftMenuCell.h"

@implementation FMLeftMenuCell

+(NSString *)identifier {
    return  NSStringFromClass([self class]);
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setup {
    
}

+(CGFloat) height {
    return 56;
}

-(void)setData:(id) data  andImageName:(NSString *)imageName{
    self.leftIV.image = [UIImage imageNamed:imageName];
    //    self.backgroundColor = [UIColor colorFromHexString:@"#eeeeee"];
    self.leftTitleLb.font = [UIFont italicSystemFontOfSize:16];
    //    self.textLabel.textColor = [UIColor colorFromHexString:@"#333333"];
    if([data isKindOfClass:[NSString class]]) {
        self.leftTitleLb.text = (NSString *)data;
    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.alpha = .4;
    } else {
        self.alpha = 1;
    }
}


@end
