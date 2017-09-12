//
//  FMSerachService.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/7.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMSerachService.h"

@implementation FMSerachService

-(void)setPath:(NSString *)path{
    _path = path;
    self.isReadly = NO;
    [self getData];
    
}
-(NSArray *)users{
    if (!_users) {
        _users = [NSMutableArray array];
    }
    return _users;
}

-(void)getData{
//    static int i = 0;
//    __weak typeof(self) weakSelf = self;
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer.timeoutInterval = 15;
    NSLog(@"%@",_path);
    _task = [manager GET:[NSString stringWithFormat:@"%@users",_path] parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray * userArr = responseObject;
//        NSLog(@"%@",responseObject);
        NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary * dic in userArr) {
            UserModel * model = [UserModel yy_modelWithJSON:dic];
            [tempArr addObject:model];
        }
        self.users = tempArr;
//        if (tempArr.count>0) {
            self.isReadly = YES;
//        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
//        NSLog(@"ERROR: %@",error.code == -1004?@"请求超时":(error.code == -1003?@"无法解析ip":@"未知错误"));
//        if(++i < 5)
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [weakSelf getData];
//            });
        
    }];
}
@end
