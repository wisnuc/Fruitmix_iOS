//
//  FMSlideMenuControllerViewController.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMSlideMenuControllerViewController.h"
#import "UIApplication+SlideMenuControllerOC.h"


@interface FMSlideMenuControllerViewController ()

@end

@implementation FMSlideMenuControllerViewController

-(BOOL)isTagetViewController{
    UIViewController *vc = [UIApplication topViewController];
    if ([vc isKindOfClass:[RDVTabBarController class]]) {
        //nav
        UIViewController *vc2 = [(RDVTabBarController *)vc selectedViewController];
        
        if ([vc2 isKindOfClass:[UINavigationController class]]) {
            UIViewController *vc3 = [UIApplication topViewController:vc2];
            if ([vc3 isKindOfClass:[FMPhotosViewController class]]
                ||[vc3 isKindOfClass:[FMAlbumsViewController class]]
                ||[vc3 isKindOfClass:[FMShareViewController class]]) {
                return YES;
            }
            return NO;
        }
        return NO;
    }
    return NO;
}


-(void)track:(TrackAction)action {
    switch (action) {
        case TrackActionLeftTapOpen:
            NSLog(@"TrackAction: left tap open.");
            break;
        case TrackActionLeftTapClose:
            NSLog(@"TrackAction: left tap close.");
            break;
        case TrackActionLeftFlickOpen:
            NSLog(@"TrackAction: left flick open.");
            break;
        case TrackActionLeftFlickClose:
            NSLog(@"TrackAction: left flick close.");
            break;
        case TrackActionRightTapOpen:
            NSLog(@"TrackAction: right tap open.");
            break;
        case TrackActionRightTapClose:
            NSLog(@"TrackAction: right tap close.");
            break;
        case TrackActionRightFlickOpen:
            NSLog(@"TrackAction: right flick open.");
            break;
        case TrackActionRightFlickClose:
            NSLog(@"TrackAction: right flick close.");
            break;
        default:
            break;
    }
}

@end
