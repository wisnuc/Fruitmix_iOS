//
//  FMPhotoAsset.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/20.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMPhotoAsset.h"
#import "CocoaSecurity.h"
#import "FMGetThumbImage.h"

#define Scale

@interface FMPhotoAsset (){
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


@implementation FMPhotoAsset
@synthesize underlyingImage = _underlyingImage,
photoURL = _photoURL,
caption = _caption;

-(instancetype)init{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unloadUnderlyingImage) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)setCreatetime:(NSDate *)createtime{
    _createtime = createtime;
     NSDateFormatter * formatter1 = [[NSDateFormatter alloc]init];
    formatter1.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    [formatter1 setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    _createTimeString = [formatter1 stringFromDate:createtime];
}

-(void)getThumbnailWithCompleteBlock:(void(^)(UIImage *image, NSString *tag))block{
    dispatch_async([FMUtil setterDefaultQueue], ^{
        [FMGetThumbImage getThumbImageWithAsset:self andCompleteBlock:block];
    });
}

-(NSDate *)getPhotoCreateTime{
    return _createtime;
}

-(NSString *)getPhotoHash{
    if (IsNilString(self.degist))
    
    self.degist = [[FMLocalPhotoStore shareStore] getPhotoHashWithLocalId:self.localId];
    return _degist;
}

-(NSString *)getPhotoHashSync{
    if (IsNilString(_degist)) {
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        PHFetchResult * result = [PHAsset fetchAssetsWithLocalIdentifiers:@[self.localId] options:option];
        if (result.count) {
            [PhotoManager getImageFromPHAsset:result[0] Complete:^(NSData *fileData, NSString *fileName) {
                _degist = [CocoaSecurity sha256WithData:fileData].hexLower;
            }];
        }
    }
    return _degist;
}

-(UIImage *)getThumbImage{
    return self.thumbImage;
}

-(void)setThumbImage:(UIImage *)thumbImage{
    _thumbImage = thumbImage;
}

#pragma mark IDMPhoto Protocol Methods

- (UIImage *)underlyingImage {
    return _underlyingImage;
}

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
        } else if (_photoURL) {
            // Load async from web (using SDWebImageManager)
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:_photoURL options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                CGFloat progress = ((CGFloat)receivedSize)/((CGFloat)expectedSize);
                if (self.progressUpdateBlock) {
                    self.progressUpdateBlock(progress);
                }
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (image) {
                    self.underlyingImage = image;
                    [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                }
            }];
            
        } else if(_localId){
                // 图片原尺寸
            @weaky(self);
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                PHAsset * asset = [[FMLocalPhotoStore shareStore]checkPhotoIsLocalWithLocalId:_localId];
                if (asset) {
                    [PhotoManager getImageDataWithPHAsset:asset andCompleteBlock:^(NSString *filePath) {
                        if (filePath) {
                            weak_self.underlyingImage = [YYImage imageWithContentsOfFile:filePath];
                            [weak_self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                         }
                    }];
//                    CGFloat pW = __kWidth*[UIScreen mainScreen].scale;
//                    CGFloat pH = asset.pixelHeight * (pW/asset.pixelWidth);
//                    CGSize targetSize = CGSizeMake(pW, pH);
//                    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
//                    imageRequestOptions.synchronous = YES;
//                    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeDefault options:imageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//                        if (result) {
//                            weak_self.underlyingImage = result;
//                            [weak_self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
//                        }
//                    }];
                    }
            });
        }else {
            self.underlyingImage = nil;
            [self imageLoadingComplete];
        }
    }
}

// Release if we can get it again from path or url or localId
- (void)unloadUnderlyingImage {
    _loadingInProgress = NO;
    if ((self.underlyingImage && (_photoPath || _photoURL||_localId))||self.thumbImage) {
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
    if (self.degist) {
        img = [[FMGetThumbImage defaultGetThumbImage].cache getImageForKey:_degist];
    }
    
    return img?img:[UIImage imageNamed:@"photo_placeholder"];
}


-(NSString *)description{
    return [NSString stringWithFormat:@"*Local Photo* digest:%@ * localId:%@ * time:%@ ******",[self getPhotoHash],_localId,_createtime];
}


@end
