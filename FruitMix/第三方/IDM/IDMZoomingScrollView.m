//
//  IDMZoomingScrollView.m
//  IDMPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "IDMZoomingScrollView.h"
#import "IDMPhotoBrowser.h"
#import "IDMPhoto.h"

// Declare private methods of browser
@interface IDMPhotoBrowser ()
- (UIImage *)imageForPhoto:(id<IDMPhoto>)photo;
- (void)cancelControlHiding;
- (void)hideControlsAfterDelay;
- (void)toggleControls;
@end

// Private methods and properties
@interface IDMZoomingScrollView ()
@property (nonatomic) CGFloat doubleScale;
@property (nonatomic, weak) IDMPhotoBrowser *photoBrowser;
@property (nonatomic) NSString * chooseBtnImageName;
- (void)handleSingleTap:(CGPoint)touchPoint;
- (void)handleDoubleTap:(CGPoint)touchPoint view:(UIView *)view;
@end

@implementation IDMZoomingScrollView

@synthesize photoImageView = _photoImageView, photoBrowser = _photoBrowser, photo = _photo, captionView = _captionView;

- (id)initWithPhotoBrowser:(IDMPhotoBrowser *)browser {
    if ((self = [super init])) {
        // Delegate
        self.photoBrowser = browser;
        
		// Tap view for background
		_tapView = [[IDMTapDetectingView alloc] initWithFrame:self.bounds];
		_tapView.tapDelegate = self;
		_tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_tapView.backgroundColor = [UIColor clearColor];
		[self addSubview:_tapView];
        
		// Image view
		_photoImageView = [[IDMTapDetectingImageView alloc] initWithFrame:CGRectZero];
		_photoImageView.tapDelegate = self;
		_photoImageView.backgroundColor = [UIColor clearColor];
		[self addSubview:_photoImageView];
        
        /***********jy*************/
        
        _chooseBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        [_photoImageView addSubview:_chooseBtn];
        
        _lockIV = [[UIImageView alloc]initWithFrame:CGRectZero];
        [_photoImageView addSubview:_lockIV];
        
        self.photoState = JYPhotoNormal;
        
        _chooseBtnImageName = @"unselected";//未选中状态
        
        /**************************/
        
        CGRect screenBound = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenBound.size.width;
        CGFloat screenHeight = screenBound.size.height;
        
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft ||
            [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
            screenWidth = screenBound.size.height;
            screenHeight = screenBound.size.width;
        }
        
        // Progress view
        _progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake((screenWidth-35.)/2., (screenHeight-35.)/2, 35.0f, 35.0f)];
        [_progressView setProgress:0.0f];
        _progressView.tag = 101;
        _progressView.thicknessRatio = 0.1;
        _progressView.roundedCorners = NO;
        _progressView.trackTintColor    = browser.trackTintColor    ? self.photoBrowser.trackTintColor    : [UIColor colorWithWhite:0.2 alpha:1];
        _progressView.progressTintColor = browser.progressTintColor ? self.photoBrowser.progressTintColor : [UIColor colorWithWhite:1.0 alpha:1];
        [self addSubview:_progressView];
        
		// Setup
		self.backgroundColor = [UIColor clearColor];
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    return self;
}

- (void)setPhoto:(id<IDMPhoto>)photo {
    _photoImageView.image = nil; // Release image
    if (_photo != photo) {
        _photo = photo;
    }
    [self displayImage];
}

//jy
-(void)setIsChoose:(BOOL)isChoose{
    _isChoose = isChoose;
    _chooseBtnImageName =  isChoose?@"select":@"unselected";
    [self displayImage];
}

//jy addMethod
-(void)setPhotoState:(JYPhotoState)photoState{
    _photoState = photoState;
    [self displayImage];
}


- (void)prepareForReuse {
    self.photo = nil;
    [_captionView removeFromSuperview];
    self.captionView = nil;
}

#pragma mark - Image

