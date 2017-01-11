//
//  TabBarViewController.m
//  闻上
//
//  Created by imac on 15-6-17.
//  Copyright (c) 2015年 imac. All rights reserved.
//

#import "TabBarViewController.h"
#import "NavViewController.h"

@interface TabBarViewController ()
@property(nonatomic,strong)UIView *transparentView;

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     [self addTabBarToWindow];
    self.tabBar.hidden=YES;
}
- (void)addTabBarToWindow
{
    /* 页面 */
    FMShareViewController * shareVC = [[FMShareViewController alloc]init];
    FMPhotosViewController * photosVC = [[FMPhotosViewController alloc]init];
    FMAlbumsViewController * albumsVC = [[FMAlbumsViewController alloc]init];
    /* 导航 */
    NavViewController *nav0 = [[NavViewController alloc] initWithRootViewController:shareVC];
    NavViewController *nav1 = [[NavViewController alloc]initWithRootViewController:photosVC];
    NavViewController *nav2 = [[NavViewController alloc] initWithRootViewController:albumsVC];
    
    NSMutableArray *viewControllersMutArr = [[NSMutableArray alloc] initWithObjects:nav0, nav1,nav2,nil];
    
    //NSMutableArray *viewControllersMutArr = [[NSMutableArray alloc] initWithObjects:firstVC, listVC,chooseVC,synchronizeVC,panelVC,nil];
    self.viewControllers = viewControllersMutArr;
    self.selectedIndex = 0;
    self.tabBar.hidden = YES;
    
    UICustomTabBarItem *item1 = [[UICustomTabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"share"] tag:0 andSelectedImage:[UIImage imageNamed:@"share_select"]];
    UICustomTabBarItem *item2 = [[UICustomTabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"photo"]  tag:1 andSelectedImage:[UIImage imageNamed:@"photo_select"]];
    UICustomTabBarItem *item3 = [[UICustomTabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"photo-album"]  tag:2 andSelectedImage:[UIImage imageNamed:@"photo-album_select"]];

    
    self.customTabBar = [[UICustomTabBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 49, self.view.frame.size.width, 49)];
    self.customTabBar=self.customTabBar;
    self.customTabBar.buttonItems = [NSArray arrayWithObjects:item1, item2, item3,nil];
    self.customTabBar.tabDelegate = self;
    self.customTabBar.selectItemIndex = 0;
    [self.view addSubview:self.customTabBar];
//    [self addChildViewController:<#(UIViewController *)#>];
//    [self.view addSubview:<#(UIView *)#>]
    
    
}
- (void)custTabBarDidSelectItemIndex:(NSInteger)itemIndex
{

    UINavigationController *nav=self.viewControllers[itemIndex];
    [nav popToRootViewControllerAnimated:YES];
    self.selectedIndex = itemIndex;

}
//#pragma mark - 基础界面禁止横屏
//-(BOOL)shouldAutorotate{
//    return NO;
//}
//-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    return UIInterfaceOrientationMaskPortrait;
//}
//
//-(UIStatusBarStyle)preferredStatusBarStyle{
//    return UIStatusBarStyleLightContent;
//}
@end
