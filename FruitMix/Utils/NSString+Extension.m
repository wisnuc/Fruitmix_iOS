//
//  NSString+Extension.h
//  Dialysis
//
//  Created by jackygood on 14/12/27.
//  Copyright (c) 2014年 beyondwinet. All rights reserved.
//

#import "NSString+Extension.h"


@implementation NSString (Extension)

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}
+ (NSString *)fileSizeWithFileName:(NSString *)fileName
{
    // 总大小
    unsigned long long size = 0;
    NSString *sizeText = nil;
    // 文件管理者
    NSFileManager *mgr = [NSFileManager defaultManager];
    
    // 文件属性
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"JYDownloadCache/%@",fileName]];
//    MyNSLog(@"🌶%@",docDir);
    NSDictionary *attrs = [mgr attributesOfItemAtPath:docDir error:nil];
    
    // 如果这个文件或者文件夹不存在,或者路径不正确直接返回0;
    if (attrs == nil) return [NSString stringWithFormat:@"%llu",size];

        size = attrs.fileSize;
        if (size >= pow(10, 9)) { // size >= 1GB
            sizeText = [NSString stringWithFormat:@"%.2fG", size / pow(10, 9)];
        } else if (size >= pow(10, 6)) { // 1GB > size >= 1MB
            sizeText = [NSString stringWithFormat:@"%.2fM", size / pow(10, 6)];
        } else if (size >= pow(10, 3)) { // 1MB > size >= 1KB
            sizeText = [NSString stringWithFormat:@"%.2fK", size / pow(10, 3)];
        } else { // 1KB > size
            sizeText = [NSString stringWithFormat:@"%zdB", size];
        }
    
    return sizeText;
}
    
+(NSString *)fileSizeWithFLModel:(FLFilesModel *)model {
    long long size = 0;
    NSString *sizeText = nil;
    if ([model.type isEqualToString:@"file"]) { // 如果是文件夹
        size = model.size;
        if (size >= pow(10, 9)) { // size >= 1GB
            sizeText = [NSString stringWithFormat:@"%.2fG", size / pow(10, 9)];
        } else if (size >= pow(10, 6)) { // 1GB > size >= 1MB
            sizeText = [NSString stringWithFormat:@"%.2fM", size / pow(10, 6)];
        } else if (size >= pow(10, 3)) { // 1MB > size >= 1KB
            sizeText = [NSString stringWithFormat:@"%.2fK", size / pow(10, 3)];
        } else { // 1KB > size
            sizeText = [NSString stringWithFormat:@"%zdB", size];
        }
    }
    return sizeText;
}


@end
