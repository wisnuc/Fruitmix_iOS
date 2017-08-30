//
//  IDMPhotoBrowser.m
//  IDMPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "IDMPhotoBrowser.h"
#import "Masonry.h"
#import "pop/POP.h"
#import "FMAlbumNamedController.h"
#import "FMCommentController.h"
#import "FMBalloon.h"
#ifndef IDMPhotoBrowserLocalizedStrings
#define IDMPhotoBrowserLocalizedStrings(key) \
NSLocalizedStringFromTableInBundle((key), nil, [NSBundle bundleWithPath:[[NSBundle bundleForClass: self.class] pathForResource:@"IDMPBLocalizations" ofType:@"bundle"]], nil)
#endif

// Private
@interface IDMPhotoBrowser () {
    
    //JY
    UIView * _jyTitleView;//headView
    UIButton * _jyBackBtn;//
    UILabel * _jyTitleLabel;//titlelabel
    UILabel * _jyTimeLabel;
    BOOL _isShowTitleView;
    
    
    UIDeviceOrientation _nowRotateOrientation;
    UIView * _blackViewForRotate;
    BOOL  _isDismiss;
//    NSBlockOperation * _op;//加载图的op
    
    UIButton * _controlBtn;
    BOOL _isControlBtnSelected;
    
    BOOL _isShowControlbtn;
    
    NSMutableArray * _chooseArray;
    
    UIImageView * _jyToolBar;
    
    //talk view
    
    UIView * _talkView;
    UIButton * _talkBtn;//说话按钮
    UIButton * _zanbtn;//赞 按钮
    
    /*********************************************************/
    // Data
    NSMutableArray *_photos;
    
    // Views
    UIScrollView *_pagingScrollView;
    
    // Gesture
    UIPanGestureRecognizer *_panGesture;
    
    // Paging
    NSMutableSet *_visiblePages, *_recycledPages;
    NSUInteger _pageIndexBeforeRotation;
    NSUInteger _currentPageIndex;
    
    // Buttons
    UIButton *_doneButton;
    
    // Toolbar
    UIToolbar *_toolbar;
    UIBarButtonItem *_previousButton, *_nextButton, *_actionButton;
    UIBarButtonItem *_counterButton;
    UILabel *_counterLabel;
    
    // Actions
    UIActionSheet *_actionsSheet;
    UIActivityViewController *activityViewController;
    
    // Control
    NSTimer *_controlVisibilityTimer;
    
    // Appearance
    //UIStatusBarStyle _previousStatusBarStyle;
    BOOL _statusBarOriginallyHidden;
    
    // Present
    UIView *_senderViewForAnimation;
    
    // Misc
    BOOL _performingLayout;
    BOOL _rotating;
    BOOL _viewIsActive; // active as in it's in the view heirarchy
    BOOL _autoHide;
    NSInteger _initalPageIndex;
    
    BOOL _isdraggingPhoto;
    
    CGRect _senderViewOriginalFrame;
    //UIImage *_backgroundScreenshot;
    
    UIWindow *_applicationWindow;
    
    // iOS 7
    UIViewController *_applicationTopViewController;
    int _previousModalPresentationStyle;
}

// Private Properties
@property (nonatomic, strong) UIActionSheet *actionsSheet;
@property (nonatomic, strong) UIActivityViewController *activityViewController;

// Private Methods

// Layout
- (void)performLayout;

// Paging
- (void)tilePages;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (IDMZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index;
- (IDMZoomingScrollView *)pageDisplayingPhoto:(id<IDMPhoto>)photo;
- (IDMZoomingScrollView *)dequeueRecycledPage;
- (void)configurePage:(IDMZoomingScrollView *)page forIndex:(NSUInteger)index;
- (void)didStartViewingPageAtIndex:(NSUInteger)index;

// Frames
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index;
- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation;
- (CGRect)frameForDoneButtonAtOrientation:(UIInterfaceOrientation)orientation;
- (CGRect)frameForCaptionView:(IDMCaptionView *)captionView atIndex:(NSUInteger)index;

// Toolbar
- (void)updateToolbar;

// Navigation
- (void)jumpToPageAtIndex:(NSUInteger)index;
- (void)gotoPreviousPage;
- (void)gotoNextPage;

// Controls
- (void)cancelControlHiding;
- (void)hideControlsAfterDelay;
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent;
- (void)toggleControls;
- (BOOL)areControlsHidden;

// Data
- (NSUInteger)numberOfPhotos;
- (id<IDMPhoto>)photoAtIndex:(NSUInteger)index;
- (UIImage *)imageForPhoto:(id<IDMPhoto>)photo;
- (void)loadAdjacentPhotosIfNecessary:(id<IDMPhoto>)photo;
- (void)releaseAllUnderlyingPhotos;

@end

// IDMPhotoBrowser
@implementation IDMPhotoBrowser

// Properties
@synthesize displayDoneButton = _displayDoneButton, displayToolbar = _displayToolbar, displayActionButton = _displayActionButton, displayCounterLabel = _displayCounterLabel, useWhiteBackgroundColor = _useWhiteBackgroundColor, doneButtonImage = _doneButtonImage;
@synthesize leftArrowImage = _leftArrowImage, rightArrowImage = _rightArrowImage, leftArrowSelectedImage = _leftArrowSelectedImage, rightArrowSelectedImage = _rightArrowSelectedImage;
@synthesize displayArrowButton = _displayArrowButton, actionButtonTitles = _actionButtonTitles;
@synthesize arrowButtonsChangePhotosAnimated = _arrowButtonsChangePhotosAnimated;
@synthesize forceHideStatusBar = _forceHideStatusBar;
@synthesize usePopAnimation = _usePopAnimation;
@synthesize disableVerticalSwipe = _disableVerticalSwipe;
@synthesize actionsSheet = _actionsSheet, activityViewController = _activityViewController;
@synthesize trackTintColor = _trackTintColor, progressTintColor = _progressTintColor;
@synthesize delegate = _delegate;

#pragma mark - NSObject

- (id)init {
    if ((self = [super init])) {
        // Defaults
        self.hidesBottomBarWhenPushed = YES;
        
        _photoState = JYPhotoNormal;//jy
        _showTalkView = NO;
        _isShowTitleView = YES;
        
        _currentPageIndex = 0;
        _performingLayout = NO; // Reset on view did appear
        _rotating = NO;
        _viewIsActive = NO;
        _visiblePages = [NSMutableSet new];
        _recycledPages = [NSMutableSet new];
        _photos = [NSMutableArray new];
        
        _initalPageIndex = 0;
        _autoHide = YES;
        
        _displayDoneButton = YES;
        _doneButtonImage = nil;
        
        _displayToolbar = YES;
        _displayActionButton = YES;
        _displayArrowButton = YES;
        _displayCounterLabel = NO;
        
        _forceHideStatusBar = NO;
        _usePopAnimation = NO;
        _disableVerticalSwipe = NO;
        
        _useWhiteBackgroundColor = NO;
        _leftArrowImage = _rightArrowImage = _leftArrowSelectedImage = _rightArrowSelectedImage = nil;
        
        _arrowButtonsChangePhotosAnimated = YES;
        
        _backgroundScaleFactor = 1.0;
        _animationDuration = 0.28;
        _senderViewForAnimation = nil;
        _scaleImage = nil;
        
        _isdraggingPhoto = NO;
        
        if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
            self.automaticallyAdjustsScrollViewInsets = NO;
        
        _applicationWindow = [[[UIApplication sharedApplication] delegate] window];
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        {
            self.modalPresentationStyle = UIModalPresentationCustom;
            self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            self.modalPresentationCapturesStatusBarAppearance = YES;
        }
        else
        {
            _applicationTopViewController = [self topviewController];
            _previousModalPresentationStyle = _applicationTopViewController.modalPresentationStyle;
            _applicationTopViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
            self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        }
        
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        // Listen for IDMPhoto notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleIDMPhotoLoadingDidEndNotification:)
                                                     name:IDMPhoto_LOADING_DID_END_NOTIFICATION
                                                   object:nil];
        
        //jy
        _isShowControlbtn = NO;
        _chooseArray = [NSMutableArray arrayWithCapacity:0];
        
    }
    
    return self;
}

- (id)initWithPhotos:(NSArray *)photosArray {
    if ((self = [self init])) {
        _photos = [[NSMutableArray alloc] initWithArray:photosArray];
    }
    return self;
}

