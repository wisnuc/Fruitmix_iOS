//
//  FMLeftMenu.m
//  MenuDemo
//
//  Created by 杨勇 on 16/7/1.
//  Copyright © 2016年 Lying. All rights reserved.
//

#import "FMLeftMenu.h"
#import "FMLeftMenuCell.h"

@interface FMLeftMenu ()<UITableViewDelegate,UITableViewDataSource>


@end

@implementation FMLeftMenu

-(void)awakeFromNib{
    [super awakeFromNib];
//    self.userHeaderIV.layer.cornerRadius = self.userHeaderIV.frame.size.width/2;
//    self.userHeaderIV.backgroundColor = [UIColor blackColor];
    _settingTabelView.delegate = self;
    _settingTabelView.dataSource = self;
    _settingTabelView.scrollEnabled = NO;
    _settingTabelView.tableFooterView = [UIView new];
    self.userHeaderIV.userInteractionEnabled = YES;
    [self.userHeaderIV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeader:)]];
}
- (void)tapHeader:(id)sender {
//    if(self.delegate){
//        [self.delegate LeftMenuViewClick:10 andTitle:@"个人信息"];
//    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.nameLabel.font = [UIFont fontWithName:DONGQING size:14];
    self.nameLabel.text = [FMConfigInstance getUserNameWithUUID:DEF_UUID];
    self.userHeaderIV.image = [UIImage imageForName:self.nameLabel.text size:self.userHeaderIV.bounds.size];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return self.menus.count - 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FMLeftMenuCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FMLeftMenuCell" owner:nil options:nil] lastObject];
    if (indexPath.section == 0) {
        cell.leftLine.backgroundColor = [UIColor blackColor];
        [cell setData:_menus[indexPath.row] andImageName:_imageNames[indexPath.row]];
    }else{
        [cell setData:_menus[indexPath.row + 1] andImageName:_imageNames[indexPath.row + 1]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.delegate){
        [self.delegate LeftMenuViewClick:indexPath.section == 0? indexPath.row:indexPath.row+1 andTitle:indexPath.section == 0? self.menus[indexPath.row]:self.menus[indexPath.row+1]];
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 8;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 )
        return 72;
    return  [FMLeftMenuCell height];
}


@end
