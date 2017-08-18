//
//  UIScrollView+JYEmptyView.h
//  FruitMix
//
//  Created by 杨勇 on 16/12/22.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

#define JYDescriptionFontSize 14.f
#define JYDescriptionHeight 15.f
#define JYDescriptionTopSpace 10.f
#define JYColor_RGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


typedef void(^JYEmptyTouchBlock)(UIButton * btn);

@interface JYEmptyView : UIView

@property (nonatomic) JYEmptyTouchBlock touchBlock;

- (instancetype)initWithFrame:(CGRect)frame
                  description:(NSString *)description
                     canTouch:(void(^)(UIButton *btn))touchBlock
                 andImageName:(NSString *)imageName;

@end

@interface UIScrollView (JYEmptyView)

@property (nonatomic) JYEmptyView * emptyView;

@property (nonatomic) NSString * noNetImageName;

@property (nonatomic) NSString * noDataImageName;

-(void)displayWithMsg:(NSString *)message
                   withRowCount:(NSUInteger)count
                    andIsNoData:(BOOL)noData
                    andTableViewFrame:(CGRect)frame
                  andTouchBlock:(JYEmptyTouchBlock)block;
@end
