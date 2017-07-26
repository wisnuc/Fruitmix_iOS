//
//  FMNASPhoto.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/27.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMDTObject.h"

@interface Metadata : FMDTObject<IDMPhoto>
@property (nonatomic) NSInteger type;
@property (nonatomic) NSString * format;

@property (nonatomic) NSString * exifDateTime;
@property (nonatomic) NSString * exifMake;
@property (nonatomic) NSString * exifModel;
@property (nonatomic) NSInteger exifOrientation;

@property (nonatomic) NSInteger size;
@property (nonatomic) NSInteger height;
@property (nonatomic) NSInteger width;
@end



@interface FMNASPhoto : FMDTObject<IDMPhoto>

@property  Metadata *metadata;
@property (nonatomic) NSNumber *permittedToShare;
@property (nonatomic) NSString *digest;

@property (nonatomic) NSString *format;
@property (nonatomic) NSString *exifDateTime;
@property (nonatomic) NSString *exifMake;
@property (nonatomic) NSString *exifModel;
@property (nonatomic) NSInteger exifOrientation;

@property (nonatomic) NSInteger size;
@property (nonatomic) NSInteger height;
@property (nonatomic) NSInteger width;

//图片浏览器
-(void)setProgressUpdateBlock:(IDMProgressUpdateBlock)progressUpdateBlock;

-(IDMProgressUpdateBlock)progressUpdateBlock;

-(id)photoURL;

-(NSDate *)getPhotoCreateTime;

-(void)setThumbImage:(UIImage *)thumbImage;

-(UIImage *)getThumbImage;

@end



