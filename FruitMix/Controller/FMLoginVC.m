//
//  FMLoginVC.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/16.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMLoginVC.h"
#import "ServerBrowser.h"
#import "GCDAsyncSocket.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>

#import "RATreeView.h"
#import "FMDeviceCell.h"
#import "FMUserCell.h"
#import "FMUserLoginVC.h"
#import "FMHandLoginVC.h"

#import "JYScrollViewNotify.h"

@interface FMLoginVC ()<ServerBrowserDelegate,RATreeViewDelegate, RATreeViewDataSource>{
    ServerBrowser* _browser;
    AFNetworkReachabilityManager * _manager;
    NSTimer* _reachabilityTimer;
    UIView* _titleView;
}

@property (nonatomic) NSMutableArray * dataSource;

@property (weak, nonatomic) RATreeView *treeView;

@property (nonatomic) NSMutableArray * tempDataSource;

@property (nonatomic) FMSerachService * expandCell;

@property (nonatomic) JYScrollViewNotify * notifyView;

@end

@implementation FMLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    [self initView];
    [self addRightNav];
    self.dataSource = [NSMutableArray arrayWithCapacity:0];
    [NSMutableArray arrayWithCapacity:0];
    [self beginSearching];
    _reachabilityTimer =  [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(refreshDatasource) userInfo:nil repeats:YES];
}

-(void)addRightNav{
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [rightBtn setImage:[UIImage imageNamed:@"PLUS"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    _titleView = self.navigationItem.titleView;
}

-(void)viewOfSeaching:(BOOL)seaching{
    if(seaching){
        FMNotifyView * view = [FMNotifyView notifyViewWithMessage:@"正在搜索..."];
        view.backgroundColor = [UIColor clearColor];
        view.frame = CGRectMake(0, 0, 150, 44);
//        CATransition *animation = [CATransition animation];
//        animation.duration = 0.2f ;
//        animation.timingFunction = UIViewAnimationCurveEaseInOut;
//        animation.fillMode = kCAFillModeForwards;
//        animation.removedOnCompletion = YES;
//        animation.type = @"push";
//        animation.subtype = @"fromBottom";
//
//        [view.layer addAnimation:animation forKey:nil];
        self.navigationItem.titleView  = view;
    }else{
        self.navigationItem.titleView = _titleView;
    }
}

-(void)rightBtnClick{
    FMHandLoginVC * vc = [[FMHandLoginVC alloc]init];
    @weaky(self)
    vc.block = ^(FMSerachService * ser){
        ser.isReadly = YES;
        [_dataSource addObject:ser];
        [weak_self refreshDatasource];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)dealloc{
    [_reachabilityTimer invalidate];
    _reachabilityTimer = nil;
}

-(void)refreshDatasource{
    NSMutableArray * temp = [NSMutableArray arrayWithCapacity:0];
    for (FMSerachService * ser in _dataSource) {
        if (ser.isReadly) {
            [temp addObject:ser];
        }
    }
    if(self.tempDataSource.count != temp.count){
        self.tempDataSource = temp;
        [self.treeView reloadData];
        [self.treeView expandRowForItem:self.expandCell];
    }
//     NSLog(@"😆%@,😜%@",_dataSource,_tempDataSource);
}

-(void)initView{
    RATreeView *treeView = [[RATreeView alloc] initWithFrame:self.view.bounds];
    treeView.delegate = self;
    treeView.dataSource = self;
    treeView.treeFooterView = [UIView new];
    treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine;
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(refreshControlChanged:) forControlEvents:UIControlEventValueChanged];
    [treeView.scrollView addSubview:refreshControl];
    
    [treeView reloadData];
    [treeView setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:1.0]];
    
    
    self.treeView = treeView;
    self.treeView.frame = self.view.bounds;
    self.treeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:treeView atIndex:0];
    
    [self.treeView registerNib:[UINib nibWithNibName:NSStringFromClass([FMDeviceCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FMDeviceCell class])];
    [self.treeView registerNib:[UINib nibWithNibName:NSStringFromClass([FMUserCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FMUserCell class])];
}

- (void)refreshControlChanged:(UIRefreshControl *)refreshControl
{
    _browser = nil;
    [self.dataSource removeAllObjects];
    [self.treeView reloadData];
    [self beginSearching];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [refreshControl endRefreshing];
    });
}

- (void) beginSearching {
    [self viewOfSeaching:YES];
    _browser = [[ServerBrowser alloc] initWithServerType:@"_http._tcp" port:-1];
    _browser.delegate = self;
    double delayInSeconds = 6.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self viewOfSeaching:NO];
        NSLog(@"发现 %lu 台设备",(unsigned long)_browser.discoveredServers.count);
    });
}


- (void)viewDidAppear:(BOOL)animated {
    [self beginSearching];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}
- (void)applicationWillResignActive:(NSNotification*)notification {
    _browser = nil;
    [self.treeView reloadData];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void) applicationDidBecomeActive:(NSNotification*)notification {
    [self beginSearching];
}

