//
//  FMCreateShareAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/9/21.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMCreateShareAPI.h"



@implementation FMCreateShareAPI

+(instancetype)shareCreateWithMaintainers:(NSArray *)maintainers
                                  Viewers:(NSArray *)viewers
                                 Contents:(NSArray *)contents
                                  IsAlbum:(NSDictionary *)album{
    FMCreateShareAPI * api = [FMCreateShareAPI new];
    
    NSMutableDictionary * tempDic = [NSMutableDictionary dictionaryWithCapacity:0];
    if (!maintainers)
        maintainers = [NSArray new];
    if (!viewers)
        viewers = [NSArray new];
    [tempDic setObject:maintainers forKey:MaintainersKey];
    [tempDic setObject:viewers forKey:ViewersKey];
    [tempDic setObject:contents forKey:ContentsKey];
    if(album)
       [tempDic setObject:album forKey:ALbumKey];
    api.param = tempDic ;
    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentDirectory = [paths objectAtIndex:0];
//    NSString *fileName = [NSString stringWithFormat:@"post.txt"];// 注意不是NSData!
//    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
//    [[NSFileManager defaultManager]createFileAtPath:logFilePath contents:[api.param yy_modelToJSONData] attributes:nil];
    return api;
}

-(id)requestArgument{
    NSLog(@"%@",_param);
    return self.param;
}

/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodPost;
}
/// 请求的URL
- (NSString *)requestUrl{
    return @"mediashare";
}
-(NSDictionary *)requestHeaderFieldValueDictionary{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}

@end
