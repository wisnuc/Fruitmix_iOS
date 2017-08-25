//
//  FLDownloadingCell.h
//  FruitMix
//
//  Created by 杨勇 on 16/10/11.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FLDownloadingCell;
typedef void(^cancelBtnClockBlock)(FLDownloadingCell * cell);

@interface FLDownloadingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *fileImageView;
@property (weak, nonatomic) IBOutlet UILabel *filenameLb;
@property (weak, nonatomic) IBOutlet UILabel *downloadProgressLb;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic) cancelBtnClockBlock clickBlock;
@end
