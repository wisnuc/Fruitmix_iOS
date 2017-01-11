
#import "UICustomTabBar.h"
@implementation UICustomTabBar
@synthesize buttonItems;
@synthesize tabDelegate;
@synthesize backgroundImage;
@synthesize selectItemIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        buttonMutArr = [[NSMutableArray alloc] init];
        
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /* tabbar背景 */
    if (backgroundImageView == nil)
    {
        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 49)];
    }
    backgroundImageView.backgroundColor = [UIColor blackColor];
    [self addSubview:backgroundImageView];
    
    NSInteger itemsCount = [buttonItems count];
    float itemWidth = (self.frame.size.width -30) /itemsCount;

    if ([buttonItems count] <= 0) {
        return;
    }
    
    /* 点击按钮移动背景 */
    /*
    if (tabbarBgImageView == nil)
    {
        tabbarBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemWidth, 49)];
    }
    [self addSubview:tabbarBgImageView];
    tabbarBgImageView.image = [UIImage imageNamed:@"TabBarPress.png"];
    */
    for (NSInteger i = 0; i < itemsCount; i++) {
        id item = [buttonItems objectAtIndex:i];
        
        if ([@"UICustomTabBarItem" isEqualToString:NSStringFromClass([item class])])
        {
            UICustomTabBarItem *tempItem = (UICustomTabBarItem *)item;
            
            UIButton *itemBtn = (UIButton *)[self viewWithTag:i + 100];
            
            BOOL isExist = itemBtn ? YES : NO;
            
            if (!isExist)
            {
                
                UIButton *itemBtn=[[UIButton alloc]initWithFrame:CGRectMake(i*itemWidth + 15, 0, itemWidth, 49)];
                /* 加入数组保存 */
                [buttonMutArr addObject:itemBtn];
                itemBtn.tag = tempItem.intTag;
                
               
                [itemBtn setImage:tempItem.itemImage forState:UIControlStateNormal];
                
            
               
                [itemBtn setTitle:tempItem.strTitle forState:UIControlStateNormal];
            
                itemBtn.titleEdgeInsets = UIEdgeInsetsMake(25, 0, 0, 0);
                itemBtn.titleLabel.font = [UIFont systemFontOfSize:TABTITLE_FONT];
                [itemBtn setTitleColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0] forState:UIControlStateNormal];
                
                
                [itemBtn addTarget:self action:@selector(itemBtnClick:) forControlEvents:UIControlEventTouchDown];
                [self addSubview:itemBtn];
            }
            
        }
    }
    
}


- (IBAction)itemBtnClick:(id)sender{
    UIButton *tempBtn = (UIButton *)sender;
    NSInteger btnTag=tempBtn.tag;
    [tabDelegate custTabBarDidSelectItemIndex:btnTag];
    
}


- (void)setSelectItemIndex:(NSInteger)selectItemIndexT
{
    selectItemIndex = selectItemIndexT + 100;
}


- (void)setindex:(NSInteger)selectItemIndexT
{    
    UIButton *tempBtn = (UIButton *)[buttonMutArr objectAtIndex:selectItemIndexT];
    
    [self itemBtnClick:tempBtn];
}


/* tabbar按钮背景移动 */
- (void)slideTabBarBg:(UIButton *)button
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.20];
	[UIView setAnimationDelegate:self];
    tabbarBgImageView.center = button.center;
	[UIView commitAnimations];
}


@end


