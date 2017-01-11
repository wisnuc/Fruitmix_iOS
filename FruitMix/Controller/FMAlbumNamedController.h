//
//  FMAlbumNamedController.h
//  FruitMix
//
//  Created by 杨勇 on 16/4/19.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMBaseViewController.h"
#import "AutoHeightTextView.h"


typedef enum : NSUInteger {
    NamedUseInAlbum,
    NamedUseInPhoto,
} NamedState;

@interface FMAlbumNamedController : FMBaseViewController
@property (weak, nonatomic) IBOutlet UITextField *albumNameTF;
@property (nonatomic,assign) NSString * albumName;

@property (weak, nonatomic) IBOutlet AutoHeightTextView *albumDescTV;
@property (nonatomic,assign) NSString * albumDesc;

/**
 *  照片的 sha256 集合。
 */
@property (copy, nonatomic) NSArray * photoArr;

/**
 *  区分 场景
 */
@property (nonatomic) NamedState namedState;
@end
