//
//  JYProcessView.h
//  ProcessView
//
//  Created by JackYang on 2017/1/10.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ProcessTypeLine,
    ProcessTypeCircle,
} ProcessType;


@interface JYProcessView : NSObject

@property (nonatomic) ProcessType processType;

@property (nonatomic) UILabel * descLb;

@property (nonatomic) UILabel * subDescLb;

@property (nonatomic) void (^cancleBlock)(void);

+(JYProcessView *)processViewWithType:(ProcessType)type;
-(void)setValueForProcess:(CGFloat)process;
-(void)show;
-(void)dismiss;
@end
