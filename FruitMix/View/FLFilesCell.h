//
//  FLFilesCell.h
//  FruitMix
//
//  Created by 杨勇 on 16/10/14.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum : NSUInteger {
    FLFliesCellStatusNormal = 0,
    FLFliesCellStatusCanChoose,
} FLFliesCellStatus;

@class FLFilesCell;
typedef void(^downBtnClockBlock)(FLFilesCell * cell);
typedef void(^longPressBlock)(FLFilesCell * cell);

@interface FLFilesCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *layerView;
@property (weak, nonatomic) IBOutlet UIImageView *f_ImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *downBtn;

@property (nonatomic) downBtnClockBlock clickBlock;
@property (nonatomic) longPressBlock longpressBlock;
@property (nonatomic) FLFliesCellStatus status;

@end
