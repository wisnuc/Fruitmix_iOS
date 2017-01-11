//
//  UIApplication+JYTopVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/11/18.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "UIApplication+JYTopVC.h"

@implementation UIApplication (JYTopVC)

+(UIViewController *)topViewController:(UIViewController *)viewController {
    if (viewController == nil) {
        viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)viewController;
        return [UIApplication topViewController:nav.visibleViewController];
    }
    
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)viewController;
        UIViewController *selected = tab.selectedViewController;
        if (selected != nil) {
            return [UIApplication topViewController:selected];
        }
    }
    
    UIViewController *presented = viewController.presentedViewController;
    if (presented != nil) {
        return [UIApplication topViewController:presented];
    }
    
    if ([viewController isKindOfClass:[RDVTabBarController class]]) {
        RDVTabBarController *slide = (RDVTabBarController *)viewController;
        return [UIApplication topViewController:slide.selectedViewController];
    }
    
    return viewController;
}

+(UIViewController *)topViewController {
    UIViewController *controller = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    return [UIApplication topViewController:controller];
}


@end
