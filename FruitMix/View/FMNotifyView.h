//
//  FMNotifyView.h
//  FruitMix
//
//  Created by 杨勇 on 16/9/30.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMNotifyView : UIView
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;


@property (nonatomic) BOOL showLoadingView;

+(instancetype)notifyViewWithMessage:(NSString *)message;
@end
