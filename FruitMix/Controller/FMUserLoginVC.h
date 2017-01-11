//
//  FMUserLoginVC.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/17.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMUserLoginVC : FMBaseViewController
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (nonatomic) UserModel * user;

@property (nonatomic) FMSerachService * service;

@end
