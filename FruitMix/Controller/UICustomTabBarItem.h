//
//  CustomTabItem.h
//  GUOHUALIFE
//
//  Created by zte- s on 12-11-28.
//  Copyright (c) 2012年 zte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface UICustomTabBarItem : NSObject
{
    NSString *strTitle;
    UIImage *itemImage;
    NSInteger intTag;
    UIImage *itemSelectedImage;
}

@property (nonatomic, retain) NSString *strTitle;
@property (nonatomic, retain) UIImage *itemImage;
@property (nonatomic, assign) NSInteger intTag;
@property (nonatomic) UIImage *itemSelectedImage;

- (id)initWithTitle:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag andSelectedImage:(UIImage *)selectedImage;

@end
