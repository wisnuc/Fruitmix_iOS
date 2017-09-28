//
//  TYDownloadUtility.m
//  TYDownloadManagerDemo
//
//  Created by tany on 16/6/12.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYDownloadUtility.h"

@implementation TYDownloadUtility

+ (float)calculateFileSizeInUnit:(unsigned long long)contentLength
{
    if(contentLength >= pow(10, 9))
        return (float) (contentLength / (float)pow(10, 9));
    else if(contentLength >= pow(10, 6))
        return (float) (contentLength / (float)pow(10, 6));
    else if(contentLength >= pow(10, 3))
        return (float) (contentLength / (float)pow(10, 3));
    else
        return (float) (contentLength);
}
+ (NSString *)calculateUnit:(unsigned long long)contentLength
{
     unsigned long long size =contentLength;
    NSString *sizeText = nil;
    if (contentLength >= pow(10, 9)) { // size >= 1GB
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

@end
