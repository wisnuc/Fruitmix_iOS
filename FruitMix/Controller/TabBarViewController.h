//
//  TabBarViewController.h
//  闻上
//
//  Created by imac on 15-6-17.
//  Copyright (c) 2015年 imac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICustomTabBar.h"
@interface TabBarViewController : UITabBarController<CustTabBarDelegate>
@property(nonatomic,strong)UICustomTabBar *customTabBar;
@end
