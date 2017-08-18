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

//@property  Metadata *metadata;
//@property (nonatomic) NSNumber *permittedToShare;
//@property (nonatomic) NSString *digest;
//
//@property (nonatomic) NSString *format;
//@property (nonatomic) NSString *exifDateTime;
//@property (nonatomic) NSString *exifMake;
//@property (nonatomic) NSString *exifModel;
//@property (nonatomic) NSInteger exifOrientation;
//
//@property (nonatomic) NSInteger size;
//@property (nonatomic) NSInteger height;
//@property (nonatomic) NSInteger width;
@property (nonatomic) NSString *m;
@property (nonatomic) NSInteger h;
@property (nonatomic) NSInteger w;
@property (nonatomic) NSInteger size;
@property (nonatomic) NSInteger orient;
@property (nonatomic) NSString *datetime;
@property (nonatomic) NSString *make;
@property (nonatomic) NSString *model;
@property (nonatomic) NSString *lat;
@property (nonatomic) NSString *latr;
@property (nonatomic) NSString *fmlong;
@property (nonatomic) NSString *longr;
@property (nonatomic) NSString *fmhash;
//"m": "JPEG",
//"w": 4624,
//"h": 2608,
//"orient": 1,
//"datetime": "2017:06:17 17:31:18",
//"make": "Sony",
//"model": "G3116",
//"lat": "31/1, 10/1, 506721/10000",
//"latr": "N",
//"long": "121/1, 36/1, 27960/10000",
//"longr": "E",
//"size": 4192863

//图片浏览器
-(void)setProgressUpdateBlock:(IDMProgressUpdateBlock)progressUpdateBlock;

-(IDMProgressUpdateBlock)progressUpdateBlock;

-(id)photoURL;

-(NSDate *)getPhotoCreateTime;

-(void)setThumbImage:(UIImage *)thumbImage;

-(UIImage *)getThumbImage;

@end



