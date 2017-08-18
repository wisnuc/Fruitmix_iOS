//
//  FMMediaShareDataSource.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/20.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMMediaShareDataSource.h"
#import "FMStatusLayout.h"

@implementation FMMediaShareDataSource{
    MSWeakTimer * _timer;
}

+(instancetype)sharedDataSource{
    if(!MyAppDelegate.mediaDataSource){
        MyAppDelegate.mediaDataSource = [FMMediaShareDataSource new];
    }
    return MyAppDelegate.mediaDataSource;
}

-(instancetype)init{
    if (self= [super init]) {
//        [self refreshData];
        [self getMetaData];
        [[NSNotificationCenter defaultCenter]addObserver:self  selector:@selector(handleBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleForground) name:UIApplicationDidBecomeActiveNotification object:nil];
        _timer = [MSWeakTimer scheduledTimerWithTimeInterval:10.f target:self selector:@selector(refreshData) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    }
    return self;
}
-(void)handleBackground{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}
-(void)handleForground{
    if (!_timer) {
        _timer = [MSWeakTimer scheduledTimerWithTimeInterval:10.f target:self selector:@selector(refreshData) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    }
}

-(void)dealloc{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)getMetaData{
    @weaky(self);
//    [FMUpdateShareTool getMediaShares:^(NSArray *shares) {
//        @autoreleasepool {
//            NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
//            for (id<FMMediaShareProtocol> mediaShare in shares) {
//                FMStatusLayout * layout = [[FMStatusLayout alloc]initWithStatus:mediaShare];
//                [arr addObject:layout];
//            }
//            if ([weak_self checkIfEqualWithNow:arr]) {
//                NSLog(@"...........需要刷新..........");
//                weak_self.dataSource = arr;
//                [weak_self.dataSource sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//                    long long time1 = ((FMStatusLayout *)obj1).status.getTime;
//                    long long time2 = ((FMStatusLayout *)obj2).status.getTime;
//                    if (time1 > time2)
//                        return NSOrderedAscending;
//                    else if (time1 == time2)
//                        return NSOrderedSame;
//                    else
//                        return NSOrderedDescending;
//                }];
//                [weak_self _notifyDelegate];
//            }
//        }
//    }];
}

-(BOOL)checkIfEqualWithNow:(NSArray *)arr{
    if(arr.count != self.dataSource.count || !self.dataSource)
        return YES;
    NSMutableArray * tempArr = [self.dataSource mutableCopy];
    BOOL shouldRefresh = NO;
    
    for (FMStatusLayout * layout in arr) {
        @autoreleasepool {
            BOOL tempshouldRefresh = YES;
            FMStatusLayout * tempLayout;
            for (FMStatusLayout * layout2  in tempArr) {
                if ([(FMMediaShare *)layout2.status isEqualToMediaShare:layout.status]){//找到相同
                    tempshouldRefresh = NO;
                    tempLayout = layout2;
                    break;
                }
            }
            if (tempshouldRefresh) {//没有相同
                shouldRefresh = YES;
                break;
            }else
                [tempArr removeObject:tempLayout];
        }
    }
    
    tempArr = nil;
    return shouldRefresh;
}



-(void)refreshData{
    [self getMetaData];
}

//通知代理
-(void)_notifyDelegate{
    if (_delegate && [_delegate respondsToSelector:@selector(shareDataSourceDidUpdate)]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FM_SHARE_UPDATE_NOTIFY object:[self.dataSource mutableCopy]];//发送广播
        [_delegate shareDataSourceDidUpdate];
    }
}
-(void)reloadData{
    
}
@end
