//
//  JYAlertView.h
//  JYGooglePhotoAlert
//
//  Created by 杨勇 on 17/1/5.
//  Copyright © 2017年 JackYang. All rights reserved.

#import <UIKit/UIKit.h>

@interface JYAlertView : UIScrollView

@property (nonatomic ,weak) id<UITableViewDelegate> jydelegate;

@property (nonatomic ,weak) id<UITableViewDataSource> jydataSource;

@property (nonatomic ,strong) UITableView * tableView;

@property (nonatomic ,assign) NSUInteger jyContentH;


+(JYAlertView *)jy_AlertViewCreateWithDelegate:(id<UITableViewDelegate>)delegate andDataSource:(id<UITableViewDataSource>)dataSource;


-(void)show;

-(void)dismiss;
@end