- (void)serverBrowserFoundService:(NSNetService *)service {
    for (NSData * address in service.addresses) {
        NSString* addressString = [GCDAsyncSocket hostFromAddress:address];
        [self findIpToCheck:addressString andService:service];
    }
    
//    NSString* portString = [NSString stringWithFormat:@"%i", [GCDAsyncSocket portFromAddress:address]];
//    NSString* urlString = [NSString stringWithFormat:@"http://%@:%@/", addressString, portString];
//    NSDictionary * dic = [NSNetService dictionaryFromTXTRecordData:[service TXTRecordData]];
//    NSArray * dic = [NSJSONSerialization JSONObjectWithData:[service TXTRecordData] options:0 error:nil];
}


-(void)findIpToCheck:(NSString *)addressString andService:(NSNetService *)service{
    NSString* urlString = [NSString stringWithFormat:@"http://%@:3000/", addressString];
    NSLog(@"%@", urlString);
//    if ([service.name rangeOfString:@"WISNUC"].location !=NSNotFound ||[service.name rangeOfString:@"wisnuc"].location !=NSNotFound) {
        FMSerachService * ser = [FMSerachService new];
        ser.path = urlString;
        //        ser.path = @"http://192.168.5.207:3721/";
        ser.name = service.name;
        ser.type = service.type;
        ser.displayPath = addressString;
        ser.hostName = service.hostName;
        NSLog(@"%@",service.hostName);
        BOOL isNew = YES;
        for (FMSerachService * s in self.dataSource) {
            if (IsEquallString(s.path, ser.path)) {
                isNew = NO;
                break;
            }
        }
        if (isNew) {
            [self.dataSource addObject:ser];
            [self refreshDatasource];
        }
//    }
}

- (void)serverBrowserLostService:(NSNetService *)service index:(NSUInteger)index {
    if (_browser.discoveredServers.count <= 0) {
        [self beginSearching];
    }
}

-(void)pushToLoginWithCell:(UITableViewCell *)cell andItem:(id)item{
    if ([cell isKindOfClass:[FMUserCell class]]) {
        UserModel * user = item;
        FMSerachService * ser = [self.treeView parentForItem:item];
        FMUserLoginVC  * vc = [[FMUserLoginVC alloc]init];
        vc.service = ser;
        vc.user = user;
        [self applicationWillResignActive:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark TreeView Delegate methods

- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item
{
    return 69;
}

- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item
{
    
    if([item isKindOfClass:[FMSerachService class]]){
        
        if (self.expandCell) {
            [treeView collapseRowForItem:self.expandCell];
        }
        self.expandCell = item;
        FMDeviceCell *cell = (FMDeviceCell *)[treeView cellForItem:item];
        cell.allowImage.image = [UIImage imageNamed:@"Arrow_down"];
    }else
        [self pushToLoginWithCell:[treeView cellForItem:item] andItem:item];
    NSLog(@"开启");
}

- (void)treeView:(RATreeView *)treeView didDeselectRowForItem:(id)item{
    if([item isKindOfClass:[FMSerachService class]]){
        FMDeviceCell *cell = (FMDeviceCell *)[treeView cellForItem:item];
        cell.allowImage.image = [UIImage imageNamed:@"Arrow"];
    }
}

- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item
{
    if([item isKindOfClass:[FMSerachService class]]){
        FMDeviceCell *cell = (FMDeviceCell *)[treeView cellForItem:item];
        cell.allowImage.image = [UIImage imageNamed:@"Arrow"];
    }else
        [self pushToLoginWithCell:[treeView cellForItem:item] andItem:item];
    NSLog(@"关闭");
}


#pragma mark TreeView Data Source

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item
{
    if([item isKindOfClass:[FMSerachService class]]){
        FMSerachService * ser = item;
        BOOL expanded = [self.treeView isCellForItemExpanded:item];
        FMDeviceCell * cell = [treeView dequeueReusableCellWithIdentifier:NSStringFromClass([FMDeviceCell class])];
        cell.DeviceNameLb.text = ser.name;
        cell.disPlayLb.text = ser.displayPath;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.allowImage.image = expanded?[UIImage imageNamed:@"Arrow_down"]:[UIImage imageNamed:@"Arrow"];
        return cell;
    }else{
        UserModel * user = item;
        FMUserCell * cell = [treeView dequeueReusableCellWithIdentifier:NSStringFromClass([FMUserCell class])];
        cell.userNameLb.text = user.username;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.user = user;
        cell.userHeadImageView.image = [UIImage imageForName:user.username size:cell.userHeadImageView.bounds.size];
        return cell;
    }
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [self.tempDataSource count];
    }else if([item isKindOfClass:[FMSerachService class]]){
        FMSerachService * ser = item;
        return ser.users.count;
    }
    return 0;
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    FMSerachService *data = item;
    if (item == nil) {
        return [self.tempDataSource objectAtIndex:index];
    }
    return data.users[index];
}

- (BOOL)treeView:(RATreeView *)treeView canEditRowForItem:(id)item{
    return NO;
}

@end
