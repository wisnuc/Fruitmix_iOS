//
//  FMCache.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/25.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMCache.h"



@implementation FMCache

+(void)saveImage:(UIImage *)image WithLocalId:(NSString *)lId{
    NSString * path = [NSString stringWithFormat:@"%@/%@", CachePath, lId];
    if (![self isFileExist:path]) {
        NSData *data;
        if (UIImagePNGRepresentation(image) == nil) {
            data = UIImageJPEGRepresentation(image, 1);
        } else {
            data = UIImagePNGRepresentation(image);
            
        }
        [data writeToFile:path atomically:YES];
    }
}


+(void)savedata:(NSData *)data WithLocalId:(NSString *)lId{
    NSString * path = [NSString stringWithFormat:@"%@/%@", CachePath, lId];
    if (![self isFileExist:path]) {
        [data writeToFile:path atomically:YES];
    }
}

+(BOOL)isFileExist:(NSString *)path{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]){
        return YES;
    }
    else{
        return NO;
    }
}

+(UIImage *)getImageWithLocalId:(NSString *)lId{
    NSString * path = [NSString stringWithFormat:@"%@/%@", CachePath, lId];
    if ([self isFileExist:path]) {
        NSData * data = [NSData dataWithContentsOfFile:path];
        UIImage * image = [UIImage imageWithData:data];
        return image;
    }
    return nil;
}
@end
