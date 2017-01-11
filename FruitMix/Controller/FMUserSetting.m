//
//  FMUserSetting.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/12.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMUserSetting.h"
#import "FMUserSettingCell.h"
#import "FMUserAddVC.h"

@interface FMUserSetting ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLb;
@property (weak, nonatomic) IBOutlet UITableView *usersTableView;

@property (nonatomic) id navDelegate;

@property (nonatomic) NSMutableArray * dataSource;

@end

@implementation FMUserSetting

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UICOLOR_RGB(0xe2e2e2);
//    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    [self createNavbtn];
    self.usersTableView.backgroundColor = UICOLOR_RGB(0xe2e2e2);
    [self.usersTableView registerNib:[UINib nibWithNibName:NSStringFromClass([FMUserSettingCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FMUserSettingCell class])];
    self.usersTableView.tableFooterView = [UIView new];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.navDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;
//    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self getData];
//    [self addLeftBarButtonWithImage:[UIImage imageNamed:@"back"] andSEL:@selector(backbtnClick:)];
}

-(void)viewWillDisappear:(BOOL)animated{
//    self.navigationController.interactivePopGestureRecognizer.delegate = self.navDelegate;
}

-(void)getData{
    FMAsyncUsersAPI * usersApi = [FMAsyncUsersAPI new];
    [usersApi startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        NSArray * userArr = request.responseJsonObject;
        NSMutableArray *tempDataSource = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary * dic in userArr) {
            FMUsers * model = [FMUsers yy_modelWithJSON:dic];
            [tempDataSource addObject:model];
        }
        //主线程刷新
        self.dataSource = tempDataSource;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.usersTableView reloadData];
        });
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"失败");
    }];
}

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}


-(void)createNavbtn{
//    UIButton * finishBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 30, 50, 20)];
//    [finishBtn addTarget:self  action:@selector(backbtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    finishBtn.titleLabel.font = [UIFont fontWithName:FANGZHENG size:16];
//    //    [finishBtn setImage:[UIImage imageNamed:@"arrow_back"] forState:UIControlStateNormal];
//    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
//    UIBarButtonItem * item2 = [[UIBarButtonItem alloc]initWithCustomView:finishBtn];
//    self.navigationItem.rightBarButtonItem = item2;
    
}

- (IBAction)addBtnClick:(id)sender {
    FMUserAddVC * addVC = [[FMUserAddVC alloc]init];
    [self.navigationController pushViewController:addVC animated:YES];
}

-(void)backbtnClick:(UIButton *)back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FMUserSettingCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FMUserSettingCell class]) forIndexPath:indexPath];
    FMUsers * model = self.dataSource[indexPath.row];
    cell.userImageVIew.image = [UIImage imageForName:model.username size:cell.userImageVIew.bounds.size];
    cell.userNameLb.text = model.username;
    cell.state = UserSettingCellStateNormal;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
