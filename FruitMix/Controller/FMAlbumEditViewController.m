//
//  FMAlbumEditViewController.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/6.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMAlbumEditViewController.h"
#import "FMMediaShareTask.h"
#import "FMAlbumDataSource.h"

@interface FMAlbumEditViewController ()<UITextViewDelegate>
@property (nonatomic) UIButton * rightBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descLayoutH;
@property (weak, nonatomic) IBOutlet UIButton *boxBtn;
@property (weak, nonatomic) IBOutlet UIButton *permissBtn;
@property (nonatomic) BOOL isFinishLoadItems;
@property (nonatomic) BOOL isPublic;
@property (weak, nonatomic) IBOutlet UIButton *canAddBtn;
@property (nonatomic) BOOL canAdd;

@end

@implementation FMAlbumEditViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self performSelector:@selector(textViewDidChange:) withObject:_albumDescTV afterDelay:0.2];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    self.isPublic = self.album.viewers.count>1;//初始化权限 是否公开
    self.canAdd = self.album.maintainers.count>1;
}

-(void)setIsPublic:(BOOL)isPublic{
    _isPublic = isPublic;
    [self.boxBtn setImage:_isPublic?[UIImage imageNamed:@"check-box_select"]:[UIImage imageNamed:@"check-box"] forState:UIControlStateNormal];
    if (!_isPublic) {
        self.canAdd = NO;
    }
    self.canAddBtn.userInteractionEnabled = _isPublic;
}

-(void)setCanAdd:(BOOL)canAdd{
    _canAdd = canAdd;
    [self.canAddBtn setImage:canAdd?[UIImage imageNamed:@"check-box_select"]:[UIImage imageNamed:@"check-box"] forState:UIControlStateNormal];
}

- (IBAction)canAddBtnClick:(id)sender {
    self.canAdd = !self.canAdd;
}

-(void)configureView{
    self.albumNameTF.placeholder = [NSString stringWithFormat:@"未命名 %@",[NSDate getDateStringWithPhoto:[NSDate getFormatDateWithDate:[NSDate date]]]];
    self.albumDescTV.delegate = self;
    self.rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 48, 48)];
    if(_album.isAlbum){
        NSDictionary * dic = _album.album;
        self.albumNameTF.text = dic[@"title"];
        self.albumDescTV.text = dic[@"text"];
    }
    [_rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    _rightBtn.titleLabel.font = [UIFont fontWithName:DONGQING size:16];
    UIBarButtonItem *negativeSpacer = [[ UIBarButtonItem alloc ]
                                       
                                       initWithBarButtonSystemItem : UIBarButtonSystemItemFixedSpace
                                       
                                       target : nil action : nil ];
    
    negativeSpacer. width = -8;
    [_rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,[[UIBarButtonItem alloc]initWithCustomView:_rightBtn]];
}

-(void)textViewDidChange:(UITextView *)textView{
    CGFloat maxH = 80;
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height <= frame.size.height) {
        size.height = frame.size.height;
    } else {
        if (size.height >= maxH) {
            size.height = maxH ;
            textView.scrollEnabled = YES;
        } else {
            textView.scrollEnabled = NO;
        }
    }
    self.descLayoutH.constant = size.height;
}


-(void)rightBtnClick:(id)sender{
    if (self.albumNameTF.text.length >= 20) {
        [MyAppDelegate.notification displayNotificationWithMessage:@"相册名称过长!" forDuration:1];
        return;
    }
    NSMutableDictionary * album = [NSMutableDictionary dictionaryWithCapacity:0];
    [album setObject:self.albumNameTF.text?self.albumNameTF.text:(self.albumNameTF.placeholder?self.albumNameTF.placeholder:@"") forKey:@"title"];
    [album setObject:self.albumDescTV.text?self.albumDescTV.text:@"" forKey:@"text"];
    
    [FMAlbumDataSource updateAlbum:self.album andAlbum:album andIsPublic:_isPublic andCanAdd:_canAdd andComPleteBlock:^(BOOL success) {
        [SXLoadingView showAlertHUD:success?@"修改成功":@"修改失败" duration:1];
        if(success)
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (IBAction)permissBtn:(id)sender {
    self.isPublic = !self.isPublic;
}

-(void)leftBtnClick:(id)sender{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}
- (IBAction)handleTapGesture:(id)sender {
    [self.view endEditing:YES];
}

@end