- (id)initWithPhotos:(NSArray *)photosArray animatedFromView:(UIView*)view {
    if ((self = [self init])) {
        _photos = [[NSMutableArray alloc] initWithArray:photosArray];
        _senderViewForAnimation = view;
    }
    return self;
}

- (id)initWithPhotoURLs:(NSArray *)photoURLsArray {
    if ((self = [self init])) {
        NSArray *photosArray = [IDMPhoto photosWithURLs:photoURLsArray];
        _photos = [[NSMutableArray alloc] initWithArray:photosArray];
    }
    return self;
}

- (id)initWithPhotoURLs:(NSArray *)photoURLsArray animatedFromView:(UIView*)view {
    if ((self = [self init])) {
        NSArray *photosArray = [IDMPhoto photosWithURLs:photoURLsArray];
        _photos = [[NSMutableArray alloc] initWithArray:photosArray];
        _senderViewForAnimation = view;
    }
    return self;
}

- (void)dealloc {
    _pagingScrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    /**
     *  结束 设备旋转通知
     *
     *  @return return value description
     */
    [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
    [self releaseAllUnderlyingPhotos];
}

- (void)releaseAllUnderlyingPhotos {
    for (id p in _photos) {
        if (p != [NSNull null]){
            
            if ([p isKindOfClass:[PHAsset class]]) {
                
            }else{
                [p unloadUnderlyingImage];
            }
            
        }
        
    } // Release photos
}

- (void)didReceiveMemoryWarning {
    
    //清楚内存缓存
//    YYImageCache * cache = [YYImageCache sharedCache];
//    [cache.memoryCache  removeAllObjects];
//    
//    SDImageCache * sdcache = [SDImageCache sharedImageCache];
//    [sdcache clearMemory];
    [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
    
    [self releaseAllUnderlyingPhotos];
    [_recycledPages removeAllObjects];
    
    [super didReceiveMemoryWarning];
}

#pragma mark - Pan Gesture

- (void)panGestureRecognized:(id)sender {
    
    // Initial Setup
    IDMZoomingScrollView *scrollView = [self pageDisplayedAtIndex:_currentPageIndex];
    //IDMTapDetectingImageView *scrollView.photoImageView = scrollView.photoImageView;
    
    static float firstX, firstY, firstW, firstH;
    
    float viewHeight = scrollView.frame.size.height;
    float viewHalfHeight = viewHeight/2;
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    
    // Gesture Began
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        //jy
        [self jy_setAnimationViewAndInitialIndex];
        
        [self setControlsHidden:YES animated:YES permanent:YES];
        
        firstX = [scrollView center].x;
        firstY = [scrollView center].y;
//*****************************************JY ADD*****************************************/
        firstW = scrollView.photoImageView.jy_Width;
        firstH = scrollView.photoImageView.jy_Height;
//***************************************JY ADD End***************************************/
        //jy
        //        _senderViewForAnimation.hidden = (_currentPageIndex == _initalPageIndex);
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        _isdraggingPhoto = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }

//*****************************************JY ADD*****************************************/
    if(translatedPoint.y>0){
        scrollView.photoImageView.jy_Height = firstH - translatedPoint.y*0.3;
        scrollView.photoImageView.jy_Width = firstW - translatedPoint.y*(firstW/firstH)*0.3;
    }
//***************************************JY ADD End***************************************/
    
    translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
    [scrollView setCenter:translatedPoint];
    //    float newY = scrollView.center.y - viewHalfHeight;
    //    float newAlpha = 1 - fabsf(newY)/viewHeight; //abs(newY)/viewHeight * 1.8;
    //
    //    self.view.opaque = YES;
    //
    //    self.view.backgroundColor = [UIColor colorWithWhite:(_useWhiteBackgroundColor ? 1 : 0) alpha:newAlpha];
    
    
    //JY....................
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        if (scrollView.center.y > viewHalfHeight) {
            float newY = scrollView.center.y - viewHalfHeight;
            float newAlpha = 1 - fabsf(newY)/viewHeight; //abs(newY)/viewHeight * 1.8;
            
            self.view.opaque = YES;
            
            self.view.backgroundColor = [UIColor colorWithWhite:(_useWhiteBackgroundColor ? 1 : 0) alpha:newAlpha];
//            if(scrollView.center.y > viewHalfHeight+60 ){
//                if (_isShowControlbtn) {
//                    [self jy_DoneBtnClick:_doneButton];
//                }
//            }
        }
        
    }
    //JY end.................
    
    
    // Gesture Ended
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        //jy
        if(scrollView.center.y > firstY+ 10) // Automatic Dismiss View cut ** || scrollView.center.y < viewHalfHeight-40
        {
            _isDismiss = YES;
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
            if([[[UIDevice currentDevice] systemVersion] floatValue])
            {
                [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
            }
            
            
            if (_senderViewForAnimation ) { //&& _currentPageIndex == _initalPageIndex
                [self performCloseAnimationWithScrollView:scrollView];
                return;
            }
            
            CGFloat finalX = firstX, finalY;
            
            CGFloat windowsHeigt = [_applicationWindow frame].size.height;
            
            if(scrollView.center.y > viewHalfHeight+30) // swipe down
                finalY = windowsHeigt*2;
            else // swipe up
                finalY = -viewHalfHeight;
            
            CGFloat animationDuration = 0.35;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDelegate:self];
            [scrollView setCenter:CGPointMake(finalX, finalY)];
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            [UIView commitAnimations];
            
            [self performSelector:@selector(doneButtonPressed:) withObject:self afterDelay:animationDuration];
        }
        else // Continue Showing View
        {
#warning 待修改
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
            [self setNeedsStatusBarAppearanceUpdate];
            if (scrollView.center.y < self.view.jy_CenterY-100) {
                [self chooseBtnOfZoomScrollViewClick:nil];
            }
            _isdraggingPhoto = NO;
            [self setNeedsStatusBarAppearanceUpdate];
            
            self.view.backgroundColor = [UIColor colorWithWhite:(_useWhiteBackgroundColor ? 1 : 0) alpha:1];
            
            CGFloat velocityY = (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].y);
            
            CGFloat finalX = firstX;
            CGFloat finalY = viewHalfHeight;
            
            CGFloat animationDuration = (ABS(velocityY)*.0002)+.2;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            [scrollView setCenter:CGPointMake(finalX, finalY)];
            scrollView.photoImageView.jy_Width = firstW;
            scrollView.photoImageView.jy_Height = firstH;
            [UIView commitAnimations];
        }
    }
}

#pragma mark - Animation

- (void)performPresentAnimation {
    self.view.alpha = 0.0f;
    _pagingScrollView.alpha = 0.0f;
    
    UIImage *imageFromView = _scaleImage ? _scaleImage : [self getImageFromView:_senderViewForAnimation];
    
    _senderViewOriginalFrame = [_senderViewForAnimation.superview convertRect:_senderViewForAnimation.frame toView:nil];
    
    UIView *fadeView = [[UIView alloc] initWithFrame:_applicationWindow.bounds];
    fadeView.backgroundColor = [UIColor clearColor];
    [_applicationWindow addSubview:fadeView];
    
    UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
    resizableImageView.frame = _senderViewOriginalFrame;
    resizableImageView.clipsToBounds = YES;
    resizableImageView.contentMode = _senderViewForAnimation ? _senderViewForAnimation.contentMode : UIViewContentModeScaleAspectFill;
    resizableImageView.backgroundColor = [UIColor clearColor];
    [_applicationWindow addSubview:resizableImageView];
    
    //jy
    //    _senderViewForAnimation.hidden = YES;
    
    void (^completion)() = ^() {
        self.view.alpha = 1.0f;
        _pagingScrollView.alpha = 1.0f;
        resizableImageView.backgroundColor = [UIColor colorWithWhite:(_useWhiteBackgroundColor) ? 1 : 0 alpha:1];
        [fadeView removeFromSuperview];
        [resizableImageView removeFromSuperview];
        
    };

    [UIView animateWithDuration:_animationDuration animations:^{
        fadeView.backgroundColor = self.useWhiteBackgroundColor ? [UIColor whiteColor] : [UIColor blackColor];
    } completion:nil];
    
    CGRect finalImageViewFrame = [self animationFrameForImage:imageFromView presenting:YES scrollView:nil];
    self.view.opaque = YES;
    
  
    if(_usePopAnimation)
    {
        [self animateView:resizableImageView
                  toFrame:finalImageViewFrame
               completion:completion];
    }
    else
    {
        [UIView animateWithDuration:_animationDuration animations:^{
            resizableImageView.layer.frame = finalImageViewFrame;
        } completion:^(BOOL finished) {
            completion();
        }];
    }
}

