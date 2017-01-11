//
//  FMShareSetItem.h
//  FruitMix
//
//  Created by 杨勇 on 16/5/3.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FMShareSetItemDelegate <NSObject>
@required
-(void)fmSet_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface FMShareSetItem : UICollectionView<IDMPhotoBrowserDelegate>

@property (nonatomic) id<FMShareSetItemDelegate> fmDelegate;

@property (nonatomic) id<FMMediaShareProtocol> share;

+(NSInteger)getHeightWithModel:(id<FMMediaShareProtocol>)model;

@end
