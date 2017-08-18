//
//  FMBoxTwiterViewController.m
//  FruitMix
//
//  Created by wisnuc on 2017/8/11.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "FMBoxTwiterViewController.h"

@interface FMBoxTwiterViewController ()
@property (weak, nonatomic) IBOutlet UIToolbar *BottomBar;
@property (strong, nonatomic) UITextView *talkingTextView;
@end

@implementation FMBoxTwiterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

- (UITextView *)talkingTextView{
    if (!_talkingTextView) {
        _talkingTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        
    }
    return _talkingTextView;
}

@end