// Get and display image
- (void)displayImage {
	if (_photo) {
		// Reset
		self.maximumZoomScale = 1;
		self.minimumZoomScale = 1;
		self.zoomScale = 1;
        
		self.contentSize = CGSizeMake(0, 0);
		
		// Get image from browser as it handles ordering of fetching
		UIImage *img = [self.photoBrowser imageForPhoto:_photo];
		if (img) {
            // Hide ProgressView
            //_progressView.alpha = 0.0f;
            [_progressView removeFromSuperview];
            
            // Set image
			_photoImageView.image = img;
			_photoImageView.hidden = NO;
            
            // Setup photo frame
			CGRect photoImageViewFrame;
			photoImageViewFrame.origin = CGPointZero;
			photoImageViewFrame.size = img.size;
            
			_photoImageView.frame = photoImageViewFrame;
			self.contentSize = photoImageViewFrame.size;
            CGFloat scale = img.size.width/__kWidth;
            /******************* jy ******************/
            _chooseBtn.frame = CGRectMake(_photoImageView.jy_Width - 40*scale/self.zoomScale, 40*scale/self.zoomScale, 20*scale/self.zoomScale, 20*scale/self.zoomScale);
            [_chooseBtn setBackgroundImage:[UIImage imageNamed:_chooseBtnImageName] forState:UIControlStateNormal];
//            [_chooseBtn setBackgroundColor:[UIColor whiteColor]];
            
            _lockIV.frame = CGRectMake(20*scale/self.zoomScale, _photoImageView.jy_Bottom -40*scale/self.zoomScale, 20*scale/self.zoomScale, 21*20/16*scale/self.zoomScale);
//            _lockIV.backgroundColor = [UIColor blackColor];
            [_lockIV setImage:[UIImage imageNamed:@"lock_line"]];
            
            if (self.photoState == JYPhotoNormal) {
                _chooseBtn.hidden = YES;
                _lockIV.hidden = YES;
            }else{
                _chooseBtn.hidden = NO;
                _lockIV.hidden = NO;
            }
            // Set zoom to minimum zoom
			[self setMaxMinZoomScalesForCurrentBounds];
        } else {
			// Hide image view
			_photoImageView.hidden = YES;
            
            _progressView.alpha = 1.0f;
		}
        
		[self setNeedsLayout];
	}
}

- (void)setProgress:(CGFloat)progress forPhoto:(IDMPhoto*)photo {
    //jy 修正
    if ([self.photo isKindOfClass:[IDMPhoto class]]) {
        IDMPhoto *p = (IDMPhoto*)self.photo;
        
        if ([photo.photoURL.absoluteString isEqualToString:p.photoURL.absoluteString]) {
            if (_progressView.progress < progress) {
                [_progressView setProgress:progress animated:YES];
            }
        }
    }
    
}

// Image failed so just show black!
- (void)displayImageFailure {
    [_progressView removeFromSuperview];
}

#pragma mark - Setup

//- (void)setMaxMinZoomScalesForCurrentBounds {
//    // Reset
//    self.maximumZoomScale = 1;
//    self.minimumZoomScale = 1;
//    self.zoomScale = 1;
//    
//    // Bail
//    if (_photoImageView.image == nil) return;
//    
//    // Sizes
//    CGSize boundsSize = self.bounds.size;
//    boundsSize.width -= 0.1;
//    boundsSize.height -= 0.1;
//    
//    CGSize imageSize = _photoImageView.frame.size;
//    
//    // Calculate Min
//    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
//    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
//    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
//    
//    _doubleScale = MAX(xScale, yScale);
//    
//    // If image is smaller than the screen then ensure we show it at
//    // min scale of 1
//    if (xScale > 1 && yScale > 1) {
//        //minScale = 1.0;
//    }
//    
//    // Calculate Max
//    CGFloat maxScale = 4.0; // Allow double scale
//    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
//    // maximum zoom scale to 0.5.
//    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
//        maxScale = maxScale / [[UIScreen mainScreen] scale];
//        
//        if (maxScale < minScale) {
//            maxScale = minScale * 2;
//        }
//    }
//    
//    // Calculate Max Scale Of Double Tap
//    CGFloat maxDoubleTapZoomScale = 4.0 * minScale; // Allow double scale
//    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
//    // maximum zoom scale to 0.5.
//    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
//        maxDoubleTapZoomScale = maxDoubleTapZoomScale / [[UIScreen mainScreen] scale];
//        
//        if (maxDoubleTapZoomScale < minScale) {
//            maxDoubleTapZoomScale = minScale * 2;
//        }
//    }
//    
//    // Set
//    self.maximumZoomScale = maxScale;
//    self.minimumZoomScale = minScale;
//    self.zoomScale = minScale;
//    self.maximumDoubleTapZoomScale = maxDoubleTapZoomScale;
//    
//    // Reset position
//    _photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
//    [self setNeedsLayout];    
//}


