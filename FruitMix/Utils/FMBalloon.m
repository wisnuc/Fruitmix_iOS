//
//  FMBalloon.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/23.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMBalloon.h"

@implementation FMBalloon

+(void)showBalloonInPhotoBrowser{
    if (!IS_FIRST_IN_PHOTO) {
        [self showBalloonViewWithImage:[UIImage imageNamed:@"return_resize"]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_FIRST_IN_PHOTO_BROWSER_STR];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


+(void)showBalloonViewWithImage:(UIImage *)image{
    NSAssert([[NSThread currentThread] isMainThread], @"必须在主线程运行");
    UIView * backView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    backView.backgroundColor = [UIColor blackColor];
    backView.alpha = 0.7;
    [[UIApplication sharedApplication].keyWindow addSubview:backView];
    
    UIImageView * balloonView = [[UIImageView alloc]initWithFrame:backView.bounds];
    balloonView.image = image;
    [[UIApplication sharedApplication].keyWindow addSubview:balloonView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1 animations:^{
            backView.alpha = 0;
            balloonView.alpha = 0;
        } completion:^(BOOL finished) {
            [backView removeFromSuperview];
            [balloonView removeFromSuperview];
        }];
    });
}



+(void)showBalloonInAlbum{
    if (!IS_FIRST_IN_ALBUM) {
        [self showBalloonViewWithImage:[UIImage imageNamed:@"album_balloon"]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_FIRST_IN_ALBUM_STR];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}



@end
