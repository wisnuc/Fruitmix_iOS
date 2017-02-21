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

- (void) beginSearchingWithBlock:(void (^)(NSArray * discoveredServers))block {
        _browser = [[ServerBrowser alloc] initWithServerType:@"_http._tcp" port:-1];
        _browser.delegate = self;
        double delayInSeconds = 3.0f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSArray * tempArr = [NSArray arrayWithArray:_browser.discoveredServers ];
            _browser = nil;
            if(block) block(tempArr);
//            if (_browser.discoveredServers.count <= 0){
//                NSLog(@"无");
//            }else
//                NSLog(@"%lu",(unsigned long)_browser.discoveredServers.count);
        });
    
}

+(NSString *)serverIPFormService:(NSNetService *)service{
    NSData* address = [service.addresses objectAtIndex:0];
    NSString* addressString = [GCDAsyncSocket hostFromAddress:address];
    NSString* urlString = [NSString stringWithFormat:@"http://%@", addressString];
    return urlString;
}

+(BOOL)testServerWithIP:(NSString *)ip andToken:(NSString *)token{
    __block BOOL alive = NO;
    __block BOOL completed = NO;
    NSCondition *condition = [[NSCondition alloc] init];
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10.f;
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"JWT %@",token] forHTTPHeaderField:@"Authorization"];
        [manager GET:[NSString stringWithFormat:@"%@:3721/users",ip] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            alive = YES;
            completed = YES;
            [condition signal];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"获取DeviceUUID失败,%@",error);
            alive = NO;
            completed = YES;
            [condition signal];
        } ];
    [condition lock];
    while (!completed) {
        [condition wait];
    }
    [condition unlock];
    
    return alive;
}

- (void)serverBrowserFoundService:(NSNetService *)service {
//    NSData* address = [service.addresses objectAtIndex:0];
//    NSString* addressString = [GCDAsyncSocket hostFromAddress:address];
//    NSString* urlString = [NSString stringWithFormat:@"http://%@/", addressString];
//    if ([service.name rangeOfString:@"WISNUC"].location !=NSNotFound ||[service.name rangeOfString:@"Wisnuc"].location !=NSNotFound) {
//        [self getDataWithPath:urlString];
//    }
}

- (void)serverBrowserLostService:(NSNetService *)service index:(NSUInteger)index {
    if (_browser.discoveredServers.count <= 0) {
        [self beginSearchingWithBlock:nil];
    }
}

@end