- (void)performCloseAnimationWithScrollView:(IDMZoomingScrollView*)scrollView {
    float fadeAlpha = 1 - fabs(scrollView.frame.origin.y)/scrollView.frame.size.height;
    
    
    // 生成 截图
//    UIGraphicsBeginImageContext(_senderViewForAnimation.bounds.size);
//    [_senderViewForAnimation.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIImage * image = [self getImageFromView:_senderViewForAnimation];
    
    UIImage *imageFromView = image;
    if (!imageFromView && [scrollView.photo respondsToSelector:@selector(placeholderImage)]) {
        imageFromView = [scrollView.photo placeholderImage];
    }
    
    UIView *fadeView = [[UIView alloc] initWithFrame:_applicationWindow.bounds];
    fadeView.backgroundColor = self.useWhiteBackgroundColor ? [UIColor whiteColor] : [UIColor blackColor];
    fadeView.alpha = fadeAlpha;
    [_applicationWindow addSubview:fadeView];
    
    CGRect imageViewFrame = [self animationFrameForImage:imageFromView presenting:NO scrollView:scrollView];
    
    UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
    resizableImageView.frame = imageViewFrame;
    resizableImageView.contentMode = _senderViewForAnimation ? _senderViewForAnimation.contentMode : UIViewContentModeScaleAspectFill;
    resizableImageView.backgroundColor = [UIColor clearColor];
    resizableImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizableImageView.layer.masksToBounds = YES;
    [_applicationWindow addSubview:resizableImageView];
    self.view.hidden = YES;
    
    void (^completion)() = ^() {
        _senderViewForAnimation.hidden = NO;
        _senderViewForAnimation = nil;
        _scaleImage = nil;
        
        [fadeView removeFromSuperview];
        [resizableImageView removeFromSuperview];
        
        [self prepareForClosePhotoBrowser];
        [self dismissPhotoBrowserAnimated:NO];
    };
    
    [UIView animateWithDuration:0.1 animations:^{
        fadeView.alpha = 0;
        self.view.backgroundColor = [UIColor clearColor];
    } completion:nil];
    
    CGRect senderViewOriginalFrame = _senderViewForAnimation.superview ? [_senderViewForAnimation.superview convertRect:_senderViewForAnimation.frame toView:nil] : _senderViewOriginalFrame;
    
    if(_usePopAnimation)
    {
        [self animateDissmissView:resizableImageView toFrame:senderViewOriginalFrame completion:completion];
         
//         animateView:resizableImageView
//                  toFrame:senderViewOriginalFrame
//               completion:completion];
    }
    else
    {
        [UIView animateWithDuration:_animationDuration animations:^{
            resizableImageView.frame = senderViewOriginalFrame;
        } completion:^(BOOL finished) {
            completion();
        }];
    }
}

- (CGRect)animationFrameForImage:(UIImage *)image presenting:(BOOL)presenting scrollView:(UIScrollView *)scrollView
{
    if (!image) {
        return CGRectZero;
    }
    
    CGSize imageSize = image.size;
    CGFloat maxWidth = CGRectGetWidth(_applicationWindow.bounds);
    CGFloat maxHeight = CGRectGetHeight(_applicationWindow.bounds);
    //************JY Add **************/
    if(!presenting){
        maxWidth = [(IDMZoomingScrollView *)scrollView photoImageView].jy_Width;
        maxHeight = [(IDMZoomingScrollView *)scrollView photoImageView].jy_Height;
    }
    /*************JY End **************/
    
    CGRect animationFrame = CGRectZero;
    

    CGFloat aspect = imageSize.width / imageSize.height;
    if (maxWidth / aspect <= maxHeight) {
        animationFrame.size = CGSizeMake(maxWidth, maxWidth / aspect);
    }
    else {
        animationFrame.size = CGSizeMake(maxHeight * aspect, maxHeight);
    }
    
    
    
/*****************************JY Change***************************/
//    animationFrame.origin.x = roundf((maxWidth - animationFrame.size.width) / 2.0f);
//    animationFrame.origin.y = roundf((maxHeight - animationFrame.size.height) / 2.0f);
    
    animationFrame.origin.x = roundf((_applicationWindow.bounds.size.width - animationFrame.size.width) / 2.0f);
    animationFrame.origin.y = roundf((_applicationWindow.bounds.size.height - animationFrame.size.height) / 2.0f);
/*****************************JY Change end***************************/


    if (!presenting) {
        CGRect rect=[[(IDMZoomingScrollView *)scrollView photoImageView] convertRect: [(IDMZoomingScrollView *)scrollView photoImageView].bounds toView:_applicationWindow];
        animationFrame.origin.y += scrollView.frame.origin.y;
        animationFrame.origin.x = rect.origin.x;
    }
    
    return animationFrame;
}

#pragma mark - Genaral

- (void)prepareForClosePhotoBrowser {
    // Gesture
    [_applicationWindow removeGestureRecognizer:_panGesture];
    
    _autoHide = NO;
    
    // Controls
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; // Cancel any pending toggles from taps
}

- (void)dismissPhotoBrowserAnimated:(BOOL)animated {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    if ([_delegate respondsToSelector:@selector(photoBrowser:willDismissAtPageIndex:)])
        [_delegate photoBrowser:self willDismissAtPageIndex:_currentPageIndex];
    
    [self dismissViewControllerAnimated:animated completion:^{
        if ([_delegate respondsToSelector:@selector(photoBrowser:didDismissAtPageIndex:)])
            [_delegate photoBrowser:self didDismissAtPageIndex:_currentPageIndex];
        
        if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
        {
            _applicationTopViewController.modalPresentationStyle = _previousModalPresentationStyle;
        }
    }];
}

- (UIButton*)customToolbarButtonImage:(UIImage*)image imageSelected:(UIImage*)selectedImage action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:selectedImage forState:UIControlStateDisabled];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [button setContentMode:UIViewContentModeCenter];
    [button setFrame:CGRectMake(0,0, image.size.width, image.size.height)];
    return button;
}

