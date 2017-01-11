//
//  YYControl.m
//  YYKitExample
//
//  Created by ibireme on 15/9/14.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import "YYControl.h"

@implementation YYControl {
    UIImage *_image;
    CGPoint _point;
    NSTimer *_timer;
    BOOL _longPressDetected;
}

-(instancetype)init{
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    [super setImage:image];
    _image = image;
    self.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)dealloc {
    [self endTimer];
}

-(UIImage *)fixOrientation:(UIImage *)aImage
{
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *)image {
//    id content = self.layer.contents;
//    if (content != (id)_image.CGImage) {
//        CGImageRef ref = (__bridge CGImageRef)(content);
//        if (ref && CFGetTypeID(ref) == CGImageGetTypeID()) {
//            _image = [UIImage imageWithCGImage:ref scale:self.layer.contentsScale orientation:UIImageOrientationUp];
//        } else {
//            _image = nil;
//        }
//    }
    return _image;
}

- (void)startTimer {
    [_timer invalidate];
    _timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(timerFire) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)endTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)timerFire {
    [self touchesCancelled:[NSSet set] withEvent:nil];
    _longPressDetected = YES;
    if (_longPressBlock) _longPressBlock(self, _point);
    [self endTimer];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _longPressDetected = NO;
    if (_touchBlock) {
        _touchBlock(self, YYGestureRecognizerStateBegan, touches, event);
    }
    if (_longPressBlock) {
        UITouch *touch = touches.anyObject;
        _point = [touch locationInView:self];
        [self startTimer];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_longPressDetected) return;
    if (_touchBlock) {
        _touchBlock(self, YYGestureRecognizerStateMoved, touches, event);
    }
    [self endTimer];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_longPressDetected) return;
    if (_touchBlock) {
        _touchBlock(self, YYGestureRecognizerStateEnded, touches, event);
    }
    [self endTimer];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_longPressDetected) return;
    if (_touchBlock) {
        _touchBlock(self, YYGestureRecognizerStateCancelled, touches, event);
    }
    [self endTimer];
}

@end
