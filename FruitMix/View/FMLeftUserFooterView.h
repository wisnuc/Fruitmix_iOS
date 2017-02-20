//
//  FMLeftUserFooterView.h
//  FruitMix
//
//  Created by JackYang on 2017/2/20.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMLeftUserFooterView : UIView

@property (nonatomic,copy) void (^touchBlock)() ;

+(FMLeftUserFooterView *)footerViewWithTouchBlock:(void(^)())block;

@end
