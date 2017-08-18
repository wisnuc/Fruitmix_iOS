//
//  FMMessageToolBar.h
//  FruitMix
//
//  Created by wisnuc on 2017/8/14.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMMessagesToolbarContentView.h"

@interface FMMessageToolBar : UIToolbar
@property (weak, nonatomic, readonly, nullable) FMMessagesToolbarContentView *contentView;

@end
