//
//  FruitMixDefine.h
//  FruitMix
//
//  Created by JackYang on 16/3/16.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#ifndef FruitMixDefine_h
#define FruitMixDefine_h
#endif /* FruitMixDefine_h */

//#ifndef DEBUG
//# define NSLog(...) NSLog(__VA_ARGS__)
//#else
//# define NSLog(...) {}
//#endif


//UserDefaults keys
#define UserToken_STR  @"usertoken"
#define UUID_STR @"uuid"
#define DEVICE_UUID_STR @"deviceuuid"
#define DRIVE_UUID_STR @"driveuuid"
#define DIR_UUID_STR    @"diruuid"
#define ENTRY_UUID_STR      @"entryuuid"
#define PHOTO_ENTRY_UUID_STR      @"photoentryuuid"
#define LAST_REQUEST_TIME_STR @"last_request_time"
#define BASE_URL_STR @"base_url"
#define EXCEPTION_HANDLER_STR @"EXCEPTION_HANDLER"
#define USER_HOME_STR @"user_home"
#define SHOULD_UPLOAD_STR @"SHOULD_UPLOAD_STR"
#define SHOULD_WLNN_UPLOAD_STR @"SHOULD_WLNN_UPLOAD_STR"
#define KSWITHCHON     @"switchOn"


#define USER_SHOULD_SYNC_PHOTO_STR @"USER_SHOULD_SYNC_PHOTO_STR"
#define NO_USER @"NO_USER_STR"

//First TODO
#define IS_FIRST_IN_PHOTO_BROWSER_STR @"IS_FIRST_IN_PHOTO_BROWSER"
#define IS_FIRST_IN_ALBUM_STR @"IS_FIRST_IN_ALBUM"


//UserDefaults Values
#define DEF_Token [[NSUserDefaults standardUserDefaults]objectForKey:UserToken_STR]
#define DEF_UUID [[NSUserDefaults standardUserDefaults]objectForKey:UUID_STR]
#define DEF_HOME [[NSUserDefaults standardUserDefaults]objectForKey:USER_HOME_STR]
#define DRIVE_UUID  [[NSUserDefaults standardUserDefaults]objectForKey:DRIVE_UUID_STR]
#define DIR_UUID  [[NSUserDefaults standardUserDefaults]objectForKey:DIR_UUID_STR]
#define ENTRY_UUID [[NSUserDefaults standardUserDefaults]objectForKey:ENTRY_UUID_STR]
#define PHOTO_ENTRY_UUID [[NSUserDefaults standardUserDefaults]objectForKey:PHOTO_ENTRY_UUID_STR]
#define DEVICE_UUID [[NSUserDefaults standardUserDefaults]objectForKey:DEVICE_UUID_STR]
#define SWITHCHON_BOOL   [[NSUserDefaults standardUserDefaults] boolForKey:KSWITHCHON];

#define LAST_REQUEST_TIME [[NSUserDefaults standardUserDefaults]objectForKey:LAST_REQUEST_TIME_STR]//最后请求时间
#define BASE_URL [[NSUserDefaults standardUserDefaults]objectForKey:BASE_URL_STR]
#define EXCEPTION_HANDLER [[NSUserDefaults standardUserDefaults]boolForKey:EXCEPTION_HANDLER_STR]//上次是否为奔溃。

#define SHOULD_UPLOAD [[NSUserDefaults standardUserDefaults]boolForKey:SHOULD_UPLOAD_STR]


#define SHOULD_WLNN_UPLOAD [[NSUserDefaults standardUserDefaults]boolForKey:SHOULD_WLNN_UPLOAD_STR]

//抢先原则 记录 当前 可备份 用户 UUID
#define USER_SHOULD_SYNC_PHOTO [[NSUserDefaults standardUserDefaults]objectForKey:USER_SHOULD_SYNC_PHOTO_STR]

#define IS_FIRST_IN_PHOTO [[NSUserDefaults standardUserDefaults]objectForKey:IS_FIRST_IN_PHOTO_BROWSER_STR]
#define IS_FIRST_IN_ALBUM [[NSUserDefaults standardUserDefaults]objectForKey:IS_FIRST_IN_ALBUM_STR]


#define IsNilString(__String) (__String==nil || [__String isEqualToString:@""]|| [__String isEqualToString:@"null"])
#define __kWidth [[UIScreen mainScreen]bounds].size.width
#define __kHeight [[UIScreen mainScreen]bounds].size.height

// 取系统版本，e.g.  4.0 5.0
#define kSystemVersion [[[UIDevice currentDevice] systemVersion]  floatValue]
#define IOS9 kSystemVersion>9.0
#define MyAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define IsNilString(__String) (__String==nil || [__String isEqualToString:@""]|| [__String isEqualToString:@"null"])
#define MFont(font)   [UIFont systemFontOfSize:(font)]
#define MImage(image) [UIImage imageNamed:(image)]
#define loadingTime 1.5

#define IsNull(__Text) [__Text isKindOfClass:[NSNull class]]
#define IsEquallString(_Str1,_Str2)  [_Str1 isEqualToString:_Str2]

//字体
#define DONGQING @"Hiragino Sans GB"
#define Helvetica @"Helvetica"
#define FANGZHENG @"FZHei-B01S"

//16进制color 使用方法：HEXCOLOR(0xffffff)
#define HEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UICOLOR_RGB(RGB)     ([UIColor colorWithRed:((float)((RGB & 0xFF0000) >> 16))/255.0 green:((float)((RGB & 0xFF00) >> 8))/255.0 blue:((float)(RGB & 0xFF))/255.0 alpha:1.0])

#define JYSCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define JYSCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
//间距
#define FMPadding 10
#define FMShadowOffset 1
#define FMDefaultOffset 8


#ifndef weaky
#if DEBUG
#if __has_feature(objc_arc)
#define weaky(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weaky(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weaky(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weaky(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif


static inline CABasicAnimation * GetPositionAnimation (id fromValue, id toValue, CFTimeInterval duration, NSString *keyPath) {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.fromValue = fromValue;
    animation.toValue   = toValue;
    animation.duration = duration;
    animation.repeatCount = 0;
    animation.autoreverses = NO;
    //以下两个设置，保证了动画结束后，layer不会回到初始位置
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

static inline CAKeyframeAnimation * GetBtnStatusChangedAnimation() {
    CAKeyframeAnimation *animate = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animate.duration = 0.3;
    animate.removedOnCompletion = YES;
    animate.fillMode = kCAFillModeForwards;
    
    animate.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    return animate;
}
