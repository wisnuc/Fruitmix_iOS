//
//  FMAlbumEditViewController.h
//  FruitMix
//
//  Created by 杨勇 on 16/6/6.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMBaseViewController.h"
#import "FMAlbumNamedController.h"
#import "AutoHeightTextView.h"

@interface FMAlbumEditViewController : FMBaseViewController

@property (weak, nonatomic) IBOutlet UITextField *albumNameTF;
@property (weak, nonatomic) IBOutlet AutoHeightTextView *albumDescTV;

/**
 *  照片的 sha256 集合。
 */
@property (copy, nonatomic) NSArray<IDMPhoto *> * photoArr;

@property (nonatomic) id<FMMediaShareProtocol> album;

@end
