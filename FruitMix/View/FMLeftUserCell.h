//
//  FMLeftUserCell.h
//  FruitMix
//
//  Created by JackYang on 2017/2/15.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMLeftUserCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userHeader;
@property (weak, nonatomic) IBOutlet UILabel *userNameLb;

@property (weak, nonatomic) IBOutlet UILabel *deviceNameLb;

+(CGFloat)height;

@end
