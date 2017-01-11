//
//  FMGeocoder.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/21.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMGeocoder.h"

@implementation FMGeocoder

//反地理编码
+(void)geocodeWithLocation:(CLLocation *)location{
    //创建位置
    //    CLGeocoder *revGeo = [[CLGeocoder alloc] init];
    //    [revGeo reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
    //        if (!error && [placemarks count] > 0)
    //        {
    //            NSDictionary *dict = [[placemarks objectAtIndex:0] addressDictionary];
    //            NSLog(@"street address: %@",[dict objectForKey:@"Street"]);
    //            NSLog(@"City : %@",[dict objectForKey:@"City"]);
    //            NSLog(@"Country :%@",[dict objectForKey:@"Country"]);
    //            NSLog(@"FormattedAddressLines :%@",[dict objectForKey:@"FormattedAddressLines"][0]);
    //            NSLog(@"SubLocality : %@",[dict objectForKey:@"SubLocality"]);
    //            NSLog(@"SubThoroughfare : %@",[dict objectForKey:@"SubThoroughfare"]);
    //            NSLog(@"Thoroughfare : %@",[dict objectForKey:@"Thoroughfare"]);
    //        }
    //        else
    //        {
    //            NSLog(@"ERROR: %@", error); }
    //    }];
    
}

@end
