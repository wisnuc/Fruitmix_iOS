//
//  UIViewController+JYModelView.m
//  FruitMix
//
//  Created by JackYang on 16/3/22.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "UIViewController+JYModelView.h"
#import <QuartzCore/QuartzCore.h>

@interface UIViewController (JYModelAnimation)
-(UIView *)parentTarget;
-(CAAnimationGroup *)animationGroupForword:(BOOL)forword;
@end

@implementation UIViewController (JYModelAnimation)
-(UIView *)parentTarget{
    UIViewController * target = self;
    while (target.parentViewController != nil) {
        target = target.parentViewController;
    }
    return target.view;
}

-(CAAnimationGroup *)animationGroupForword:(BOOL)forword{
    CATransform3D t1 = CATransform3DIdentity;
    t1.m34 = 1.0/-900;
    t1 = CATransform3DScale(t1, 0.95, 0.95, 1);
    t1 = CATransform3DRotate(t1, 15.0*M_PI/180.0f, 1, 0, 0);
    
    CATransform3D t2 = CATransform3DIdentity;
    t2.m34 = t1.m34;
    t2 = CATransform3DTranslate(t2, 0, [self parentTarget].frame.size.height*-0.08, 0);
    t2 = CATransform3DScale(t2, 0.8, 0.8, 1);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:t1];
    animation.duration = kJYModelAnimationDuration/2;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation2.toValue = [NSValue valueWithCATransform3D:(forword?t2:CATransform3DIdentity)];
    animation2.beginTime = animation.duration;
    animation2.duration = animation.duration;
    animation2.fillMode = kCAFillModeForwards;
    animation2.removedOnCompletion = NO;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    [group setDuration:animation.duration*2];
    [group setAnimations:[NSArray arrayWithObjects:animation,animation2, nil]];
    return group;
}
@end

@implementation UIViewController (JYModelView)
-(void)present_JYViewController:(UIViewController*)vc {
    [self addChildViewController:vc];
    [self present_JYView:vc.view];
}
-(void)present_JYView:(UIView *)view{
    UIView * animationView = [self parentTarget];
    if(![animationView.subviews containsObject:view]){
        //subView Frame
        CGRect subFrame = view.frame;
        //superView Frame
        CGRect supFrame = animationView.frame;
        //subView show in window's Frame
        CGRect subShowFrame = CGRectMake(0, supFrame.size.height - subFrame.size.height, supFrame.size.width, subFrame.size.height);
        // cover view in window's Frame
        CGRect coverFrame = CGRectMake(0, 0, supFrame.size.width, supFrame.size.height-subFrame.size.height);
        
        //the view imitate window to cover screen
        UIView * overLayer = [[UIView alloc]initWithFrame:supFrame];
        overLayer.backgroundColor = [UIColor blackColor];
        
        //get screenshot to imageView
        UIGraphicsBeginImageContext(animationView.bounds.size);
        [animationView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIImageView * supImageView = [[UIImageView alloc]initWithImage:image];
        
        //add the image to overLayer
        [overLayer addSubview:supImageView];
        [animationView addSubview:overLayer];
        
        //add cover btn in subview's top to cover supView
        UIButton * dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [dismissBtn addTarget:self action:@selector(dismiss_JYView) forControlEvents:UIControlEventTouchUpInside];
        dismissBtn.backgroundColor = [UIColor clearColor];
        dismissBtn.frame = coverFrame;
        [overLayer addSubview:dismissBtn];
        
        [supImageView.layer addAnimation:[self animationGroupForword:YES] forKey:@"pushJYModelAnimation"];
        [UIView animateWithDuration:kJYModelAnimationDuration animations:^{
            supImageView.alpha = 0.7;
        }];
        
        //add to animationView
        view.frame = CGRectMake(0, supFrame.size.height, supFrame.size.width, subFrame.size.height);
        [animationView addSubview:view];
        view.layer.shadowColor = [[UIColor blackColor]CGColor];
        view.layer.shadowOffset = CGSizeMake(0, -2);
        view.layer.shadowRadius = 5.0;
        view.layer.shadowOpacity = 0.8;
        [UIView animateWithDuration:kJYModelAnimationDuration delay:0.5 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            view.frame = subShowFrame;
        } completion:^(BOOL finished) {
            
        }];
        
    }
}

-(void)dismiss_JYView{
    UIView * target = [self parentTarget];
    UIView * modal = [target.subviews objectAtIndex:target.subviews.count-1];
    UIView * overlay = [target.subviews objectAtIndex:target.subviews.count-2];
    
    [UIView animateWithDuration:kJYModelAnimationDuration animations:^{
        modal.frame = CGRectMake(0, target.frame.size.height, modal.frame.size.width, modal.frame.size.height);
    } completion:^(BOOL finished) {
        [overlay removeFromSuperview];
        [modal removeFromSuperview];
    }];
    
    // Begin overlay animation
    UIImageView * ss = (UIImageView*)[overlay.subviews objectAtIndex:0];
    [ss.layer addAnimation:[self animationGroupForword:NO] forKey:@"bringForwardAnimation"];
    [UIView animateWithDuration:kJYModelAnimationDuration animations:^{
        ss.alpha = 1;
    }];

}

-(void)dismiss_JYViewWithCompleteBlock:(CompleteBlock)block{
    [self dismiss_JYView];
    block();
}
@end
