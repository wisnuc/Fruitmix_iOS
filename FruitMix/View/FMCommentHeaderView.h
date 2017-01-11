//
//  FMCommentHeaderView.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/29.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMCommentHeaderView : UIView
@property (nonatomic) IBOutlet UILabel *headerTitleLabel;
@property (nonatomic) UIImage *headerImage;

+ (id)parallaxHeaderViewWithImage:(UIImage *)image forSize:(CGSize)headerSize;
+ (id)parallaxHeaderViewWithCGSize:(CGSize)headerSize;
- (void)layoutHeaderViewForScrollViewOffset:(CGPoint)offset;
@end
