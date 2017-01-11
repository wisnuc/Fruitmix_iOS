//
//  FMCommentHeader.m
//  FruitMix
//
//  Created by 杨勇 on 16/5/5.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMCommentHeader.h"

@implementation FMCommentHeader

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _headImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _headImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_headImageView];
    }
    return self;
}

@end
