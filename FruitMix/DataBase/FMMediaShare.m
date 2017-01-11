//
//  FMMediaShare.m
//  FruitMix
//
//  Created by 杨勇 on 16/5/26.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMMediaShare.h"
#import "FMMediaShareTask.h"

@implementation FMMediaShare{
    NSMutableArray< FMShareAlbumItem *> * _items;
}


-(long long)getTime{
    return self.mtime;
}

//主键
+ (NSString *)primaryKeyFieldName {
    return @"uuid";
}

// 当 JSON 转为 Model 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSDictionary * doc = dic[@"doc"];
    if (doc) {
        _digest = dic[DigestKey];
        _doctype = doc[@"doctype"];
        _docversion = doc[@"docversion"];
        _uuid = doc[UUIDKey];
        _author = doc[AuthorKey];
        _viewers = doc[ViewersKey];
        _maintainers = doc[MaintainersKey];
        
        _mtime = [doc[@"mtime"] doubleValue];
        _ctime = [doc[@"ctime"] doubleValue];
        _sticky = doc[@"sticky"];
        _contents = doc[ContentsKey];
        if ([doc[ALbumKey] isKindOfClass:[NSDictionary class]]) {
            _album = doc[ALbumKey];
            _isAlbum = @(1);
        }else{
            _album = nil;
            _isAlbum = @(0);
        }
        
        return YES;
    }else
        return NO;
}


-(NSArray *)contents{
    return _contents;
}

-(NSArray *)getAllContents{
    if (_items) {
        return _items;
    }
    NSMutableArray * dataSource = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary * dic in _contents) {
        FMShareAlbumItem * item = [FMShareAlbumItem new];
        item.shareid = self.uuid;
        item.digest = dic[DigestKey];
        item.creator = dic[AuthorKey];
        item.createtime = [NSDate dateWithTimeIntervalSince1970:[dic[@"time"] longLongValue]/1000];//时间赋值
        item.isLocal = NO;
        [dataSource addObject:item];
    }
    _items = dataSource;
    return dataSource;
}

-(BOOL)isEqualToMediaShare:(FMMediaShare *)share{
    return IsEquallString(share.digest, self.digest)&&IsEquallString(share.uuid, self.uuid);
}

@end