- (UIImage*)getImageFromView:(UIView *)view {
    if ([view isKindOfClass:[UIImageView class]]) {
        return ((UIImageView*)view).image;
    }
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 2);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIViewController *)topviewController
{
    UIViewController *topviewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topviewController.presentedViewController) {
        topviewController = topviewController.presentedViewController;
    }
    
    return topviewController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
   
    // View
    self.view.backgroundColor = [UIColor colorWithWhite:(_useWhiteBackgroundColor ? 1 : 0) alpha:1];
    
    self.view.clipsToBounds = YES;
    
    // Setup paging scrolling view
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    _pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
//    _pagingScrollView.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _pagingScrollView.pagingEnabled = YES;
    _pagingScrollView.delegate = self;
    _pagingScrollView.showsHorizontalScrollIndicator = NO;
    _pagingScrollView.showsVerticalScrollIndicator = NO;
    _pagingScrollView.backgroundColor = [UIColor clearColor];
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    [self.view addSubview:_pagingScrollView];
    
    // Transition animation
    [self performPresentAnimation];
    
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    // Toolbar
    _toolbar = [[UIToolbar alloc] initWithFrame:[self frameForToolbarAtOrientation:currentOrientation]];
    _toolbar.backgroundColor = [UIColor clearColor];
    _toolbar.clipsToBounds = YES;
    _toolbar.translucent = YES;
    [_toolbar setBackgroundImage:[UIImage new]
              forToolbarPosition:UIToolbarPositionAny
                      barMetrics:UIBarMetricsDefault];
    
    //jy view CGRectMake(0, 0, __kWidth, 64)
    _jyTitleView = [[UIView alloc]initWithFrame:CGRectZero];
    _jyTitleView.backgroundColor = [UIColor blackColor];
    _jyBackBtn = [[UIButton alloc]initWithFrame:CGRectZero]; //CGRectMake(10, 30, 40, 20)
    [_jyBackBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//    [_jyBackBtn setImage:[UIImage imageNamed:@"back_grayhightlight"] forState:UIControlStateHighlighted];

    [_jyBackBtn addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _jyBackBtn.touchExtendInset = UIEdgeInsetsMake(-10, -10, -10, -10);
    UILabel * timeLb = [[UILabel alloc]initWithFrame:CGRectZero];//CGRectMake(75,  20, __kWidth-150, 40)
    timeLb.textAlignment = NSTextAlignmentCenter;
    timeLb.font = [UIFont fontWithName:FANGZHENG size:16];
    timeLb.textColor = [UIColor whiteColor];
    [_jyTitleView addSubview:timeLb];
    _jyTimeLabel = timeLb;
    
    //jy when to use doneBtn
    if (_photoBrowserType == JYPhotoBrowserTypeNone ||_photoBrowserType == JYPhotoBrowserTypePhotoCanChoose) {
        // Close Button
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneButton setFrame:[self frameForDoneButtonAtOrientation:currentOrientation]];
        [_doneButton setAlpha:1.0f];
        //jy
        [_doneButton addTarget:self action:@selector(jy_DoneBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_doneButton setTitle:@"选择" forState:UIControlStateNormal];
        _doneButton.titleLabel.font = [UIFont fontWithName:FANGZHENG size:16];
        _doneButton.contentMode = UIViewContentModeScaleAspectFit;
    }
    if (_photoBrowserType == JYPhotoBrowserTypeAlbum) {
        _jyTimeLabel.hidden = YES;
    }
    
    if (_showTalkView) {
        _jyToolBar = [[UIImageView alloc]initWithFrame:CGRectZero]; //CGRectMake(0, __kHeight-100,__kWidth, 49)
        [_jyToolBar setImage:[UIImage imageNamed:@"transparency_bg"]];
        _jyToolBar.userInteractionEnabled = YES;
        
        _talkBtn = [[UIButton alloc]initWithFrame:CGRectZero];//CGRectMake(__kWidth - 60, 10 , 30, 30)
        [_talkBtn setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
        [_talkBtn addTarget:self action:@selector(talkViewClick:) forControlEvents:UIControlEventTouchUpInside];
        [_jyToolBar addSubview:_talkBtn];
        
//        _zanbtn = [[UIButton alloc]initWithFrame:CGRectMake(__kWidth - 60, 10 , 30, 30)];
//        [_zanbtn setImage:[UIImage imageNamed:@"praise"] forState:UIControlStateNormal];
//        [_talkView addSubview:_zanbtn];
//        _talkBtn addTarget:self action:<#(nonnull SEL)#> forControlEvents:<#(UIControlEvents)#>
    }
    
    
    UIImage *leftButtonImage = (_leftArrowImage == nil) ?
    [UIImage imageNamed:@"IDMPhotoBrowser.bundle/images/IDMPhotoBrowser_arrowLeft.png"]          : _leftArrowImage;
    
    UIImage *rightButtonImage = (_rightArrowImage == nil) ?
    [UIImage imageNamed:@"IDMPhotoBrowser.bundle/images/IDMPhotoBrowser_arrowRight.png"]         : _rightArrowImage;
    
    UIImage *leftButtonSelectedImage = (_leftArrowSelectedImage == nil) ?
    [UIImage imageNamed:@"IDMPhotoBrowser.bundle/images/IDMPhotoBrowser_arrowLeftSelected.png"]  : _leftArrowSelectedImage;
    
    UIImage *rightButtonSelectedImage = (_rightArrowSelectedImage == nil) ?
    [UIImage imageNamed:@"IDMPhotoBrowser.bundle/images/IDMPhotoBrowser_arrowRightSelected.png"] : _rightArrowSelectedImage;
    
    // Arrows
    _previousButton = [[UIBarButtonItem alloc] initWithCustomView:[self customToolbarButtonImage:leftButtonImage
                                                                                   imageSelected:leftButtonSelectedImage
                                                                                          action:@selector(gotoPreviousPage)]];
    _nextButton = [[UIBarButtonItem alloc] initWithCustomView:[self customToolbarButtonImage:rightButtonImage
                                                                               imageSelected:rightButtonSelectedImage
                                                                                      action:@selector(gotoNextPage)]];
    // Counter Label
    _counterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 95, 40)];
    _counterLabel.textAlignment = NSTextAlignmentCenter;
    _counterLabel.backgroundColor = [UIColor clearColor];
    _counterLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    
    if(_useWhiteBackgroundColor == NO) {
        _counterLabel.textColor = [UIColor whiteColor];
        _counterLabel.shadowColor = [UIColor darkTextColor];
        _counterLabel.shadowOffset = CGSizeMake(0, 1);
    }
    else {
        _counterLabel.textColor = [UIColor blackColor];
    }
    
    // Counter Button
    _counterButton = [[UIBarButtonItem alloc] initWithCustomView:_counterLabel];
    
    // Action Button
    _actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                  target:self
                                                                  action:@selector(actionButtonPressed:)];
    
    // Gesture
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    [_panGesture setMinimumNumberOfTouches:1];
    [_panGesture setMaximumNumberOfTouches:1];
    
    // Update
    //[self reloadData];
    
    // Super
    [super viewDidLoad];
    
    //jy
    [self jy_CreateControlbtn];
    
    // Update
    [self reloadData];
    
    //Regesit  Device Orientation Notify
    /**
     *  JY 开始生成 设备旋转 通知
     */
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    
    /**
     *  添加 设备旋转 通知
     *
     *  当监听到 UIDeviceOrientationDidChangeNotification 通知时，调用handleDeviceOrientationDidChange:方法
     *  @param handleDeviceOrientationDidChange: handleDeviceOrientationDidChange: description
     *
     *  @return return value description
     */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Super
    [super viewWillAppear:animated];
    
    // Status Bar
    _statusBarOriginallyHidden = [UIApplication sharedApplication].statusBarHidden;
    
    // Update UI
    [self hideControlsAfterDelay];
     [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
     [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewIsActive = YES;
    [FMBalloon showBalloonInPhotoBrowser];
}

// Release any retained subviews of the main view.
- (void)viewDidUnload {
    _currentPageIndex = 0;
    _pagingScrollView = nil;
    _visiblePages = nil;
    _recycledPages = nil;
    _toolbar = nil;
    _doneButton = nil;
    _previousButton = nil;
    _nextButton = nil;
    
    [super viewDidUnload];
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _useWhiteBackgroundColor ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    if(_forceHideStatusBar) {
        return YES;
    }
    
    if(_isdraggingPhoto) {
        if(_statusBarOriginallyHidden) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        return [self areControlsHidden];
    }
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    // Flag
    _performingLayout = YES;
    
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    // Toolbar
    _toolbar.frame = [self frameForToolbarAtOrientation:currentOrientation];
    
    // Done button
    _doneButton.frame = [self frameForDoneButtonAtOrientation:currentOrientation];
    
//    _jyToolBar.frame =  CGRectMake(0, __kHeight-49,__kWidth, 49);
//    _talkBtn.frame = CGRectMake(__kWidth - 60, 10 , 30, 30);
    
    CGRect screenBounds = self.view.bounds;

    //jy  add animation rotate
    [UIView animateWithDuration:0.5 animations:^{
        _jyToolBar.frame =  CGRectMake(0, screenBounds.size.height-49,screenBounds.size.width, 49);
        _talkBtn.frame = CGRectMake(screenBounds.size.width - 60, 10 , 30, 30);
        [self updateJYViewAtOrientation:currentOrientation];
    }];
    
    // Remember index
    NSUInteger indexPriorToLayout = _currentPageIndex;
    
    // Get paging scroll view frame to determine if anything needs changing
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
    //jy  add animation for rotate
    [UIView animateWithDuration:0.5 animations:^{
        // Frame needs changing
        _pagingScrollView.frame = pagingScrollViewFrame;
        
        // Recalculate contentSize based on current orientation
        _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    }];
    // Adjust frames and configuration of each visible page
    for (IDMZoomingScrollView *page in _visiblePages) {
        NSUInteger index = PAGE_INDEX(page);
        [UIView animateWithDuration:0.5 animations:^{
            page.frame = [self frameForPageAtIndex:index];
            page.captionView.frame = [self frameForCaptionView:page.captionView atIndex:index];
            [page setMaxMinZoomScalesForCurrentBounds];
        }];
    }
    [UIView animateWithDuration:0.5 animations:^{
        // Adjust contentOffset to preserve page location based on values collected prior to location
        _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
        [self didStartViewingPageAtIndex:_currentPageIndex]; // initial
    }];
    
    // Reset
    _currentPageIndex = indexPriorToLayout;
    _performingLayout = NO;
    
    // Super
    [super viewWillLayoutSubviews];
}

- (void)performLayout {
    // Setup
    _performingLayout = YES;
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    
    // Setup pages
    [_visiblePages removeAllObjects];
    [_recycledPages removeAllObjects];
    
    // Toolbar
    if (_displayToolbar) {
        [self.view addSubview:_toolbar];
    } else {
        [_toolbar removeFromSuperview];
    }
    
#warning jyView
    [self.view addSubview:_jyTitleView];
    [_jyTitleView addSubview:_jyBackBtn];
    [_jyTitleView addSubview:_jyTitleLabel];
    
    if (_showTalkView) {
        [self.view addSubview:_jyToolBar];
        _jyToolBar.frame =  CGRectMake(0, __kHeight-49,__kWidth, 49);
        _talkBtn.frame = CGRectMake(__kWidth - 60, 10 , 30, 30);
//        [_jyToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.mas_equalTo(self.view.mas_right);
//            make.bottom.mas_equalTo(self.view.mas_bottom);
//            make.left.mas_equalTo(self.view.mas_left);
//            make.height.equalTo(@49);
//        }];
//        
//        [_talkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.mas_equalTo(_jyToolBar.mas_right).with.offset(-60);
//            make.top.mas_equalTo(_jyToolBar.mas_top).with.offset(10);
//            make.width.equalTo(@30);
//            make.height.equalTo(@30);
//        }];
    }
    
    
    // Close button
    if(_displayDoneButton && !self.navigationController.navigationBar)
        [_jyTitleView addSubview:_doneButton];
    
    // Toolbar items & navigation
    UIBarButtonItem *fixedLeftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                    target:self action:nil];
    fixedLeftSpace.width = 32; // To balance action button
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:self action:nil];
    NSMutableArray *items = [NSMutableArray new];
    
    if (_displayActionButton)
        [items addObject:fixedLeftSpace];
    [items addObject:flexSpace];
    
    if (numberOfPhotos > 1 && _displayArrowButton)
        [items addObject:_previousButton];
    
    if(_displayCounterLabel) {
        [items addObject:flexSpace];
        [items addObject:_counterButton];
    }
    
    [items addObject:flexSpace];
    if (numberOfPhotos > 1 && _displayArrowButton)
        [items addObject:_nextButton];
    [items addObject:flexSpace];
    
    if(_displayActionButton)
        [items addObject:_actionButton];
    
    [_toolbar setItems:items];
    [self updateToolbar];
    
    // Content offset
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:_currentPageIndex];
    [self tilePages];
    
    _performingLayout = NO;
    
    if(! _disableVerticalSwipe)
        [self.view addGestureRecognizer:_panGesture];
    
    [self updateJYViewAtOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

-(void)updateJYViewAtOrientation:(UIInterfaceOrientation)orientation{
    CGRect screenBound = self.view.bounds;
    CGFloat screenWidth = screenBound.size.width;
    CGFloat  jyTitleHeight = 64;
    CGFloat jyBackBtnH = 30;
    CGFloat jyTimeLbH = 20;
    if(_nowRotateOrientation && _nowRotateOrientation != UIDeviceOrientationPortrait){
        jyTitleHeight = 44;
        jyBackBtnH = 10;
        jyTimeLbH = 0;
    }
    _jyTitleView.frame = CGRectMake(0, 0, screenWidth, jyTitleHeight);
    _jyBackBtn.frame = CGRectMake(0, jyBackBtnH - 12, 48, 48);
    _jyTimeLabel.frame = CGRectMake(75,  jyTimeLbH, screenWidth-150, 40);
    if (!_isShowTitleView) {
        _jyTitleView.jy_Bottom = 0;
        _jyToolBar.jy_Top = screenBound.size.height;
    }
}

#pragma mark - Data

- (void)reloadData {
    // Get data
    [self releaseAllUnderlyingPhotos];
    
    // Update
    [self performLayout];
    
    // Layout
    [self.view setNeedsLayout];
}

- (NSUInteger)numberOfPhotos {
    return _photos.count;
}

- (id<IDMPhoto>)photoAtIndex:(NSUInteger)index {
    return _photos[index];
}

- (IDMCaptionView *)captionViewForPhotoAtIndex:(NSUInteger)index {
    IDMCaptionView *captionView = nil;
    if ([_delegate respondsToSelector:@selector(photoBrowser:captionViewForPhotoAtIndex:)]) {
        captionView = [_delegate photoBrowser:self captionViewForPhotoAtIndex:index];
    } else {
        id <IDMPhoto> photo = [self photoAtIndex:index];
        if ([photo respondsToSelector:@selector(caption)]) {
            if ([photo caption]) captionView = [[IDMCaptionView alloc] initWithPhoto:photo];
        }
    }
    captionView.alpha = [self areControlsHidden] ? 0 : 1; // Initial alpha
    
    return captionView;
}

- (UIImage *)imageForPhoto:(id<IDMPhoto>)photo {
    if (photo) {
        // Get image or obtain in background
        if ([photo underlyingImage]) {
            return [photo underlyingImage];
        } else {
//            if(_op)
//               [_op cancel];
//            _op = [NSBlockOperation blockOperationWithBlock:^{
                [photo loadUnderlyingImageAndNotify];
//            }];
//            [_op start];
            return [photo placeholderImage];
        }
    }
    
    return nil;
}

- (void)loadAdjacentPhotosIfNecessary:(id<IDMPhoto>)photo {
    IDMZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        // If page is current page then initiate loading of previous and next pages
        NSUInteger pageIndex = PAGE_INDEX(page);
        if (_currentPageIndex == pageIndex) {
            if (pageIndex > 0) {
                // Preload index - 1
                id <IDMPhoto> photo = [self photoAtIndex:pageIndex-1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndNotify];
                    IDMLog(@"Pre-loading image at index %i", pageIndex-1);
                }
            }
            if (pageIndex < [self numberOfPhotos] - 1) {
                // Preload index + 1
                id <IDMPhoto> photo = [self photoAtIndex:pageIndex+1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndNotify];
                    IDMLog(@"Pre-loading image at index %i", pageIndex+1);
                }
            }
        }
    }
}

