//
//  FMNotifyView.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/30.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMNotifyView.h"


@implementation FMNotifyView

+(instancetype)notifyViewWithMessage:(NSString *)message{
    FMNotifyView * view = [[NSBundle mainBundle] loadNibNamed:@"FMNotifyView" owner:nil options:nil][0];
    view.titleView.text = message;
    view.backgroundColor = StatusBar_Color;
//    view.loadingView.jy_Size = CGSizeMake(10, 10);
    return view;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.showLoadingView = YES;
}


-(void)setShowLoadingView:(BOOL)showLoadingView{
    _showLoadingView = showLoadingView;
    self.loadingView.hidden = !showLoadingView;
}
@end
