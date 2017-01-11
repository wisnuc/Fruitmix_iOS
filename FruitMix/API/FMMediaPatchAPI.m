//
//  FMMediaPatchAPI.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/1.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMMediaPatchAPI.h"

@implementation FMMediaPatchAPI
/// Http请求的方法
- (JYRequestMethod)requestMethod{
    return JYRequestMethodPatch;
}
/// 请求的URL
- (NSString *)requestUrl{
    return @"mediashare";
}
-(NSDictionary *)requestHeaderFieldValueDictionary{
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"JWT %@",DEF_Token] forKey:@"Authorization"];
    return dic;
}

-(id)requestArgument{
    NSLog(@"%@",self.param);
    return self.param;
}

-(NSDictionary *)param{
    if (_param) {
        return _param;
    }else if (_patchArr){
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:0];
        NSData * commandsData=[NSJSONSerialization dataWithJSONObject:_patchArr options:0 error:nil];
        //[[NSString alloc]initWithData:commandsData encoding:NSUTF8StringEncoding]
        [dict setObject:[[NSString alloc]initWithData:commandsData encoding:NSUTF8StringEncoding] forKey:@"commands"];
        return dict;
    }
    return nil;
}


-(instancetype)initWithType:(PatchType)type andPath:(NSString *)shareid andValue:(id)value{
    if (self = [super init]) {
//        [JYRequestConfig sharedConfig].baseURL = @"http://192.168.1.102:9220/";
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
        NSString * ty = @"";
        switch (type) {
            case PatchTypeAdd:
                ty = @"add";
                break;
            case PatchTypeReplace:
                ty = @"replace";
                break;
            case PatchTypeRemove:
                ty = @"remove";
                break;
            default:
                break;
        }
        [dic setValue:ty forKey:@"op"];
        [dic setValue:shareid forKey:@"path"];
        [dic setValue:value forKey:@"value"];
        
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:0];
//        NSData * opDic=[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
//        NSArray * arrCom = [NSArray arrayWithObject:[[NSString alloc]initWithData:opDic encoding:NSUTF8StringEncoding]];
        NSMutableArray * arrCom = [NSMutableArray arrayWithCapacity:0];
        [arrCom addObject:dic];
        
        NSData * commandsData=[NSJSONSerialization dataWithJSONObject:arrCom options:0 error:nil];
        
        
        [dict setObject:[[NSString alloc]initWithData:commandsData encoding:NSUTF8StringEncoding] forKey:@"commands"];
        _param = dict;
    }
    return self;
}

- (id)responseSerialization{
    AFHTTPResponseSerializer * js = [AFHTTPResponseSerializer serializer];
    return js;
}

-(NSMutableArray *)patchArr{
    if (!_patchArr) {
        _patchArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _patchArr;
}

-(void)addPatchType:(PatchType)type andPath:(NSString *)shareid andValue:(id)value{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString * ty = @"";
    switch (type) {
        case PatchTypeAdd:
            ty = @"add";
            break;
        case PatchTypeReplace:
            ty = @"replace";
            break;
        case PatchTypeRemove:
            ty = @"remove";
            break;
        default:
            break;
    }
    [dic setValue:ty forKey:@"op"];
    [dic setValue:shareid forKey:@"path"];
//     NSData * commandsData=[NSJSONSerialization dataWithJSONObject:value options:0 error:nil];[[NSString alloc]initWithData:commandsData encoding:NSUTF8StringEncoding]
    [dic setValue:value forKey:@"value"];
    [self.patchArr addObject:dic];
}

@end