#pragma mark - IDMPhoto Loading Notification

- (void)handleIDMPhotoLoadingDidEndNotification:(NSNotification *)notification {
    id <IDMPhoto> photo = [notification object];
#warning jy get page
    IDMZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        if ([photo underlyingImage]) {
            // Successful load
            [page displayImage];
            [self loadAdjacentPhotosIfNecessary:photo];
        } else {
            // Failed to load
            [page displayImageFailure];
        }
    }
}

#pragma mark - Paging

- (void)tilePages {
    // Calculate which pages should be visible
    // Ignore padding as paging bounces encroach on that
    // and lead to false page loads
    CGRect visibleBounds = _pagingScrollView.bounds;
    NSInteger iFirstIndex = (NSInteger) floorf((CGRectGetMinX(visibleBounds)+PADDING*2) / CGRectGetWidth(visibleBounds));
    NSInteger iLastIndex  = (NSInteger) floorf((CGRectGetMaxX(visibleBounds)-PADDING*2-1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > [self numberOfPhotos] - 1) iFirstIndex = [self numberOfPhotos] - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > [self numberOfPhotos] - 1) iLastIndex = [self numberOfPhotos] - 1;
    
    // Recycle no longer needed pages
    NSInteger pageIndex;
    for (IDMZoomingScrollView *page in _visiblePages) {
        pageIndex = PAGE_INDEX(page);
        if (pageIndex < (NSUInteger)iFirstIndex || pageIndex > (NSUInteger)iLastIndex) {
            [_recycledPages addObject:page];
            [page prepareForReuse];
            [page removeFromSuperview];
            IDMLog(@"Removed page at index %i", PAGE_INDEX(page));
        }
    }
    [_visiblePages minusSet:_recycledPages];
    while (_recycledPages.count > 2) // Only keep 2 recycled pages
        [_recycledPages removeObject:[_recycledPages anyObject]];
    
    // Add missing pages
    for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            // Add new page
#warning jy do something with select or scroll
            
            IDMPhoto * photo = [_photos objectAtIndex:index];
            _jyTimeLabel.text = [self getDateStringWithPhoto:[photo getPhotoCreateTime]];
            
            
            IDMZoomingScrollView *page;
            page = [[IDMZoomingScrollView alloc] initWithPhotoBrowser:self];
            page.photoState = self.photoState;
            page.backgroundColor = [UIColor clearColor];
            page.opaque = YES;
            page.isChoose = [self isChoosePhoto:[self photoAtIndex:index]];
            [page.chooseBtn addTarget:self  action:@selector(chooseBtnOfZoomScrollViewClick:) forControlEvents:UIControlEventTouchUpInside];
            
            
            
            [self configurePage:page forIndex:index];
            
            [_visiblePages addObject:page];
            [_pagingScrollView addSubview:page];
            IDMLog(@"Added page at index %i", index);
            
            // Add caption
            IDMCaptionView *captionView = [self captionViewForPhotoAtIndex:index];
            captionView.frame = [self frameForCaptionView:captionView atIndex:index];
            [_pagingScrollView addSubview:captionView];
            page.captionView = captionView;
        }
    }
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
    for (IDMZoomingScrollView *page in _visiblePages)
        if (PAGE_INDEX(page) == index) return YES;
    return NO;
}

