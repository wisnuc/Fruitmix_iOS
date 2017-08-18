//
//  LoginModel.m
//  FruitMix
//
//  Created by wisnuc on 2017/8/17.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "LoginModel.h"

@implementation LoginModel

-(NSMutableArray *)stationArray{
    if(!_stationArray){
        _stationArray = [NSMutableArray array];
    }
    return _stationArray;
}
@end
