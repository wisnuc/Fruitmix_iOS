//
//  FMNeedUploadPatch.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/27.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMDTObject.h"

@interface FMNeedUploadPatch : FMDTObject

@property (nonatomic) NSString * localid;

@property (nonatomic) NSString * shareid;


//sha256
@property (nonatomic) NSArray * addLocalArr;

/**
 *  has nil 、uploaded 、failed 、 notfound 、 jumpvideo
 */
@property (nonatomic) NSString * state;

//something delete can  do 

@end
