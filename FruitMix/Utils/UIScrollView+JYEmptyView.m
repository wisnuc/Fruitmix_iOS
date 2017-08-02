//
//  UIScrollView+JYEmptyView.m
//  FruitMix
//
//  Created by 杨勇 on 16/12/22.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "UIScrollView+JYEmptyView.h"

@implementation JYEmptyView

- (instancetype)initWithFrame:(CGRect)frame description:(NSString *)description canTouch:(void(^)(UIButton *btn))touchBlock andImageName:(NSString *)imageName{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *iconImage = [UIImage imageNamed:imageName];
        NSLog(@"%@",NSStringFromCGRect(frame) );
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-iconImage.size.width)/2,(frame.size.height - 64 - 44- iconImage.size.height)/2,iconImage.size.width, iconImage.size.height)];
//        frame.size.width*0.5-iconImage.size.width*0.5, frame.size.height*0.5-iconImage.size.height, iconImage.size.width, iconImage.size.height
        imageView.image = iconImage;
        [self addSubview:imageView];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, imageView.center.y+iconImage.size.height*0.5+JYDescriptionTopSpace, JYSCREEN_WIDTH-20, JYDescriptionHeight)];
        tipLabel.textColor = JYColor_RGB(0x999999);
        tipLabel.font = [UIFont systemFontOfSize:JYDescriptionFontSize];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.text = description;
        [self addSubview:tipLabel];
        if (touchBlock) {
            self.touchBlock = touchBlock;
            UIButton *btnTouchView = [[UIButton alloc] initWithFrame:frame];
            [btnTouchView addTarget:self action:@selector(windowTouchAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btnTouchView];
        }
    }
    return self;
}

-(void)windowTouchAction:(UIButton *)button{
    if (self.touchBlock) {
        _touchBlock(button);
    }
}

@end


@implementation UIScrollView (JYEmptyView)
const char kNoNetImageNameKey;
const char kNoDataImageNameKey;
const char kJYEmptyViewKey;

-(void)setEmptyView:(JYEmptyView *)emptyView{
    objc_setAssociatedObject(self, &kJYEmptyViewKey, emptyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(JYEmptyView *)emptyView{
    return objc_getAssociatedObject(self, &kJYEmptyViewKey);
}

-(void)setNoNetImageName:(NSString *)noNetImageName{
    objc_setAssociatedObject(self, &kNoNetImageNameKey, noNetImageName, OBJC_ASSOCIATION_ASSIGN);
}

-(NSString *)noNetImageName{
    return objc_getAssociatedObject(self, &kNoNetImageNameKey);
}

-(void)setNoDataImageName:(NSString *)noDataImageName{
    objc_setAssociatedObject(self, &kNoDataImageNameKey, noDataImageName, OBJC_ASSOCIATION_ASSIGN);
}

-(NSString *)noDataImageName{
    return objc_getAssociatedObject(self, &kNoDataImageNameKey);
}

-(void)displayWithMsg:(NSString *)message
                   withRowCount:(NSUInteger)count
          andIsNoData:(BOOL)noData andTableViewFrame:(CGRect)frame
                  andTouchBlock:(JYEmptyTouchBlock)block{
    if (count == 0) {
        [self removeEmptyView];
        NSString *imageName = noData ? self.noDataImageName:self.noNetImageName;
        if(imageName == nil ||  [imageName isEqualToString:@""]){
            imageName = noData ? @"jy_no_data" : @"jy_no_network";
        }
        NSLog(@"%@",NSStringFromCGRect(frame));
        self.emptyView = [[JYEmptyView alloc]initWithFrame:frame description:message canTouch:block andImageName:imageName];
        [self addSubview:self.emptyView];
    }else{
        [self removeEmptyView];
    }
}

-(void)removeEmptyView{
    if (self.emptyView) {
        self.emptyView.hidden = YES;
        [self.emptyView removeFromSuperview];
        self.emptyView = nil;
    }
}
@end