#pragma mark - JY Change For Feng
- (void)setMaxMinZoomScalesForCurrentBounds {
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    
    // Bail
    if (_photoImageView.image == nil) return;
    
    // Sizes
    CGSize boundsSize = self.bounds.size;
    boundsSize.width -= 0.1;
    boundsSize.height -= 0.1;
    
    CGSize imageSize = _photoImageView.frame.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    CGFloat maxFullScale = MAX(xScale, yScale);
    
    // If image is smaller than the screen then ensure we show it at
    // min scale of 1
    if (xScale > 1 && yScale > 1) {
        //minScale = 1.0;
    }
    
    // Calculate Max
    CGFloat maxScale = 4.0; // Allow double scale
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
        
        if (maxScale < minScale) {
            maxScale = minScale * 2;
        }
        
        if (maxScale < maxFullScale) {
            maxScale = maxFullScale;
        }
        
    }
    
    // Calculate Max Scale Of Double Tap
    CGFloat maxDoubleTapZoomScale = 4.0 * minScale; // Allow double scale
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxDoubleTapZoomScale = maxDoubleTapZoomScale / [[UIScreen mainScreen] scale];
        
        if (maxDoubleTapZoomScale < minScale) {
            maxDoubleTapZoomScale = minScale * 2;
        }
        if(maxDoubleTapZoomScale >maxScale){
            maxDoubleTapZoomScale = maxScale;
        }
        if (maxDoubleTapZoomScale < maxFullScale) {
            maxDoubleTapZoomScale = maxFullScale;
        }
    }
    
    // Set
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
    self.maximumDoubleTapZoomScale = maxDoubleTapZoomScale;
    
    // Reset position
    _photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
    [self setNeedsLayout];    
}

#pragma mark - Layout

- (void)layoutSubviews {
	// Update tap view frame
	_tapView.frame = self.bounds;
    
	// Super
	[super layoutSubviews];
    
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
	} else {
        frameToCenter.origin.x = 0;
	}
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
	} else {
        frameToCenter.origin.y = 0;
	}
    
	// Center
	if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter))
		_photoImageView.frame = frameToCenter;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _photoImageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[_photoBrowser cancelControlHiding];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
	[_photoBrowser cancelControlHiding];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[_photoBrowser hideControlsAfterDelay];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Tap Detection

- (void)handleSingleTap:(CGPoint)touchPoint {
	[_photoBrowser performSelector:@selector(toggleControls) withObject:nil afterDelay:0.2];
}


- (void)handleDoubleTap:(CGPoint)touchPoint view:(UIView *)view {
    
    // Cancel any single tap handling
    [NSObject cancelPreviousPerformRequestsWithTarget:_photoBrowser];
    
    // Zoom
    if (self.zoomScale != self.minimumZoomScale) {
        
        // Zoom out
        [self setZoomScale:self.minimumZoomScale animated:YES];
        
    } else {
        // Zoom in
        CGSize targetSize = CGSizeMake(self.frame.size.width / self.maximumDoubleTapZoomScale, self.frame.size.height / self.maximumDoubleTapZoomScale);
        CGPoint targetPoint = CGPointMake(touchPoint.x - targetSize.width / 2, touchPoint.y - targetSize.height / 2);
        CGPoint outTargetPoint = CGPointMake(touchPoint.x * (_photoImageView.bounds.size.width/view.bounds.size.width) - targetSize.width / 2, touchPoint.y * (_photoImageView.bounds.size.height/view.bounds.size.height) - targetSize.height / 2);
        if (![view.superclass isEqual:_photoImageView.superclass]) {
            [self zoomToRect:CGRectMake(outTargetPoint.x, outTargetPoint.y, targetSize.width, targetSize.height) animated:YES];
        }else{
            [self zoomToRect:CGRectMake(targetPoint.x, targetPoint.y, targetSize.width, targetSize.height) animated:YES];
        }
    }
    // Delay controls
    [_photoBrowser hideControlsAfterDelay];
}

#pragma mark - old Version

//- (void)handleDoubleTap:(CGPoint)touchPoint {
//	
//	// Cancel any single tap handling
//	[NSObject cancelPreviousPerformRequestsWithTarget:_photoBrowser];
//	
//	// Zoom
//	if (self.zoomScale == self.maximumZoomScale) {
//		
//		// Zoom out
//		[self setZoomScale:self.minimumZoomScale animated:YES];
//		
//	} else {
//		
//		// Zoom in
//		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
//		
//	}
//	
//	// Delay controls
//	[_photoBrowser hideControlsAfterDelay];
//}

// Image View
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch { 
    [self handleSingleTap:[touch locationInView:imageView]];
}
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:imageView] view:imageView];
}

// Background View
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:view]];
}
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:view] view:view];
}

@end
