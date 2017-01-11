//
//  NSString+JYImageType.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/22.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "NSString+JYImageType.h"

@implementation NSString (JYImageType)

+(BOOL)checkIsImageWithFileName:(NSString *)fileName{
    NSSet * set = [NSSet setWithObjects:@"jpeg",@"jpg",@"JPEG",@"JPG",@"png",@"PNG",@"GIF",@"gif",@"tiff", nil];
    NSString * filetype =  [fileName pathExtension];
    return [set containsObject:filetype];
}

+ (NSString *)sd_contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
        case 0x52:
            // R as RIFF for WEBP
            if ([data length] < 12) {
                return nil;
            }
            
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"image/webp";
            }
            
            return nil;
    }
    return nil;
}
@end
