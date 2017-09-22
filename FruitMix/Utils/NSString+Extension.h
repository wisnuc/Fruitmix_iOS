//
//  NSString+Extension.h
//  Dialysis
//
//  Created by jackygood on 14/12/27.
//  Copyright (c) 2014年 beyondwinet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLFilesModel.h"

@interface NSString (Extension)

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;
+ (NSString *)fileSizeWithFileName:(NSString *)fileName;
+ (NSString *)fileSizeWithFLModel:(FLFilesModel *)model;
@end
