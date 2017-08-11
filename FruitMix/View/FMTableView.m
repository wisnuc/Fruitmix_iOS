//
//  FMTableView.m
//  FruitMix
//
//  Created by wisnuc on 2017/8/7.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMTableView.h"

@implementation FMTableView

- (instancetype)init{
    self = [super init];
    if (self) {
         self.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
       self.contentInset = UIEdgeInsetsMake(44, 0, 0, 0); 
    }
    return self;
}

@end
