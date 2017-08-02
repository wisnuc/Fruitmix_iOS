//
//  FMAlbumNamedController.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/19.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMAlbumNamedController.h"
#import "FMAlbumDataSource.h"

@interface FMAlbumNamedController ()<UITextViewDelegate,UITextFieldDelegate>
@property (nonatomic) UIButton * rightBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descLayoutH;
@property (weak, nonatomic) IBOutlet UIButton *boxBtn;
@property (weak, nonatomic) IBOutlet UIButton *permissBtn;
@property (weak, nonatomic) IBOutlet UIView *descLine;
@property (nonatomic) BOOL isFinishLoadItems;
@property (nonatomic) BOOL isPermiss;
@property (nonatomic) BOOL canAdd;

@property (weak, nonatomic) IBOutlet UIButton *canAddBtn;
@property (weak, nonatomic) IBOutlet UILabel *canAddLabel;

@end

@implementation FMAlbumNamedController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
    _isPermiss = NO;//初始化权限 是否公开
    _canAdd = NO;
    self.canAddBtn.userInteractionEnabled = NO;
//    self.modalTransitionStyle = UIModalTransitionStylePartialCurl;
}



-(void)configureView{
    self.albumNameTF.placeholder = [NSString stringWithFormat:@"未命名 %@",[NSDate getDateStringWithPhoto:[NSDate getFormatDateWithDate:[NSDate date]]]];
    self.albumNameTF.delegate = self;
    self.albumDescTV.delegate = self;
    self.rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 40, 20)];
    if (!IsNilString(_albumName)) {
        self.albumNameTF.text = _albumName;
    }
    if (!IsNilString(_albumDesc)) {
        self.albumDescTV.text = _albumDesc;
    }
    [_rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    _rightBtn.titleLabel.font = [UIFont fontWithName:DONGQING size:16];
    [_rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    if(self.namedState == NamedUseInPhoto){
        UIView  * headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, __kWidth, 64)];
        headView.backgroundColor = UICOLOR_RGB(0x3f51b5);
        [self.view addSubview:headView];
        self.rightBtn.frame = CGRectMake(__kWidth - 56, 18, 48, 48);
        [headView addSubview:_rightBtn];
        
        UIButton * leftBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 18, 48, 48)];
        [leftBtn setImage:[UIImage imageNamed:@"back_gray"]
                 forState:UIControlStateNormal];
        [leftBtn setImage:[UIImage imageNamed:@"back_grayhighlight"]
                 forState:UIControlStateHighlighted];
        [leftBtn addTarget:self
                    action:@selector(leftBtnClick:)
          forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:leftBtn];
    }else{
        UIBarButtonItem *negativeSpacer = [[ UIBarButtonItem alloc ]
                                           
                                           initWithBarButtonSystemItem : UIBarButtonSystemItemFixedSpace
                                           
                                           target : nil action : nil ];
        
        negativeSpacer. width = -8;
        _rightBtn.frame = CGRectMake(0, 0, 48, 48);
        self.navigationItem.rightBarButtonItems = @[negativeSpacer ,[[UIBarButtonItem alloc]initWithCustomView:_rightBtn] ];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (string.length == 0) {
        return YES;
    }
    else if (textField.text.length + string.length >20 ) {
        [MyAppDelegate.notification displayNotificationWithMessage:@"相册名称不能大于20个字符" forDuration:1];
        return NO;
    }
    return YES;
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
    if (self.albumNameTF.text.length > 20) {
        [MyAppDelegate.notification displayNotificationWithMessage:@"相册名称过长" forDuration:1];
        return;
    }
    
    [SXLoadingView showProgressHUD:@"正在准备照片"];
    
    NSString * nameStr = self.albumNameTF.text;
    if (IsNilString(nameStr)) {
        nameStr = self.albumNameTF.placeholder;
    }
    NSString * descStr = self.albumDescTV.text;
    
    NSMutableDictionary * album = [NSMutableDictionary dictionaryWithCapacity:0];
    [album setValue:nameStr forKey:TitleKey];
    [album setValue:descStr forKey:TextKey];
    
    NSMutableArray * contents = [NSMutableArray arrayWithCapacity:0];
    for (id<IDMPhoto> photo in self.photoArr) {
        NSString * digest = [photo getPhotoHash];
        if (IsNilString(digest) && [photo isKindOfClass:[FMPhotoAsset class]]) {
            digest = [(FMPhotoAsset *)photo getPhotoHashSync];
        }
        [contents addObject:digest];
    }
    
    NSMutableArray * maintainers = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray * viewers = [NSMutableArray arrayWithCapacity:0];
    if(_canAdd && _isPermiss){
        [maintainers addObjectsFromArray:[FMDBControl getAllUsersUUID]];
    }else if(_isPermiss){
        [viewers addObjectsFromArray:[FMDBControl getAllUsersUUID]];
    }
    [SXLoadingView hideProgressHUD];
    [FMAlbumDataSource createAlbumWithMaintainers:maintainers Viewers:viewers Contents:contents IsAlbum:album andComPleteBlock:^(BOOL success) {
         [SXLoadingView showAlertHUD:[NSString stringWithFormat:@"创建相册%@",success?@"成功":@"失败"] duration:1];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FM_NEED_UPDATE_UI_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:APP_JUMP_TO_ALBUM_NOTIFY object:nil];

    if (self.namedState == NamedUseInPhoto) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

-(void)setCanAdd:(BOOL)canAdd{
    _canAdd = canAdd;
    if (canAdd) {
        [self.canAddBtn setImage:[UIImage imageNamed:@"check-box_select"] forState:UIControlStateNormal];
    }
    else
        [self.canAddBtn setImage:[UIImage imageNamed:@"check-box"] forState:UIControlStateNormal];
}

- (IBAction)canAddBtnClick:(id)sender {
    self.canAdd = !self.canAdd;
}

- (IBAction)permissBtn:(id)sender {
    _isPermiss = !_isPermiss;
    [self.boxBtn setImage:_isPermiss?[UIImage imageNamed:@"check-box_select"]:[UIImage imageNamed:@"check-box"] forState:UIControlStateNormal];
    self.canAddBtn.userInteractionEnabled = _isPermiss;
    if (!_isPermiss) {
        self.canAdd = NO;
    }
}

-(void)leftBtnClick:(id)sender{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
}
- (IBAction)handleTapGesture:(id)sender {
    [self.view endEditing:YES];
}
@end
