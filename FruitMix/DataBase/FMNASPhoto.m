//
//  FMNASPhoto.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/27.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMNASPhoto.h"
#import "FMGetThumbImage.h"

@interface FMNASPhoto (){
    // Image Sources
    NSString *_photoPath;
    
    // Image
    UIImage *_underlyingImage;
    
    // Other
    NSString *_caption;
    BOOL _loadingInProgress;
    IDMProgressUpdateBlock _progressUpdateBlock;
    
    NSDate * _createDate;
    
    BOOL _shouldRequestThumbnail;
    
}

// Properties
@property (nonatomic, strong) UIImage *underlyingImage;

@property (nonatomic) UIImage * thumbImage;

// Methods
- (void)imageLoadingComplete;

@end

@implementation FMNASPhoto
@synthesize underlyingImage = _underlyingImage;


-(id)photoURL{
    return nil;
}

-(void)setThumbImage:(UIImage *)thumbImage{
    _thumbImage = thumbImage;
}
-(UIImage *)getThumbImage{
    return _thumbImage;
}

-(void)setShouldRequestThumbnail:(BOOL)shouldRequestThumbnail{
    _shouldRequestThumbnail = shouldRequestThumbnail;
}

-(BOOL)shouldRequestThumbnail{
    return _shouldRequestThumbnail;
}

-(void)setProgressUpdateBlock:(IDMProgressUpdateBlock)progressUpdateBlock{
    _progressUpdateBlock = progressUpdateBlock;
}

-(IDMProgressUpdateBlock)progressUpdateBlock{
    return _progressUpdateBlock;
}

//主键
+ (NSString *)primaryKeyFieldName {
    return @"fmhash";
}

-(void)setDatetime:(NSString *)datetime{
    _datetime = datetime;
    NSString * createDate = _datetime;
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy:MM:dd HH:mm:ss"];
    _createDate = [inputFormatter dateFromString:createDate];
}
- (void)setFmhash:(NSString *)fmhash{
     NSLog(@"😜😜😜😜%@",fmhash);
    _fmhash = fmhash;
}
//yymodel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"fmlong" : @"long",
             @"fmhash": @"hash"
             };
}

//+ (NSDictionary *)modelCustomPropertyMapper {
//    return @{
//             @"format":@"metadata.format",
//             @"exifDateTime":@"metadata.exifDateTime",
//             @"exifMake":@"metadata.exifMake",
//             @"exifModel":@"metadata.exifModel",
//             @"exifOrientation":@"metadata.exifOrientation",
//             
//             @"size":@"metadata.size",
//             @"height":@"metadata.height",
//             @"width":@"metadata.width"
//     };
//}


-(instancetype)init{
    self = [super init];
    if (self) {
        NSTimeInterval timeInteral = 0;
        _createDate = [[NSDate alloc]initWithTimeIntervalSince1970:timeInteral];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unloadUnderlyingImage) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(NSDate *)getPhotoCreateTime{
    return _createDate;
}

-(NSString *)getPhotoHash{
//    NSLog(@"🍄%@",self.fmhash);
    return self.fmhash;
    
}

-(void)getThumbnailWithCompleteBlock:(void(^)(UIImage *image, NSString *tag))block{
    [FMGetThumbImage getThumbImageWithAsset:self andCompleteBlock:block];
}

#pragma mark - Delegate

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
        } else if (_fmhash) {
            
            [FMGetImage getFullScreenImageWithPhotoHash:_fmhash andCompleteBlock:^(UIImage *image, NSString *tag) {
                if (image) {
                    self.underlyingImage = image;
                    
                    [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                }
            }];
        }else {
            // Failed - no source
            self.underlyingImage = nil;
            [self imageLoadingComplete];
        }
    }
}

// Release if we can get it again from path or url
- (void)unloadUnderlyingImage {
    _loadingInProgress = NO;
    
    if (self.underlyingImage && (_photoPath || _fmhash)) {
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
    UIImage * img = [[FMGetThumbImage defaultGetThumbImage].cache getImageForKey:_fmhash];
    return img?img:[UIImage imageNamed:@"photo_placeholder"];
}


-(NSString *)description{
    return [NSString stringWithFormat:@"* NAS Photo * digest:%@ ** time:%@ *",_fmhash,_createDate];
}

@end
