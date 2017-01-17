//
//  FMPersonsCell.h
//  JYGooglePhotoAlert
//
//  Created by JackYang on 2017/1/8.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMGroup.h"

typedef UICollectionViewCell * (^getCollectionViewCell) (NSIndexPath * indexPath ,UICollectionViewCell * cell);

typedef void (^selectItemBlock)(NSInteger index);

@interface FMPersonsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (copy ,nonatomic) selectItemBlock selectItemBlock;

@property (nonatomic , copy) getCollectionViewCell  getCollectionViewCellBlock;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier Count:(NSUInteger)count getCellsBlock:(getCollectionViewCell)block;

-(CGFloat)cellH;

@end