- (IDMZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index {
    IDMZoomingScrollView *thePage = nil;
    for (IDMZoomingScrollView *page in _visiblePages) {
        if (PAGE_INDEX(page) == index) {
            thePage = page; break;
        }
    }
    return thePage;
}

- (IDMZoomingScrollView *)pageDisplayingPhoto:(id<IDMPhoto>)photo {
    IDMZoomingScrollView *thePage = nil;
    for (IDMZoomingScrollView *page in _visiblePages) {
        if (page.photo == photo) {
            thePage = page; break;
        }
    }
    return thePage;
}

- (void)configurePage:(IDMZoomingScrollView *)page forIndex:(NSUInteger)index {
    page.frame = [self frameForPageAtIndex:index];
    page.tag = PAGE_INDEX_TAG_OFFSET + index;
    page.photo = [self photoAtIndex:index];
    
    __block __weak IDMPhoto *photo = (IDMPhoto*)page.photo;
    __weak IDMZoomingScrollView* weakPage = page;
    photo.progressUpdateBlock = ^(CGFloat progress){
        [weakPage setProgress:progress forPhoto:photo];
    };
}

- (IDMZoomingScrollView *)dequeueRecycledPage {
    IDMZoomingScrollView *page = [_recycledPages anyObject];
    if (page) {
        [_recycledPages removeObject:page];
    }
    return page;
}

// Handle page changes
- (void)didStartViewingPageAtIndex:(NSUInteger)index {
    // Load adjacent images if needed and the photo is already
    // loaded. Also called after photo has been loaded in background
    id <IDMPhoto> currentPhoto = [self photoAtIndex:index];
    if ([currentPhoto underlyingImage]) {
        // photo loaded so load ajacent now
        [self loadAdjacentPhotosIfNecessary:currentPhoto];
    }
    if ([_delegate respondsToSelector:@selector(photoBrowser:didShowPhotoAtIndex:)]) {
        [_delegate photoBrowser:self didShowPhotoAtIndex:index];
    }
}

#pragma mark - Frame Calculations

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = _pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self numberOfPhotos], bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
    CGFloat pageWidth = _pagingScrollView.bounds.size.width;
    CGFloat newOffset = index * pageWidth;
    return CGPointMake(newOffset, 0);
}

- (BOOL)isLandscape:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsLandscape(orientation);
}

- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
    CGFloat height = 44;
    
    if ([self isLandscape:orientation])
        height = 32;
    
    return CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
}

- (CGRect)frameForDoneButtonAtOrientation:(UIInterfaceOrientation)orientation {
    CGRect screenBound = self.view.bounds;
    CGFloat screenWidth = screenBound.size.width;
    
    // if ([self isLandscape:orientation]) screenWidth = screenBound.size.height;
    
    return CGRectMake(screenWidth - 55, 30, 40, 26);
}

- (CGRect)frameForCaptionView:(IDMCaptionView *)captionView atIndex:(NSUInteger)index {
    CGRect pageFrame = [self frameForPageAtIndex:index];
    
    CGSize captionSize = [captionView sizeThatFits:CGSizeMake(pageFrame.size.width, 0)];
    CGRect captionFrame = CGRectMake(pageFrame.origin.x, pageFrame.size.height - captionSize.height - (_toolbar.superview?_toolbar.frame.size.height:0), pageFrame.size.width, captionSize.height);
    
    return captionFrame;
}


#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView  {
    // Checks
    if (!_viewIsActive || _performingLayout || _rotating) return;
    
    // Tile pages
    [self tilePages];
    
    // Calculate current page
    CGRect visibleBounds = _pagingScrollView.bounds;
    NSInteger index = (NSInteger) (floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
    if (index > [self numberOfPhotos] - 1) index = [self numberOfPhotos] - 1;
    NSUInteger previousCurrentPage = _currentPageIndex;
    _currentPageIndex = index;
    if (_currentPageIndex != previousCurrentPage) {
        [self didStartViewingPageAtIndex:index];
        
        if(_arrowButtonsChangePhotosAnimated) [self updateToolbar];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // Hide controls when dragging begins
    
    //jy 浏览模式
//    [self setControlsHidden:YES animated:YES permanent:NO];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // Update toolbar when page changes
    if(! _arrowButtonsChangePhotosAnimated) [self updateToolbar];
}

#pragma mark - Toolbar

- (void)updateToolbar {
    // Counter
    if ([self numberOfPhotos] > 1) {
        _counterLabel.text = [NSString stringWithFormat:@"%lu %@ %lu", (unsigned long)(_currentPageIndex+1), IDMPhotoBrowserLocalizedStrings(@"of"), (unsigned long)[self numberOfPhotos]];
    } else {
        _counterLabel.text = nil;
    }
    
    // Buttons
    _previousButton.enabled = (_currentPageIndex > 0);
    _nextButton.enabled = (_currentPageIndex < [self numberOfPhotos]-1);
}

- (void)jumpToPageAtIndex:(NSUInteger)index {
    // Change page
    if (index < [self numberOfPhotos]) {
        CGRect pageFrame = [self frameForPageAtIndex:index];
        
        if(_arrowButtonsChangePhotosAnimated)
        {
            [_pagingScrollView setContentOffset:CGPointMake(pageFrame.origin.x - PADDING, 0) animated:YES];
        }
        else
        {
            _pagingScrollView.contentOffset = CGPointMake(pageFrame.origin.x - PADDING, 0);
            [self updateToolbar];
        }
    }
    
    // Update timer to give more time
    [self hideControlsAfterDelay];
}

- (void)gotoPreviousPage { [self jumpToPageAtIndex:_currentPageIndex-1]; }
- (void)gotoNextPage     { [self jumpToPageAtIndex:_currentPageIndex+1]; }

#pragma mark - Control Hiding / Showing

// If permanent then we don't set timers to hide again
- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent {
    // Cancel any timers
    [self cancelControlHiding];
     _isShowTitleView = !_isShowTitleView;
    // Captions
    NSMutableSet *captionViews = [[NSMutableSet alloc] initWithCapacity:_visiblePages.count];
    for (IDMZoomingScrollView *page in _visiblePages) {
        if (page.captionView) [captionViews addObject:page.captionView];
    }
    
    // Hide/show bars
    [UIView animateWithDuration:(animated ? 0.1 : 0) animations:^(void) {
        CGFloat alpha = hidden ? 0 : 1;
        [self.navigationController.navigationBar setAlpha:alpha];
        [_toolbar setAlpha:alpha];
        //        [_doneButton setAlpha:alpha];
//#pragma make - jy photo Browser  动画位置
        CGRect screenBound = self.view.bounds;
        CGFloat screenHeight = screenBound.size.height;
        if (hidden) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
            [self setNeedsStatusBarAppearanceUpdate];
            [UIView animateWithDuration:0.5 animations:^{
                _jyTitleView.jy_Bottom = 0;
                _jyToolBar.jy_Bottom = screenHeight+49;
            } completion:^(BOOL finished) {
                _jyToolBar.hidden = hidden;
            }];
        }
        else{
            _jyToolBar.hidden = hidden;
            BOOL isRotate = _nowRotateOrientation && _nowRotateOrientation != UIDeviceOrientationPortrait;
            if (!isRotate){
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                [self setNeedsStatusBarAppearanceUpdate];
            }
            [UIView animateWithDuration:0.5 animations:^{
                if(isRotate)
                    _jyTitleView.jy_Bottom = 44;
                else
                    _jyTitleView.jy_Bottom = 64;
                _jyToolBar.jy_Bottom = screenHeight;
            } completion:^(BOOL finished) {
                
            }];
        }
        for (UIView *v in captionViews) v.alpha = alpha;
    } completion:^(BOOL finished) {}];
    
    // Control hiding timer
    // Will cancel existing timer but only begin hiding if they are visible
    if (!permanent) [self hideControlsAfterDelay];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)cancelControlHiding {
    // If a timer exists then cancel and release
    if (_controlVisibilityTimer) {
        [_controlVisibilityTimer invalidate];
        _controlVisibilityTimer = nil;
    }
}

