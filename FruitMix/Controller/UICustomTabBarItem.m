//
//  CustomTabItem.m
//  GUOHUALIFE
//
//  Created by zte- s on 12-11-28.
//  Copyright (c) 2012年 zte. All rights reserved.
//

#import "UICustomTabBarItem.h"

@implementation UICustomTabBarItem
@synthesize itemSelectedImage;
@synthesize strTitle;
@synthesize itemImage;
@synthesize intTag;

- (id)initWithTitle:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag andSelectedImage:(UIImage *)selectedImage{
    if (self = [super init]) {
        self.strTitle = title;
        self.itemImage = image;
        self.intTag = tag;
        self.itemSelectedImage = selectedImage;
    }
    
    return self;
}

@end
