//
//  FMShareAlbumItem.m
//  FruitMix
//
//  Created by 杨勇 on 16/5/18.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMShareAlbumItem.h"
#import "FMGetThumbImage.h"

@interface FMShareAlbumItem (){
    // Image Sources
    NSString *_photoPath;
    
    // Image
    UIImage *_underlyingImage;
    
    // Other
    NSString *_caption;
    BOOL _loadingInProgress;
}

// Properties
@property (nonatomic, strong) UIImage *underlyingImage;

// Methods
- (void)imageLoadingComplete;

@end

@implementation FMShareAlbumItem

@synthesize underlyingImage = _underlyingImage,
photoURL = _photoURL,
caption = _caption;


-(NSDate *)getPhotoCreateTime{
    return _createtime;
}

-(NSString *)getPhotoHash{
    return self.digest;
}

-(UIImage *)getThumbImage{
    return _thumbImage;
}


-(instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unloadUnderlyingImage) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        _shouldRequestThumbnail = YES;
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark IDMPhoto Protocol Methods

- (void)loadUnderlyingImageAndNotify {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    _loadingInProgress = YES;
    if (self.underlyingImage) {
        // Image already loaded
        [self imageLoadingComplete];
    } else {
        if (_photoPath) {
            // Load async from file
            [self performSelectorInBackground:@selector(loadImageFromFileAsync) withObject:nil];
        } else if (_digest) {
            [PhotoManager managerCheckPhotoIsLocalWithPhotohash:_digest andCompleteBlock:^(NSString *localId, NSString *photoHash, BOOL isLocal) {
                if (isLocal) {
                    [[FMGetImage defaultGetImage] getOriginalImageWithLocalhash:_digest andCompleteBlock:^(UIImage *image, NSString *tag) {
                        if (image) {
                            self.underlyingImage = image;
                            [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                        }
                    } andIsCover:NO];
                }else{
                    [[FMGetImage defaultGetImage] getOriginalImageWithHash:_digest andCount:0 andPressBlock:^(NSInteger receivedSize, NSInteger expectedSize) {
                        CGFloat progress = ((CGFloat)receivedSize)/((CGFloat)expectedSize);
                        if (self.progressUpdateBlock) {
                            self.progressUpdateBlock(progress);
                        }
                    }andCompletBlock:^(UIImage *image, NSString *tag) {
                        if (image) {
                            self.underlyingImage = image;
                            [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                        }
                    }];
                }
                
            }];
        }else {
            self.underlyingImage = nil;
            [self imageLoadingComplete];
        }
    }
}

- (void)unloadUnderlyingImage {
    _loadingInProgress = NO;
    
    if (self.underlyingImage && (_photoPath || _digest)) {
        self.underlyingImage = nil;
        self.thumbImage = nil;
    }
}

#pragma mark - Async Loading

- (UIImage *)decodedImageWithImage:(UIImage *)image {
    if (image.images)
    {
        // Do not decode animated images
        return image;
    }
    
    CGImageRef imageRef = image.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGRect imageRect = (CGRect){.origin = CGPointZero, .size = imageSize};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    int infoMask = (bitmapInfo & kCGBitmapAlphaInfoMask);
    BOOL anyNonAlpha = (infoMask == kCGImageAlphaNone ||
                        infoMask == kCGImageAlphaNoneSkipFirst ||
                        infoMask == kCGImageAlphaNoneSkipLast);
    
    // CGBitmapContextCreate doesn't support kCGImageAlphaNone with RGB.
    // https://developer.apple.com/library/mac/#qa/qa1037/_index.html
    if (infoMask == kCGImageAlphaNone && CGColorSpaceGetNumberOfComponents(colorSpace) > 1)
    {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        
        // Set noneSkipFirst.
        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    }
    // Some PNGs tell us they have alpha but only 3 components. Odd.
    else if (!anyNonAlpha && CGColorSpaceGetNumberOfComponents(colorSpace) == 3)
    {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
    }
    
    // It calculates the bytes-per-row based on the bitsPerComponent and width arguments.
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 imageSize.width,
                                                 imageSize.height,
                                                 CGImageGetBitsPerComponent(imageRef),
                                                 0,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    // If failed, return undecompressed image
    if (!context) return image;
    
    CGContextDrawImage(context, imageRect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    
    UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(decompressedImageRef);
    return decompressedImage;
}

// Called in background
// Load image in background from local file
- (void)loadImageFromFileAsync {
    @autoreleasepool {
        @try {
            self.underlyingImage = [UIImage imageWithContentsOfFile:_photoPath];
            if (!_underlyingImage) {
                //IDMLog(@"Error loading photo from path: %@", _photoPath);
            }
        } @finally {
            self.underlyingImage = [self decodedImageWithImage: self.underlyingImage];
            [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
        }
    }
}

// Called on main
- (void)imageLoadingComplete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // Complete so notify
    _loadingInProgress = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:IDMPhoto_LOADING_DID_END_NOTIFICATION
                                                        object:self];
}

-(UIImage *)placeholderImage{
    UIImage * img;
    if (self.digest) {
        img = [[FMGetThumbImage defaultGetThumbImage].cache getImageForKey:_digest];
    }
    return img?img:[UIImage imageNamed:@"photo_placeholder"];
}

-(void)getThumbnailWithCompleteBlock:(void (^)(UIImage *, NSString *))block{
    [FMGetThumbImage getThumbImageWithAsset:self andCompleteBlock:block];
}

@end
