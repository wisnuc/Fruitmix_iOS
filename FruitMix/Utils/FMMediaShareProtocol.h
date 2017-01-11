//
//  FMMediaShareProtocol.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/26.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FMMediaShareProtocol <NSObject>

@required

-(NSArray *)getAllContents;
-(NSArray *)viewers;
-(NSArray *)maintainers;
-(long long)getTime;
-(NSString *)author;
-(NSString *)uuid;
-(NSNumber *)isAlbum;
-(NSArray *)contents;
-(NSDictionary *)album;

@end
