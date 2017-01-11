//
//  FMWaterfallController.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/26.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMWaterfallController : FMBaseViewController <UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout>{
    NSString * _abc;
}
@property (nonatomic)  UICollectionView *collectionView;

@property (nonatomic) id<FMMediaShareProtocol> album;

//是否显示 评论按钮
@property (nonatomic) BOOL canComments;

@end
