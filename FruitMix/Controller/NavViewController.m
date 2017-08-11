//
//  NavViewController.m
//  闻上
//
//  Created by JackYang on 15-6-2.
//  Copyright (c) 2015年 JackYang. All rights reserved.
//

#import "NavViewController.h"
#import "UIView+dropshadow.h"

@interface NavViewController ()
//@property (nonatomic, assign) id currentDelegate;

@end

@implementation NavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationBar.backgroundColor = [UIColor whiteColor];
//    UICOLOR_RGB(0x3f51b5);
    self.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor darkTextColor]};
//    self.currentDelegate = self.interactivePopGestureRecognizer.delegate;
    self.transferNavigationBarAttributes = YES;
    UIView * redView = [[UIView alloc]initWithFrame:CGRectMake(0, -20, __kWidth, 20)];
    redView.backgroundColor = StatusBar_Color;
    self.navigationBar.translucent = NO;
    [self.navigationBar addSubview:redView];
    [self useClipsToBoundsRemoveBlackLine];
    
    
}
-(void)useClipsToBoundsRemoveBlackLine
{
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)])
    {
        
        NSArray *list=self.navigationController.navigationBar.subviews;
        
        for (id obj in list)
        {
            
            if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0)
            {//10.0的系统字段不一样
                UIView *view =   (UIView*)obj;
                for (id obj2 in view.subviews) {
                    
                    if ([obj2 isKindOfClass:[UIImageView class]])
                    {
                        
                        UIImageView *image =  (UIImageView*)obj2;
                        image.hidden = YES;
                    }
                }
            }
        }
    }
    //设置移除黑线
//    [self.navigationController.navigationBar setShadowImage:[UIImage new]]; 
}
//- (void)_commonInit
//{
//    self.navigationBar.barTintColor = UICOLOR_RGB(0x3f51b5);
//    self.navigationBar.backgroundColor = UICOLOR_RGB(0x3f51b5);
//    self.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor whiteColor]};
//    //    self.currentDelegate = self.interactivePopGestureRecognizer.delegate;
////    self.transferNavigationBarAttributes = YES;
//    UIView * redView = [[UIView alloc]initWithFrame:CGRectMake(0, -20, __kWidth, 20)];
//    redView.backgroundColor = StatusBar_Color;
//    self.navigationBar.translucent = NO;
//    [self.navigationBar addSubview:redView];
//    [self.navigationBar dropShadowWithOffset:CGSizeMake(0, 8) radius:8 color:[UIColor blackColor] opacity:0.5];
//}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        if(self.navigationItem.leftBarButtonItems.count == 0){
            [self addBackItemWith:viewController];
            NSLog(@"需要");
        }
        
        //        viewController.hidesBottomBarWhenPushed = YES;
        
    }
    
    
    
    [super pushViewController:viewController animated:animated];
    
}

- (void)backBtnClick
{
    [self popViewControllerAnimated:YES];
}

- (void)addBackItemWith:(UIViewController *)viewController
{//14 28
    
    //左按钮
    UIButton *leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 52, 52)];
    [leftBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];//设置按钮点击事件
    [leftBtn setImage:[UIImage imageNamed:@"back_gray"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"back_grayhighlight"] forState:UIControlStateHighlighted];
    //设置按钮正常状态图片
    UIBarButtonItem *leftBarButon = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
//    leftBarButon.tintColor = [UIColor blueColor];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -16 - 2*([UIScreen mainScreen].scale - 1);//这个数值可以根据情况自由变化
    viewController.navigationItem.leftBarButtonItems = @[negativeSpacer, leftBarButon];
    viewController.navigationItem.leftBarButtonItem.tintColor = [UIColor redColor];
//    viewController.navigationItem.leftBarButtonItem.tintColor = [UIColor darkGrayColor];
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame = CGRectMake(0, 0,25, 25);
//    [button setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}


//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    if (viewController == self.viewControllers[0]) {
//        self.interactivePopGestureRecognizer.delegate = self.navigationController.interactivePopGestureRecognizer.delegate;
//    }else{
//        self.interactivePopGestureRecognizer.delegate = nil;
//    }
//}

- (BOOL)shouldAutorotate
{
//    if(self.topViewController.presentedViewController){
//        if ([self.topViewController.presentedViewController respondsToSelector:@selector(shouldAutorotate)]) {
//            return [self.topViewController.presentedViewController shouldAutorotate];
//        }
//    }
    return self.topViewController.shouldAutorotate;
    
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    UIViewController * topVc = self.topViewController;
    return topVc.supportedInterfaceOrientations;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

@end
