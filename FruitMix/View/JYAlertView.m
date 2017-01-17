//
//  JYAlertView.m
//  JYGooglePhotoAlert
//
//  Created by 杨勇 on 17/1/5.
//  Copyright © 2017年 JackYang. All rights reserved.
//

#import "JYAlertView.h"

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

#define kDefaultViewH roundf(kHeight/3*2)

@interface JYAlertView ()<UIScrollViewDelegate>{
    UIView * _backViewForTableView;
    UIView * _blackView;
    BOOL _isDissmiss;
}
@end

@implementation JYAlertView

+(JYAlertView *)jy_AlertViewCreateWithDelegate:(id<UITableViewDelegate>)delegate andDataSource:(id<UITableViewDataSource>)dataSource{
    JYAlertView * alertView = [[JYAlertView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
    alertView.jydelegate = delegate;
    alertView.jydataSource = dataSource;
    [alertView setUpViews];
    return alertView;
}


-(void)setUpViews{
    _isDissmiss = NO;
    self.backgroundColor = [UIColor clearColor];
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    UIView * backViewForTableView = [UIView new];
    backViewForTableView.backgroundColor = [UIColor whiteColor];
    backViewForTableView.frame = CGRectMake(0, 0, kWidth, 2*kHeight);
    [self addSubview:backViewForTableView];
    _backViewForTableView = backViewForTableView;
    
    //获取TableView的高 及配置 tableView
    _jyContentH = [self setUpTableView];
    
    backViewForTableView.frame = CGRectMake(0, _tableView.jy_Top, kWidth, 2*kHeight);
    CGFloat selfH = _jyContentH>kHeight ? 2 * kHeight - kDefaultViewH : (_jyContentH > kDefaultViewH ? kHeight-kDefaultViewH + _jyContentH : kHeight + 1);
    self.contentSize = CGSizeMake(0, selfH);
    UIView * blackView = [UIView new];
    blackView.frame = CGRectMake(0, -kHeight, kWidth,kHeight + _tableView.jy_Top);
    blackView.backgroundColor = [UIColor blackColor];
    blackView.alpha = 0.5;
    [self addSubview:blackView];
    _blackView = blackView;
    [self.tableView addObserver:self  forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self  forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld  context:nil];
    
    _tableView.jy_Top += kDefaultViewH;
    backViewForTableView.jy_Top +=kDefaultViewH;
    blackView.jy_Top += kDefaultViewH;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
    [blackView addGestureRecognizer:tap];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _tableView.jy_Top -= kDefaultViewH;
        backViewForTableView.jy_Top -=kDefaultViewH;
        blackView.jy_Top -= kDefaultViewH;
    } completion:nil];
}

-(CGFloat)setUpTableView{
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = _jydelegate;
    _tableView.dataSource = _jydataSource;
    _tableView.scrollEnabled = NO;
    _tableView.tableFooterView = [UIView new];
    _tableView.sectionHeaderHeight = 40;
    _tableView.rowHeight = 56;
    [self addSubview:_tableView];
    if (!self.jydataSource) return 0;
    CGFloat allH = 0;//总高度
    CGFloat defaultCellH = 56;//默认cell高度
    for (int i = 0; i< [_tableView numberOfSections]; i++) {
        allH += 40;//默认session header高度
        for (int j = 0; j< [_tableView numberOfRowsInSection:i]; j++) {
            if ([_jydelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) allH += [_jydelegate tableView:_tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            else allH += defaultCellH;
        }
    }
    CGFloat tableViewY = allH < kDefaultViewH?kHeight-allH:kHeight-kDefaultViewH;
    CGFloat tableViewH = allH>kHeight?kHeight:allH;
    _tableView.frame = CGRectMake(0, tableViewY, kWidth, tableViewH);
    return allH;
}

-(void)dealloc{
    [self removeObserver:self forKeyPath:@"contentOffset"];
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (![keyPath isEqualToString:@"contentOffset"]) return;
    if (_jyContentH < kHeight){
        _tableView.scrollEnabled = NO;
        self.scrollEnabled = YES;
    }else{
        CGPoint newPoint ,oldPoint;
        id newValue = [ change valueForKey:NSKeyValueChangeNewKey ];
        [(NSValue*)newValue getValue:&newPoint ];
        id oldValue = [ change valueForKey:NSKeyValueChangeOldKey ];
        [(NSValue*)oldValue getValue:&oldPoint ];
        if (object == self)
            [self checkScrollWithOldPoint:oldPoint newPoint:newPoint];
        else if(object == self.tableView)
            [self checkTableView];
    }
}

//a < kDef
//                      ====> tableViewEnable = NO; scrollViewEnable = YES;
// kH > a > kDef


static BOOL isDownScroll = YES;
// a> kH
-(void)checkScrollWithOldPoint:(CGPoint)old newPoint:(CGPoint)new{
    isDownScroll =  old.y > new.y;
    //scroll
    if (new.y == kHeight -kDefaultViewH) {
        self.tableView.scrollEnabled = YES;
        self.scrollEnabled = YES;
    }
    else if (old.y < kHeight -kDefaultViewH && new.y < kHeight - kDefaultViewH) {
        self.tableView.scrollEnabled = NO;
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        self.scrollEnabled = YES;
    }else if(old.y <= kHeight -kDefaultViewH && new.y > kHeight - kDefaultViewH){
        self.tableView.scrollEnabled = YES;
        self.scrollEnabled = NO;
        [self setContentOffset:CGPointMake(0, kHeight - kDefaultViewH) animated:NO];
    }
    
    if (!self.isDragging) {
        
    }
}


-(void)checkTableView{
    if (self.tableView.contentOffset.y == 0 && self.contentOffset.y == kHeight - kDefaultViewH) {
        self.scrollEnabled = YES;
        self.tableView.scrollEnabled = YES;
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ((self.contentOffset.y < 30 && !isDownScroll) || (self.contentOffset.y < self.contentSize.height - kHeight - 30 && isDownScroll)) {
        [self setContentOffset:CGPointMake(0, 0) animated:YES];
    }else{
        [self setContentOffset:CGPointMake(0, self.contentSize.height - kHeight) animated:YES];
    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if (self.contentOffset.y < -10 && isDownScroll){
        [self dismiss];
    }else if ((self.contentOffset.y < 30 && !isDownScroll) || (self.contentOffset.y < self.contentSize.height - kHeight - 30 && isDownScroll)) {
        [self setContentOffset:CGPointMake(0, 0) animated:YES];
    }else{
        [self setContentOffset:CGPointMake(0, self.contentSize.height - kHeight) animated:YES];
    }
}

-(void)dismiss{
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _tableView.jy_Top += kDefaultViewH;
        _backViewForTableView.jy_Top +=kDefaultViewH;
        _blackView.jy_Top += kDefaultViewH;
        _blackView.alpha = 0 ;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        _isDissmiss = YES;
    }];
}

-(void)show{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    if (_isDissmiss) {
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _tableView.jy_Top -= kDefaultViewH;
            _backViewForTableView.jy_Top -=kDefaultViewH;
            _blackView.jy_Top -= kDefaultViewH;
            _blackView.alpha = 1 ;
        } completion:nil];
    }
}


@end
