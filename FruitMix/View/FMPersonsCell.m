//
//  FMPersonsCell.m
//  JYGooglePhotoAlert
//
//  Created by JackYang on 2017/1/8.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "FMPersonsCell.h"
#import "FMPersonCell.h"

@interface FMPersonsCell ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    NSUInteger  _count;
}

@end


@implementation FMPersonsCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier Count:(NSUInteger)count getCellsBlock:(getCollectionViewCell)block{
    self = [[[NSBundle mainBundle]loadNibNamed:@"FMPersonsCell" owner:nil options:nil] lastObject];
    [self.collectionView registerNib:[UINib nibWithNibName:@"FMPersonCell" bundle:nil] forCellWithReuseIdentifier:@"FMPersonCell"];
    _count = count;
    _getCollectionViewCellBlock = block;
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - collectionView

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _count;
}



-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FMPersonCell" forIndexPath:indexPath];
    return _getCollectionViewCellBlock(indexPath,cell);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_selectItemBlock) {
        _selectItemBlock(indexPath.row);
    }
}


-(CGFloat)cellH{
    return 109;
}
@end
