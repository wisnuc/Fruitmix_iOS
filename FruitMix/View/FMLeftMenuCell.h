//
//  FMLeftMenuCell.h
//  FruitMix
//
//  Created by 杨勇 on 16/11/16.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMLeftMenuCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *leftIV;
@property (weak, nonatomic) IBOutlet UILabel *leftTitleLb;

@property (weak, nonatomic) IBOutlet UIView *leftLine;

+(NSString *)identifier;

-(void)setup;

+(CGFloat) height;

-(void)setData:(id) data  andImageName:(NSString *)imageName;

@end
