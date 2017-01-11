//
//  FMGeocoder.h
//  FruitMix
//
//  Created by 杨勇 on 16/9/21.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMGeocoder : NSObject

//反地理编码
+(void)geocodeWithLocation:(CLLocation *)location;

@end
