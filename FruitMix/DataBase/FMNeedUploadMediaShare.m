//
//  FMNeedUploadMediaShare.m
//  FruitMix
//
//  Created by 杨勇 on 16/6/26.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMNeedUploadMediaShare.h"

@implementation FMNeedUploadMediaShare{
    NSMutableArray< FMShareAlbumItem *> * _items;
}

+ (NSString *)primaryKeyFieldName {
    return @"uuid";
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.uuid = FMDT_UUID();
    }
    return self;
}

-(long long)getTime{
    return self.createDate;
}

-(NSArray *)contents{
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:0];
    if (self.netPhotos.count) {
        [array addObjectsFromArray:self.netPhotos];
    }
    if (self.localPhotos.count) {
        [array addObjectsFromArray:self.localPhotos];
    }
    return array;
}

-(NSArray *)getAllContents{
    if (!_items) {
        _items = [NSMutableArray arrayWithCapacity:0];
        for (NSString  * digest in self.contents) {
            FMShareAlbumItem * item = [FMShareAlbumItem new];
            item.digest = digest;
            item.createtime = [NSDate dateWithTimeIntervalSince1970:self.createDate/1000];
            [_items addObject:item];
        }
    }
    return _items;
}

//-(NSArray *)getAllItems{
//    if (!_items) {
//        _items = [NSMutableArray arrayWithCapacity:0];
//        for (NSDictionary * dic in self.getAllContents) {
//            FMShareAlbumItem * item = [FMShareAlbumItem new];
//            item.digest = dic[@"digest"];
//            item.isLocal = YES;
//            [_items addObject:item];
//        }
//    }
//    return _items;
//}

-(NSArray *)getUploadContents{
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:0];
    if (self.netPhotos.count) {
        for (NSString * digest in self.netPhotos) {
            NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:0];
            [dic setValue:digest forKey:@"digest"];
            [dic setValue:@"media" forKey:@"type"];
            [array addObject:dic];
        }
    }
    return array;
}

@end
