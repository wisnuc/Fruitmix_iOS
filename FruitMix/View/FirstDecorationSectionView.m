//
//  FirstDecorationSectionView.m
//  TYDecorationSectionLayoutDemo
//
//  Created by tanyang on 15/12/29.
//  Copyright © 2015年 tanyang. All rights reserved.
//

#import "FirstDecorationSectionView.h"

@implementation FirstDecorationSectionView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    self.backgroundColor = UICOLOR_RGB(0xe2e2e2);
    self.backgroundColor = [UIColor whiteColor];
    self.cardView.backgroundColor  = [UIColor whiteColor];
    
//    self.cardView.backgroundColor = UICOLOR_RGB(0xfafafa);
//    self.cardView.layer.sh
//    self.cardView.layer.shadowColor = [[UIColor blackColor]CGColor];
//    self.cardView.layer.shadowOffset = CGSizeMake(0, -2);
//    self.cardView.layer.shadowRadius = 5.0;
//    self.cardView.layer.shadowOpacity = 0.3;
}

@end