// Enable/disable control visiblity timer
- (void)hideControlsAfterDelay {
    // return;
    
    if (![self areControlsHidden]) {
        [self cancelControlHiding];
//        _controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
    }
}

- (BOOL)areControlsHidden { return (_toolbar.alpha == 0); }
- (void)hideControls      {
    if(_autoHide) [self setControlsHidden:YES animated:YES permanent:NO]; }
- (void)toggleControls    {
    [self setControlsHidden:![self areControlsHidden] animated:YES permanent:NO]; }


#pragma mark - Properties

- (void)setInitialPageIndex:(NSUInteger)index {
    // Validate
    if (index >= [self numberOfPhotos]) index = [self numberOfPhotos]-1;
    _initalPageIndex = index;
    _currentPageIndex = index;
    if ([self isViewLoaded]) {
        [self jumpToPageAtIndex:index];
        if (!_viewIsActive) [self tilePages]; // Force tiling if view is not visible
    }
}

#pragma mark - Buttons

- (void)doneButtonPressed:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    if([[[UIDevice currentDevice] systemVersion] floatValue])
    {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    }
    
    
    //jy *************************
    [self jy_setAnimationViewAndInitialIndex];
    //****************************
    if (_senderViewForAnimation) {        // && _currentPageIndex == _initalPageIndex
        IDMZoomingScrollView *scrollView = [self pageDisplayedAtIndex:_currentPageIndex];
        [self performCloseAnimationWithScrollView:scrollView];
    }
    else {
        _senderViewForAnimation.hidden = NO;
        [self prepareForClosePhotoBrowser];
        [self dismissPhotoBrowserAnimated:YES];
    }
}

- (void)actionButtonPressed:(id)sender {
    id <IDMPhoto> photo = [self photoAtIndex:_currentPageIndex];
    
    if ([self numberOfPhotos] > 0 && [photo underlyingImage]) {
        if(!_actionButtonTitles)
        {
            // Activity view
            NSMutableArray *activityItems = [NSMutableArray arrayWithObject:[photo underlyingImage]];
            if (photo.caption) [activityItems addObject:photo.caption];
            
            self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            
            __typeof__(self) __weak selfBlock = self;
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
            {
                [self.activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
                    [selfBlock hideControlsAfterDelay];
                    selfBlock.activityViewController = nil;
                }];
            }
            else
            {
//                [self.activityViewController setCompletionHandler:^(NSString *activityType, BOOL completed) {
//                    [selfBlock hideControlsAfterDelay];
//                    selfBlock.activityViewController = nil;
//                }];
            }
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                [self presentViewController:self.activityViewController animated:YES completion:nil];
            }
            else { // iPad
                UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:self.activityViewController];
                [popover presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0)
                                         inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny
                                       animated:YES];
            }
        }
        else
        {
            // Action sheet
            self.actionsSheet = [UIActionSheet new];
            self.actionsSheet.delegate = self;
            for(NSString *action in _actionButtonTitles) {
                [self.actionsSheet addButtonWithTitle:action];
            }
            
            self.actionsSheet.cancelButtonIndex = [self.actionsSheet addButtonWithTitle:IDMPhotoBrowserLocalizedStrings(@"Cancel")];
            self.actionsSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                [_actionsSheet showInView:self.view];
            } else {
                [_actionsSheet showFromBarButtonItem:sender animated:YES];
            }
        }
        
        // Keep controls hidden
        [self setControlsHidden:NO animated:YES permanent:YES];
    }
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet == _actionsSheet) {
        self.actionsSheet = nil;
        
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            if ([_delegate respondsToSelector:@selector(photoBrowser:didDismissActionSheetWithButtonIndex:photoIndex:)]) {
                [_delegate photoBrowser:self didDismissActionSheetWithButtonIndex:buttonIndex photoIndex:_currentPageIndex];
                return;
            }
        }
    }
    
    [self hideControlsAfterDelay]; // Continue as normal...
}

#pragma mark - pop Animation

- (void)animateView:(UIView *)view toFrame:(CGRect)frame completion:(void (^)(void))completion
{
    if ([view isKindOfClass:[UIImageView class]]) {
        view.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    [animation setSpringBounciness:7];
    [animation setDynamicsMass:1];
    [animation setToValue:[NSValue valueWithCGRect:frame]];
    [view pop_addAnimation:animation forKey:nil];
    
    if (completion)
    {
        [animation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
            completion();
        }];
    }
}


- (void)animateDissmissView:(UIView *)view toFrame:(CGRect)frame completion:(void (^)(void))completion
{
    if ([view isKindOfClass:[UIImageView class]]) {
        view.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    [animation setSpringBounciness:3];
    [animation setDynamicsMass:1];
    [animation setToValue:[NSValue valueWithCGRect:frame]];
    [view pop_addAnimation:animation forKey:nil];
    
    if (completion)
    {
        [animation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
            completion();
        }];
    }
}

#pragma mark - jy

-(void)setPhotoState:(JYPhotoState)photoState{
    _photoState = photoState;
    IDMZoomingScrollView *page = [self pageDisplayedAtIndex:_currentPageIndex];
    if (page) {
        page.photoState = photoState;
        page.isChoose = NO;
    }
    if (photoState == JYPhotoNormal) {
        [_chooseArray removeAllObjects];//删除所有的选中照片
    }
    
}


//获取动画控件
-(void)jy_setAnimationViewAndInitialIndex{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:needAnimationViewWillDismissAtPageIndex:)]) {
        _senderViewForAnimation = [self.delegate photoBrowser:self needAnimationViewWillDismissAtPageIndex:_currentPageIndex];
    }
}

//rightBtn Click


- (void)jy_DoneBtnClick:(UIButton *)sender{
    
    //改变状态
    self.photoState =  self.photoState == JYPhotoCanChoose? JYPhotoNormal:JYPhotoCanChoose;
    
    //防止动画冲突
    sender.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.userInteractionEnabled = YES;
    });
    
    if (!_isShowControlbtn) {
        [self jy_ShowControlBtn];
    }
    else{
        [self jy_HiddenControlBtn];
    }
    _isShowControlbtn  = !_isShowControlbtn;
}

-(void)jy_CreateControlbtn{
    if (!_controlBtn) {
        _controlBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _controlBtn.showsTouchWhenHighlighted = YES;
        [_controlBtn setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
        _controlBtn.frame = CGRectMake(self.view.jy_Width-80 , self.view.jy_Height, 64, 64);
        _controlBtn.layer.cornerRadius = 32;
        _controlBtn.layer.masksToBounds = YES;
        [_controlBtn addTarget:self action:@selector(jy_ControlBtnChick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_controlBtn];
    }
    _isControlBtnSelected = NO;//初始状态未选中
}

-(void)jy_ShowControlBtn{
    //防止过度增高
    if (_controlBtn.frame.origin.y < self.view.jy_Height) {
        return;
    }
    _controlBtn.moveY(-100).bounce.animate(0.5);
}

-(void)jy_HiddenControlBtn{
    if (_isControlBtnSelected) {
        [self jy_ControlBtnChick:_controlBtn];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _controlBtn.moveY(100).bounce.animate(0.5);
        });
    }
    else{
        _controlBtn.moveY(100).bounce.animate(0.5);
    }
    
}


