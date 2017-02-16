//
//  FMLeftMenu.m
//  MenuDemo
//
//  Created by 杨勇 on 16/7/1.
//  Copyright © 2016年 Lying. All rights reserved.
//

#import "FMLeftMenu.h"
#import "FMLeftMenuCell.h"
#import "FMLeftUserCell.h"

@interface FMLeftMenu ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *versionLb;

@end

@implementation FMLeftMenu

-(void)awakeFromNib{
    [super awakeFromNib];
//    self.userHeaderIV.layer.cornerRadius = self.userHeaderIV.frame.size.width/2;
//    self.userHeaderIV.backgroundColor = [UIColor blackColor];
    _settingTabelView.delegate = self;
    _settingTabelView.dataSource = self;
    
    _usersTableView.dataSource = self;
    _usersTableView.delegate = self;
    _isUserTableViewShow = NO;
    
    _settingTabelView.scrollEnabled = NO;
    _settingTabelView.tableFooterView = [UIView new];
    _usersTableView.tableFooterView = [UIView new];
    self.userHeaderIV.userInteractionEnabled = YES;
    [self.userHeaderIV addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeader:)]];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app名称
//    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleName"];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleVersion"];
    self.versionLb.text = [NSString stringWithFormat:@"WISNUC %@",app_Version];
}

- (IBAction)dropDownBtnClick:(id)sender {
    _isUserTableViewShow = !_isUserTableViewShow;
    if (_isUserTableViewShow) {
        ((UIButton *)sender).transform = CGAffineTransformMakeRotation(M_PI);
        [UIView animateWithDuration:0.3 animations:^{
            _usersTableView.alpha = 1;
            self.usersDatasource = [NSMutableArray arrayWithArray:[FMDBControl getAllUserLoginInfo]];
            [_usersTableView reloadData];
        } completion:nil];
    }else{
        ((UIButton *)sender).transform = CGAffineTransformIdentity;
        NSMutableArray * tempArr = self.menus;
        self.menus = [NSMutableArray new];
        [_settingTabelView reloadData];
        self.menus = tempArr;
        [UIView animateWithDuration:0.3 animations:^{
            _usersTableView.alpha = 0;
            [_settingTabelView reloadData];
        } completion:^(BOOL finished) {
            self.usersDatasource = [NSMutableArray new];
            [_usersTableView reloadData];
        }];
    }
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
    if(tableView == _settingTabelView)
        return 2;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == _settingTabelView){
        if (section == 0) {
            return 1;
        }
        return self.menus.count - 1;
    }else
        return self.usersDatasource.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _settingTabelView) {
        FMLeftMenuCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"FMLeftMenuCell" owner:nil options:nil] lastObject];
        if (indexPath.section == 0) {
            cell.leftLine.backgroundColor = [UIColor blackColor];
            [cell setData:_menus[indexPath.row] andImageName:_imageNames[indexPath.row]];
        }else{
            [cell setData:_menus[indexPath.row + 1] andImageName:_imageNames[indexPath.row + 1]];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else{
        FMLeftUserCell * cell =  [[[NSBundle mainBundle] loadNibNamed:@"FMLeftUserCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        FMUserLoginInfo * info =  self.usersDatasource[indexPath.row];
        cell.userNameLb.text = info.userName;
        cell.deviceNameLb.text = info.bonjour_name;
        cell.userHeader.image = [UIImage imageForName:info.userName size:cell.userHeader.bounds.size];
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == _settingTabelView){
        if(self.delegate){
            [self.delegate LeftMenuViewClickSettingTable:indexPath.section == 0? indexPath.row:indexPath.row+1 andTitle:indexPath.section == 0? self.menus[indexPath.row]:self.menus[indexPath.row+1]];
        }
    }else{
        if(self.delegate){
            [self.delegate LeftMenuViewClickUserTable:self.usersDatasource[indexPath.row]];
        }
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
    if(tableView == _settingTabelView){
        if(indexPath.section == 0 )
            return 72;
        return  [FMLeftMenuCell height];
    }else{
        return [FMLeftUserCell height];
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    double delay = (indexPath.row*indexPath.row) * 0.004;  //Quadratic time function for progressive delay
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.95, 0.95);
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(0,(tableView == _settingTabelView?1:-1)*(indexPath.row+1)*CGRectGetHeight(cell.contentView.frame));
    cell.transform = CGAffineTransformConcat(scaleTransform, translationTransform);
    cell.alpha = 0.f;
    
    [UIView animateWithDuration:0.6/2 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         cell.transform = CGAffineTransformIdentity;
         cell.alpha = 1.f;
         
     } completion:nil];
    
}

@end
