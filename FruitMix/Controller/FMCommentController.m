//
//  FMCommentController.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/29.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMCommentController.h"
#import "FMCommentCell.h"
#import "MXParallaxHeader.h"
#import "FMCommentHeader.h"
#import "FMMediaShareTask.h"
#import "FMNeedUploadMediaShare.h"

@interface FMCommentController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>

@property (nonatomic) UITableView * tableView;

@property (nonatomic) NSMutableArray * dataSource;

@property (nonatomic) BRPlaceholderTextView * commentView;

@property (nonatomic) id navDelegate;

@property (nonatomic) UIView * toolbar;

@property (nonatomic) UIButton * sendBtn;

@property (nonatomic) UIView * headView;

@property (nonatomic) UIButton * backBtn;

@end

@implementation FMCommentController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
    [self addToolBar];
    [self registeNotify];
    [self initHeadView];
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    self.navDelegate =  self.navigationController.interactivePopGestureRecognizer.delegate;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self.navDelegate;
}

-(void)addToolBar{
    UIView * toolBar = [[UIView alloc]initWithFrame:CGRectMake(0, __kHeight-47, __kWidth, 47)];
    toolBar.backgroundColor = [UIColor whiteColor];
    BRPlaceholderTextView * commentView = [[BRPlaceholderTextView alloc]initWithFrame:CGRectMake(10, 0, __kWidth-80, 47)];
    self.commentView = commentView;
    commentView.placeholder = @"说点什么吧...";
    commentView.delegate = self;
    commentView.font = [UIFont fontWithName:DONGQING size:15];
    [commentView setPlaceholderColor:UICOLOR_RGB(0xbbbbbb)];
    [commentView setPlaceholderFont:[UIFont fontWithName:DONGQING size:17]];
    [self.view addSubview:toolBar];
    [toolBar addSubview:commentView];
    
    UIButton * sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(__kWidth-65, 0, 65, 47)];
    sendBtn.backgroundColor = UICOLOR_RGB(0x3f51b5);
    [sendBtn setImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [toolBar addSubview:sendBtn];
    self.toolbar = toolBar;
    self.sendBtn = sendBtn;
}

-(void)sendBtnClick:(UIButton *)btn{
    NSString * saytext = self.commentView.text;
    self.commentView.text = @"";
    [self.commentView setPlaceholderHidden:NO];
    [self.view endEditing:YES];
    if (saytext.length>0) {
        if (self.item.isLocal) {
            //对本地照片做评论
            id comment = [FMMediaShareTask mediaTaskAddCommentWithShareId:self.item.shareid andPhotoHash:_photoHash andText:saytext];
            [self.dataSource addObject:comment];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.dataSource.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
           
        }else
            [FMPostCommentAPI  postNewCommentWithComment:saytext andPhotoDigest:_photoHash andShareId:self.item.shareid andCompleteBlock:^(BOOL success,id response) {
                if (success) {
                    [[NSNotificationCenter defaultCenter]postNotificationName:CREATE_NEW_COMMENT object:nil];
                    [SXLoadingView showAlertHUD:@"评论成功" duration:1];
                    FMComment * comment = [FMComment new];
                    comment.shareid = response[@"shareid"];
                    comment.creator = response[@"creator"];
                    comment.text = response[@"text"];
                    comment.datatime = [response[@"datatime"] longLongValue];
                    [self.dataSource addObject:comment];
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.dataSource.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }else{
                    [SXLoadingView showAlertHUD:@"评论失败" duration:1];
                }
            }];
    }else
        [SXLoadingView showAlertHUD:@"请输入评论内容" duration:1];
}

-(void)reloadCommentView{
    [self.view endEditing:YES];
    self.commentView.text = nil;
    [self.commentView setPlaceholderHidden:NO];
}

-(void)initData{
    [self.dataSource addObjectsFromArray:[FMMediaShareTask mediaTask_SelectCommentWithPhotoHash:_photoHash]];
    [self.tableView reloadData];
    FMGetCommentsAPI * api = [FMGetCommentsAPI apiWithPhotoHash:_photoHash];
    [api startWithCompletionBlockWithSuccess:^(__kindof JYBaseRequest *request) {
        for (NSDictionary * dic in request.responseJsonObject) {
            FMComment * comment = [FMComment yy_modelWithJSON:dic];
            [self.dataSource addObject:comment];
        }
        [self.tableView reloadData];
    } failure:^(__kindof JYBaseRequest *request) {
        NSLog(@"获取评论出错");
    }];
}

