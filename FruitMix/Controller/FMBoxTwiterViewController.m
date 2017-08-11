//
//  FMBoxTwiterViewController.m
//  FruitMix
//
//  Created by wisnuc on 2017/8/11.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMBoxTwiterViewController.h"

@interface FMBoxTwiterViewController ()

@end

@implementation FMBoxTwiterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    
}


@end
