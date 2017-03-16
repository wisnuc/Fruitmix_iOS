//
//  UIColor+FM_UserHeadImage.m
//  FruitMix
//
//  Created by 杨勇 on 16/7/5.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "UIColor+FM_UserHeadImage.h"

@implementation UIColor (FM_UserHeadImage)

static UIColor * lastColor = nil;
+(UIColor *)colorForUser:(NSString *)userName{
    static NSMutableArray * colorArr = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colorArr = [NSMutableArray array];
        [colorArr addObject:UICOLOR_RGB(0xffc107)];
        [colorArr addObject:UICOLOR_RGB(0x8bc34a)];
        [colorArr addObject:UICOLOR_RGB(0x00bcd4)];
    });
    
    UIColor * color = [self colorForKey:userName];
    if (color) {
        return color;
    }else if(lastColor){
        NSMutableArray * tempArr = [colorArr mutableCopy];
        [tempArr removeObject:lastColor];
        color = tempArr[arc4random() % 2];
        [self setColor:color forKey:userName];
        return color;
    }
    color = colorArr[arc4random() % 3];
    lastColor = color;
    [self setColor:color forKey:userName];
    return color;
}

+ (NSMutableDictionary *)cachedImages {
    static NSMutableDictionary *items = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        items = [NSMutableDictionary new];
    });
    
    return items;
}

+ (UIColor *)colorForKey:(NSString *)key {
    return self.cachedImages[key];
}

+ (void)setColor:(UIColor *)color forKey:(NSString *)key {
    self.cachedImages[key] = color;
}

@end
