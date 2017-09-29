//
//  FMConfiguation.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/21.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMConfiguation.h"

@implementation FMConfiguation
@synthesize userToken = _userToken;
@synthesize deviceUUID = _deviceUUID , userUUID = _userUUID , userHome = _userHome , usersDic = _usersDic;

+(instancetype)shareConfiguation{
    static FMConfiguation * config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[FMConfiguation alloc]init];
    });
    return config;
}

-(NSString *)userHome{
    if(IsNilString(_userHome)){
        if (IsNilString(DEF_HOME)) {
            [FMDBControl asyncUserHome];//去获取UserHome
        }
        _userHome = DEF_HOME;
    }
    return _userHome;
}

-(void)setUserHome:(NSString *)userHome{
    _userHome = userHome;
    [[NSUserDefaults standardUserDefaults] setObject:userHome forKey:USER_HOME_STR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setUserToken:(NSString *)userToken{
    _userToken = userToken;
    [[NSUserDefaults standardUserDefaults] setObject:userToken forKey:UserToken_STR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)userToken{
    if (IsNilString(_userToken)) {
        _userToken = DEF_Token;
    }
    return _userToken;
}

- (void)setIsCloud:(BOOL)isCloud{
    _isCloud = isCloud;
    [[NSUserDefaults standardUserDefaults] setBool:isCloud forKey:KISCLOUD_STR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setNickName:(NSString *)nickName{
    _nickName = nickName;
    [[NSUserDefaults standardUserDefaults] setObject:nickName forKey:KNickName_STR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setDeviceUUID:(NSString *)deviceUUID{
    _deviceUUID = deviceUUID;
    [[NSUserDefaults standardUserDefaults] setObject:deviceUUID forKey:DEVICE_UUID_STR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)deviceUUID{
    if (IsNilString(_deviceUUID)) {
        _deviceUUID = DEVICE_UUID;
    }
    return _deviceUUID;
}

-(NSString *)userUUID{
    if (IsNilString(_userUUID)) {
        _userUUID = DEF_UUID;
    }
    return _userUUID;
}

-(void)setUserUUID:(NSString *)userUUID{
    _userUUID = userUUID;
    [[NSUserDefaults standardUserDefaults] setObject:userUUID forKey:UUID_STR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setUsersDic:(NSMutableDictionary *)usersDic{
    _usersDic = usersDic;
}

- (void)setAvatarUrl:(NSString *)avatarUrl{
    _avatarUrl = avatarUrl;
    [[NSUserDefaults standardUserDefaults] setObject:avatarUrl forKey:KAVATARURL_STR];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSMutableDictionary *)usersDic{
    if (!_usersDic) {
        NSArray * users = [FMDBControl getAllUsers];
        _usersDic = [NSMutableDictionary dictionaryWithCapacity:0];
        for (FMUsers * user in users) {
            [_usersDic setObject:user.username forKey:user.uuid];
        }
    }
    return _usersDic;
}

-(NSString *)getUserNameWithUUID:(NSString *)uuid{
    NSString * username = @"未知";
    if (!IsNilString([self.usersDic objectForKey:uuid])) {
        username = [self.usersDic objectForKey:uuid];
    }
     return  username;
}

//- (NSString *)getBonjourWithUUID:(NSString *)uuid{
//    NSString * bonjourname = @"未知";
//    if (!IsNilString([self.usersDic objectForKey:uuid])) {
//        bonjourname = [self.usersDic objectForKey:uuid];
//    }
//    return  bonjourname;
//}
-(void)cleanTheUserAllLocalCache{
    
}

@end
