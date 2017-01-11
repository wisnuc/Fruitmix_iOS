//
//  FMCheckManager.m
//  FruitMix
//
//  Created by 杨勇 on 16/8/4.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMCheckManager.h"
#import "ServerBrowser.h"
#import "GCDAsyncSocket.h"
#import "AFNetworking.h"
#import "FMSerachService.h"

@interface FMCheckManager ()<ServerBrowserDelegate>{
    ServerBrowser* _browser;
}

@end

@implementation FMCheckManager

+(instancetype)shareCheckManager{
    static FMCheckManager * checkManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        checkManager = [FMCheckManager new];
    });
    return checkManager;
}

-(instancetype)init{
    if (self = [super init]) {
        [self beginSearching];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:FM_NET_STATUS_NOT_WIFI_NOTIFY object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:FM_NET_STATUS_WIFI_NOTIFY object:nil];
    }
    return self;
}

- (void) beginSearching {
    if([PhotoManager shareManager].netStatus == FMNetStatusWIFI){
        _browser = [[ServerBrowser alloc] initWithServerType:@"_http._tcp" port:-1];
        _browser.delegate = self;
        double delayInSeconds = 6.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (_browser.discoveredServers.count <= 0){
                NSLog(@"无");
            }else
                NSLog(@"%lu",(unsigned long)_browser.discoveredServers.count);
        });
    }
}

- (void)applicationWillResignActive:(NSNotification*)notification {
    _browser = nil;
    
}
- (void) applicationDidBecomeActive:(NSNotification*)notification {
    [self beginSearching];
}

- (void)serverBrowserFoundService:(NSNetService *)service {
    NSData* address = [service.addresses objectAtIndex:0];
    NSString* addressString = [GCDAsyncSocket hostFromAddress:address];
    NSString* urlString = [NSString stringWithFormat:@"http://%@/", addressString];
    if ([service.name rangeOfString:@"WISNUC"].location !=NSNotFound ||[service.name rangeOfString:@"Wisnuc"].location !=NSNotFound) {
        [self getDataWithPath:urlString];
    }
}

-(void)getDataWithPath:(NSString *)path{
    static int i = 0;
    __weak typeof(self) weakSelf = self;
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    [manager GET:[NSString stringWithFormat:@"%@login",path] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray * userArr = responseObject;
        NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary * dic in userArr) {
            UserModel * model = [UserModel yy_modelWithJSON:dic];
            [tempArr addObject:model.uuid];
        }
        //重置path
        if ([tempArr containsObject:DEF_UUID]) {
            JYRequestConfig * config = [JYRequestConfig sharedConfig];
            config.baseURL = path;
            [MyAppDelegate.notification displayNotificationWithMessage:@"重连至设备" forDuration:1];
            _browser = nil;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        i++;
        if(i<5){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf getDataWithPath:path];
            });
        }
    }];
}

- (void)serverBrowserLostService:(NSNetService *)service index:(NSUInteger)index {
    if (_browser.discoveredServers.count <= 0) {
        [self beginSearching];
    }
}

@end
