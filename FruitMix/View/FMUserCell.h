//
//  FMUserCell.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/17.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMUserCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userHeadImageView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLb;

@property (nonatomic) UserModel * user;
@end