//加号响应事件
-(void)jy_ControlBtnChick:(UIButton *)sender{
    sender.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.userInteractionEnabled = YES;
    });
    
    
    if (!_isControlBtnSelected) {
        [self _controlBtnUp];
    }else{
        [self _controlBtnDown];
    }
    _isControlBtnSelected = ! _isControlBtnSelected;
}




//controlBtn 呼出的 小按钮 的 响应事件
-(void)smallBtnClick:(UIButton *)btn{
    NSInteger tag = btn.tag;
    switch (tag) {
        case 100:{
            //创建图集
            if (_chooseArray.count == 0) {
                [SXLoadingView showAlertHUD:@"请先选择照片" duration:1];
            }else{
                FMAlbumNamedController * vc = [[FMAlbumNamedController alloc]init];
                vc.namedState = NamedUseInPhoto;
                vc.photoArr = _chooseArray;
                [self presentViewController:vc animated:YES completion:nil];
            }
        }
            break;
        case 101:{
            //加锁
            
        }
            break;
        case 102:{
            //解锁
            
        }
            break;
        default:
            break;
    }
    [self jy_ControlBtnChick:_controlBtn];
    
}



-(void)_controlBtnUp{
    
    _controlBtn.imageView.rotate(180).bounce.animate(0.5);
    for (int i = 0; i< 3 ; i++) {
        UIButton *  btn = [[UIButton alloc]initWithFrame:CGRectZero];
        btn.jy_Width = 54;
        btn.jy_Height = 54;
        btn.center = _controlBtn.center;
        [btn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"small_%d",i+1]] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 27;
        btn.layer.masksToBounds = YES;
        btn.tag = i + 100;
        [btn addTarget:self  action:@selector(smallBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        [self.view bringSubviewToFront:_controlBtn];
        btn.moveY(-(90+i*65)).bounce.animate(0.25+i*0.2);
    }
    
}

-(void)_controlBtnDown{
    
    _controlBtn.imageView.rotate(-180).bounce.animate(0.5);
    //    int y = 50;
    UIButton * btn1 = nil;
    UIButton * btn2 = nil;
    UIButton * btn3 = nil;
//    UIButton * btn4 = nil;
    for (UIView * subView in [self.view subviews]) {
        if (subView.tag == 100) {
            btn1 = (UIButton *)subView;
        }
        if (subView.tag == 101) {
            btn2 = (UIButton *)subView;
        }
        if (subView.tag == 102) {
            btn3 = (UIButton *)subView;
        }
//        if (subView.tag == 103) {
//            btn4 = (UIButton *)subView;
//        }
    }
    if (btn1) {
        btn1.moveY(_controlBtn.jy_Bottom - btn1.jy_Bottom).bounce.animate(0.25).animationCompletion= JHAnimationCompletion() {
            [btn1 removeFromSuperview];
        };
        btn2.moveY(_controlBtn.jy_Bottom - btn2.jy_Bottom).bounce.animate(0.35).animationCompletion= JHAnimationCompletion() {
            [btn2 removeFromSuperview];
        };
        btn3.moveY(_controlBtn.jy_Bottom - btn3.jy_Bottom).bounce.animate(0.45).animationCompletion= JHAnimationCompletion() {
            [btn3 removeFromSuperview];
        };
//        btn4.moveY(_controlBtn.jy_Bottom - btn4.jy_Bottom).bounce.animate(0.55).animationCompletion= JHAnimationCompletion() {
//            [btn4 removeFromSuperview];
//        };
    }else{
        NSLog(@"异常！");
    }
}

-(void)chooseBtnOfZoomScrollViewClick:(UIButton *)sender{
    IDMPhoto * photo = [_photos objectAtIndex:_currentPageIndex];
    BOOL isChoose = YES;
    if ([_chooseArray indexOfObject:photo] == NSNotFound) {
        [_chooseArray addObject:photo];
    }else{
        [_chooseArray removeObject:photo];
        isChoose = NO;
    }
    IDMZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    page.isChoose = isChoose;
    
}


-(BOOL)isChoosePhoto:(IDMPhoto *)photo{
    if ([_chooseArray indexOfObject:photo] == NSNotFound) {
        return NO;
    }else{
        return YES;
    }
}

-(NSString *)getDateStringWithPhoto:(NSDate *)date{
    //    NSDate *date = [photo getPhotoCreateTime];
    
    NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy年MM月dd日";
    NSString * dateString = [formatter1 stringFromDate:date];
    if ([dateString isEqualToString:@"1970年01月01日"]) {
        dateString = @"未知时间";
    }
    return dateString;
}

-(void)talkViewClick:(UIButton *)btn{
    FMCommentController * vc = [[FMCommentController alloc]init];
    FMShareAlbumItem * item = [self photoAtIndex:_currentPageIndex];
    
    vc.photoHash = item.digest;
    vc.item = item;
    [self presentViewController:vc  animated:YES completion:nil];
    
//    vc.photoHash = self.
}


-(UIView *)blackViewForRotate{
    if (!_blackViewForRotate) {
        UIView * blackView = [[UIView alloc]initWithFrame:CGRectMake(-1000, -1000, 2000, 2000)];
        blackView.backgroundColor = [UIColor blackColor];
        _blackViewForRotate = blackView;
        [self.view.superview insertSubview:[self blackViewForRotate] belowSubview:self.view];
    }
    return _blackViewForRotate;
}

-(void)autorotateViews:(UIDeviceOrientation)interfaceOrientation{
    if (_isdraggingPhoto)
        return;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self setNeedsStatusBarAppearanceUpdate];
    if (interfaceOrientation == UIDeviceOrientationLandscapeRight) {
        [self blackViewForRotate].alpha = 1;
        _nowRotateOrientation = UIDeviceOrientationLandscapeRight;
//        self.view.bounds = CGRectMake(0, 0, __kHeight, __kWidth);
        [UIView animateWithDuration:0.5 animations:^{
            self.view.bounds = CGRectMake(0, 0, __kHeight, __kWidth);
            self.view.transform = CGAffineTransformMakeRotation(-M_PI/2);
        } completion:^(BOOL finished) {
             [self blackViewForRotate].alpha = 0;
        }];
        
    }else if (interfaceOrientation == UIDeviceOrientationLandscapeLeft){
        _nowRotateOrientation = UIDeviceOrientationLandscapeLeft;
         [self blackViewForRotate].alpha = 1;
//        self.view.bounds = CGRectMake(0, 0, __kHeight, __kWidth);
        [UIView animateWithDuration:0.5 animations:^{
            self.view.bounds = CGRectMake(0, 0, __kHeight, __kWidth);
            self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
        } completion:^(BOOL finished) {
             [self blackViewForRotate].alpha = 0;
        }];
    }else{
        if (!_isDismiss) {
            [self blackViewForRotate].alpha = 1;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self blackViewForRotate].alpha = 0;
            });
        }
        if (_nowRotateOrientation != UIDeviceOrientationPortrait) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            [self setNeedsStatusBarAppearanceUpdate];
//            self.view.bounds = CGRectMake(0, 0,__kWidth, __kHeight);
            [UIView animateWithDuration:0.5 animations:^{
                self.view.bounds = CGRectMake(0, 0,__kWidth, __kHeight);
                self.view.transform = CGAffineTransformIdentity;
            }];
        }
        _nowRotateOrientation = UIDeviceOrientationPortrait;
    }
}

//-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    [self autorotateViews:interfaceOrientation];
//    return NO;
//}

- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation
{
    //1.获取 当前设备 实例
    UIDevice *device = [UIDevice currentDevice] ;
    
    
    
    
    /**
     *  2.取得当前Device的方向，Device的方向类型为Integer
     *
     *  必须调用beginGeneratingDeviceOrientationNotifications方法后，此orientation属性才有效，否则一直是0。orientation用于判断设备的朝向，与应用UI方向无关
     *
     *  @param device.orientation
     *
     */
    
    switch (device.orientation) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
            break;
            
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            break;
            
            //系統無法判斷目前Device的方向，有可能是斜置
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            [self autorotateViews:UIDeviceOrientationLandscapeLeft];;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            [self autorotateViews:UIDeviceOrientationLandscapeRight];
            break;
            
        case UIDeviceOrientationPortrait:
            [self autorotateViews:UIDeviceOrientationPortrait];
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            break;
            
        default:
            NSLog(@"无法辨识");
            break;
    }
    
}



//-(BOOL)shouldAutorotate
//{
//    return YES;
//}
//
//-(UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAll;
//}

@end