-(void)registeNotify{
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(getNotify:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(getNotify:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)getNotify:(NSNotification *)notify{
    NSDictionary *userInfo = [notify userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat keyboardH = keyboardRect.size.height;
    CGFloat keyboardY= keyboardRect.origin.y;
    CGFloat viewH = [UIScreen mainScreen].bounds.size.height;
    CGFloat moveH = viewH-keyboardH;
    //animationValue
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    if (__kHeight<moveH) {
        [UIView animateWithDuration:animationDuration animations:^{
            self.toolbar.transform = CGAffineTransformIdentity;
        }];
        return ;
    }else{
        if (viewH == keyboardY) {
            [UIView animateWithDuration:animationDuration animations:^{
                self.toolbar.transform = CGAffineTransformIdentity;
            }];
            
        }else{
            [UIView animateWithDuration:animationDuration animations:^{
                self.toolbar.transform = CGAffineTransformMakeTranslation(0, -(__kHeight - moveH));
            }];
        }
    }
    
}

-(void)initHeadView{
//    NSString * degist = self.photoHash;
//    if ([PhotoManager managerCheckIfIsLocalPhoto:degist]) {
//        [[FMGetImage defaultGetImage] getOriginalImageWithLocalhash:degist andCompleteBlock:^(UIImage *image, NSString *tag) {
//           [(FMCommentHeader *)self.tableView.parallaxHeader.view headImageView].image = image;
//        }];
//    }else{
//        [[FMGetImage defaultGetImage] getOriginalImageWithHash:degist andCount:0 andPressBlock:nil andCompletBlock:^(UIImage *image, NSString *tag) {
//            [(FMCommentHeader *)self.tableView.parallaxHeader.view headImageView].image = image;
//        }];
//    }
}

-(void)initView{
    
    _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, __kWidth, 64)];
    _headView.backgroundColor = UICOLOR_RGB(0x3f51b5);
    [self.view addSubview:_headView];
    
    _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 18, 48, 48)];
    [_backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [_backBtn addTarget:self  action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:_backBtn];
    
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, __kWidth, __kHeight-47-64) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [FMCommentCell setTableViewWidth:self.tableView.frame.size.width];
    
    self.tableView.parallaxHeader.view = [[FMCommentHeader alloc]initWithFrame:CGRectMake(0, 0, __kWidth, 300)];
    self.tableView.parallaxHeader.height = 200;
    self.tableView.parallaxHeader.mode = MXParallaxHeaderModeFill;
    self.tableView.parallaxHeader.minimumHeight = 0;
    self.tableView.separatorStyle = NO;
    [self.view addSubview:_tableView];
}

-(void)backBtnClick:(UIButton *)backBtn{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numOfRows = self.dataSource.count;
    return numOfRows;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 0.0;
    FMComment *comment = self.dataSource[indexPath.row];
    NSString *content = comment.text;
    
    cellHeight += [FMCommentCell cellHeightForComment:content];
    return cellHeight;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self customCellForIndex:indexPath];
    FMComment *comment = self.dataSource[indexPath.row];
    [(FMCommentCell *)cell  configureCommentCellForComment:comment];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)customCellForIndex:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSString * detailId = kCellIdentifier;
    cell = [self.tableView dequeueReusableCellWithIdentifier:detailId];
    if (!cell)
    {
        cell = [FMCommentCell storyCommentCellForTableWidth:self.tableView.frame.size.width];
    }
    return cell;
}

#pragma mark UISCrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView)
    {
        [self reloadCommentView];
    }
}


#pragma mark - TextViewDelegate
-(void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length>0) {
        [_sendBtn setImage:[UIImage imageNamed:@"send-_select"] forState:UIControlStateNormal];
    }else{
        [_sendBtn setImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.text.length>0) {
        [_sendBtn setImage:[UIImage imageNamed:@"send-_select"] forState:UIControlStateNormal];
    }else{
        [_sendBtn setImage:[UIImage imageNamed:@"send"] forState:UIControlStateNormal];
    }
}
@end
