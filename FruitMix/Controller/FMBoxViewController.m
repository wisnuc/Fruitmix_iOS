//
//  FMBoxViewController.m
//  FruitMix
//
//  Created by wisnuc on 2017/8/11.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMBoxViewController.h"
#import "FMBoxTableViewCell.h"
#import "FMBoxTwiterViewController.h"
#import "VCFloatingActionButton.h"

@interface FMBoxViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
floatMenuDelegate
>
@property (weak, nonatomic) IBOutlet UITableView *boxTableView;
@property (strong, nonatomic) VCFloatingActionButton * fabButton;
@end

@implementation FMBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleChangeIsAdminNotify:) name:FM_USER_ISADMIN object:nil];
}

//-(void)handleChangeIsAdminNotify:(NSNotification *)notify{
//    BOOL isAdmin = [notify.object boolValue];
//    if (isAdmin) {
//        NSLog(@"HHHHHHH");
//    }
//    [self reloadLeftMenuIsAdmin:isAdmin];
//}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
}

- (void)initView{
    _boxTableView.dataSource = self;
    _boxTableView.delegate = self;
    [self.view addSubview:self.fabButton];
}

- (void)initData{
   
    
    
    
}

#pragma mark - TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FMBoxTwiterViewController *twiterVC = [[FMBoxTwiterViewController alloc]init];
    [self.navigationController pushViewController:twiterVC animated:YES];
}

#pragma mark - TableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        FMBoxTableViewCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FMBoxTableViewCell class])];
        if (nil == cell) {
            cell= [[[NSBundle mainBundle] loadNibNamed:@"FMBoxTableViewCell" owner:nil options:nil] lastObject];
        }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (VCFloatingActionButton *)fabButton{
    if (!_fabButton) {
        CGRect floatFrame = CGRectMake(JYSCREEN_WIDTH - 80 , __kHeight - 64 - 56 - 88, 56, 56);
        NSLog(@"%f",self.view.jy_Width);
        _fabButton = [[VCFloatingActionButton alloc]initWithFrame:floatFrame normalImage:[UIImage imageNamed:@"add_album"] andPressedImage:[UIImage imageNamed:@"icon_close"] withScrollview:_boxTableView];
        _fabButton.automaticallyInsets = YES;
        _fabButton.imageArray = @[@"fab_share"];
        _fabButton.labelArray = @[@""];
        _fabButton.delegate = self;
//        _fabButton.hidden = YES;
    }
    return _fabButton;
}
@end
