#import <UIKit/UIKit.h>
#import "UICustomTabBarItem.h"


/* tabbar属性设置 */

///* title */
//#define TAB1_TITLE @"首页"
//#define TAB2_TITLE @"第二页"
//#define TAB3_TITLE @"第三页"
//#define TAB4_TITLE @"第四页"
//#define TAB5_TITLE @"更多"
/* title */
#define TAB1_TITLE @""
#define TAB2_TITLE @""
#define TAB3_TITLE @""
#define TAB4_TITLE @""
#define TAB5_TITLE @""
/* font */
#define TABTITLE_FONT 11

/* color */
#define TABTITLE_COLOR_NOR 0xFF0000
#define TABTITLE_COLOR_HIG 0x0000FF


@protocol CustTabBarDelegate;


@interface UICustomTabBar : UIView
{
    NSArray *buttonItems;
    
    NSMutableArray *buttonMutArr;
    
    UIImage *backgroundImage;
    
    NSInteger selectItemIndex;
    
//    id<CustTabBarDelegate> tabDelegate;
    
@private
    UIImageView *backgroundImageView;   /* tabbar背景 */
    UIButton *lastBtn;
    
    UIImageView *tabbarBgImageView;     /* 点击背景 */
}

@property (nonatomic, retain) UIImage *backgroundImage;
@property (nonatomic, retain) NSArray *buttonItems;
@property (nonatomic, assign) id<CustTabBarDelegate> tabDelegate;
@property (nonatomic, assign) NSInteger selectItemIndex;


- (void)setindex:(NSInteger)selectItemIndexT;

@end


@protocol CustTabBarDelegate <NSObject>

- (void)custTabBarDidSelectItemIndex:(NSInteger)itemIndex;


@end
