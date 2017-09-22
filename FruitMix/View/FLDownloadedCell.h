//
//  FLDownloadedCell.h
//  FruitMix
//
//  Created by 杨勇 on 16/10/11.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLDownloadedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *fileImageView;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLb;
@property (weak, nonatomic) IBOutlet UILabel *downloadTimeLb;
    @property (weak, nonatomic) IBOutlet UILabel *sizeLb;
    
@end
