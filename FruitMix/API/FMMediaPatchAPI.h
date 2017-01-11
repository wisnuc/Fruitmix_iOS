//
//  FMMediaPatchAPI.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/1.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "JYBaseRequest.h"

typedef enum : NSUInteger {
    PatchTypeAdd,
    PatchTypeRemove,
    PatchTypeReplace,
} PatchType;

@interface FMMediaPatchAPI : JYBaseRequest

@property (nonatomic) NSMutableArray * patchArr;

@property (nonatomic) NSDictionary * param;

/**
 *  patch 接口
 *
 *  @param type    add /replace/remove
 *  @param shareid
 *  @param value
 *
 *  @return
 */
-(instancetype)initWithType:(PatchType)type andPath:(NSString *)shareid andValue:(id)value;

/**
 *  多条patch一次执行
 */
-(void)addPatchType:(PatchType)type andPath:(NSString *)shareid andValue:(id)value;
@end
