//
//  FMDeviceCell.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/16.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMDeviceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *allowImage;
@property (weak, nonatomic) IBOutlet UILabel *DeviceNameLb;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (weak, nonatomic) IBOutlet UILabel *disPlayLb;

@end
