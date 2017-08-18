//
//  FMMessagesToolbarContentView.h
//  FruitMix
//
//  Created by wisnuc on 2017/8/14.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMMessagesComposerTextView.h"

@interface FMMessagesToolbarContentView : UIView

@property (weak, nonatomic, readonly, nullable) FMMessagesComposerTextView *textView;

@property (copy, nonatomic, nullable) NSString *placeHolder;

@property (strong, nonatomic) UIColor * _Nullable placeHolderTextColor;

@property (assign, nonatomic) UIEdgeInsets placeHolderInsets;

@end
