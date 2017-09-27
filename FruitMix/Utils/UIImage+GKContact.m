//
// Created by Georg Kitz on 01/05/14.
// Copyright (c) 2014 Tracr Ltd. All rights reserved.
//

#import "UIImage+GKContact.h"
#import "UIColor+FM_UserHeadImage.h"

static inline NSString *GKInitials(NSString *name) {
    __block NSMutableString *initials = [NSMutableString new];
    NSArray *array = [name componentsSeparatedByString:@" "];
    [array enumerateObjectsUsingBlock:^(NSString *part, NSUInteger idx, BOOL *stop) {

        if (part.length == 0) {
            return;
        }

        [initials appendString:[part substringToIndex:1]];

        if (idx == 1) {
            *stop = YES;
        };
    }];

    return initials;
}

static inline NSString *GKContactKey(NSString *initials, CGSize size, UIColor *backgroundColor, UIColor *textColor, UIFont *font) {
    return [NSString stringWithFormat:@"%@-%f-%f-%@-%@-%@", initials, size.width, size.height, backgroundColor.description, textColor.description, font.description];
}

@implementation UIImage (GKContact)


#pragma mark -
#pragma mark Cache

+ (NSMutableDictionary *)cachedImages {
    static NSMutableDictionary *items = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
       items = [NSMutableDictionary new];
    });

    return items;
}

+ (UIImage *)imageForKey:(NSString *)key {
    return self.cachedImages[key];
}

+ (void)setImage:(UIImage *)image forKey:(NSString *)key {
    self.cachedImages[key] = image;
}

#pragma mark -
#pragma mark Image Drawing

+ (UIImage *)drawImageForInitials:(NSString *)initials size:(CGSize)imageSize backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor font:(UIFont *)font
{
    CGFloat w = imageSize.width;
    CGFloat h = imageSize.height;
    CGFloat r = imageSize.width / 2;

    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, backgroundColor.CGColor);
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);

    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, w, h)];
    [path addClip];
    [path setLineWidth:1.0f];
    [path stroke];

    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, w, h));

    NSDictionary *dict = @{NSFontAttributeName: font, NSForegroundColorAttributeName: textColor};
    CGSize textSize = [initials sizeWithAttributes:dict];

    [initials drawInRect:CGRectMake(r - textSize.width / 2, r - font.lineHeight / 2, w, h) withAttributes:dict];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}

#pragma mark -
#pragma mark Public Methods

+ (instancetype)imageWhiteForName:(NSString *)name size:(CGSize)size {
    
    // Default colors.
    UIColor *defaultBackgroundColor = [UIColor whiteColor];
    UIColor *defaultTextColor = COR1;
    
    // Default font.
    CGFloat r = size.width / 2;
    UIFont *font = [UIFont systemFontOfSize:r - 6];
    
    return [self imageWhiteForName:name  size:size backgroundColor:defaultBackgroundColor textColor:defaultTextColor font:font];
}

+ (instancetype)imageWhiteForName:(NSString *)name size:(CGSize)size backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor font:(UIFont *)font
{
    NSString *initials = [GKInitials(name) uppercaseString];
    NSString *key = GKContactKey(initials, size, backgroundColor, textColor, font);
    
    UIImage *image = [self imageForKey:key];
    if (!image) {
        //修改颜色
        image = [self drawImageForInitials:initials size:size backgroundColor:[UIColor whiteColor] textColor:textColor font:font];
        [self setImage:image forKey:key];
    }
    
    return image;
}
+ (instancetype)imageForName:(NSString *)name size:(CGSize)size {

    // Default colors.
    UIColor *defaultBackgroundColor = [UIColor colorWithRed:0.784 green:0.776 blue:0.800 alpha:1];
    UIColor *defaultTextColor = [UIColor whiteColor];

    // Default font.
    CGFloat r = size.width / 2;
    UIFont *font = [UIFont systemFontOfSize:r - 6];

    return [self imageForName:name  size:size backgroundColor:defaultBackgroundColor textColor:defaultTextColor font:font];
}

+ (instancetype)imageForName:(NSString *)name size:(CGSize)size backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor font:(UIFont *)font
{
    NSString *initials = [GKInitials(name) uppercaseString];
    NSString *key = GKContactKey(initials, size, backgroundColor, textColor, font);

    UIImage *image = [self imageForKey:key];
    if (!image) {
        //修改颜色
        image = [self drawImageForInitials:initials size:size backgroundColor:[UIColor colorForUser:name] textColor:textColor font:font];
        [self setImage:image forKey:key];
    }

    return image;
}



+ (UIImage *)imageWithSize:(CGSize)size drawBlock:(void (^)(CGContextRef context))drawBlock {
    if (!drawBlock) return nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return nil;
    drawBlock(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)rescaleImageToSize:(CGSize)size {
    
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    
    [self drawInRect:rect];  // scales image to rect
    
    UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resImage;
    
}


+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio :(CGSize)targetSize
{
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        }
        else {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp ||sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight,CGImageGetBitsPerComponent(imageRef),CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth,CGImageGetBitsPerComponent(imageRef),CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }
    
    /*  // In the right or left cases, we need to switch scaledWidth and scaledHeight,
     // and also the thumbnail point
     if (sourceImage.imageOrientation == UIImageOrientationLeft) {
     thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
     CGFloat oldScaledWidth = scaledWidth;
     scaledWidth = scaledHeight;
     scaledHeight = oldScaledWidth;
     
     CGContextRotateCTM (bitmap, radians(90));
     CGContextTranslateCTM (bitmap, 0, -targetHeight);
     
     } else if (sourceImage.imageOrientation ==UIImageOrientationRight) {
     thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
     CGFloat oldScaledWidth = scaledWidth;
     scaledWidth = scaledHeight;
     scaledHeight = oldScaledWidth;
     
     CGContextRotateCTM (bitmap, radians(-90));
     CGContextTranslateCTM (bitmap, -targetWidth, 0);
     
     } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
     // NOTHING
     } else if (sourceImage.imageOrientation == UIImageOrientationDown){
     CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
     CGContextRotateCTM (bitmap, radians(-180.));
     }
     */
    CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x,thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage;
}



+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size
{
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



@end
