//
//  FMPhotosCollectionViewCell.m
//  FruitMix
//
//  Created by 杨勇 on 16/4/5.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMPhotosCollectionViewCell.h"
#import "FMUtil.h"
#import "FMGetThumbImage.h"

@interface FMPhotosCollectionViewCell  ()

@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;

@end


@implementation FMPhotosCollectionViewCell

-(void)prepareForReuse{
    [super prepareForReuse];
    self.fmPhotoImageView.backgroundColor =UICOLOR_RGB(0xf5f5f5);
    self.fmPhotoImageView.image = [self imageWithColor:UICOLOR_RGB(0xf5f5f5)];
    self.lockBtn.hidden = YES;
    self.maskLayer.hidden =YES;
}

- (UIImage*) imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    UILongPressGestureRecognizer * longGesture =
            [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongGesture:)];
    longGesture.minimumPressDuration = 0.5f;
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)];
    [self.fmPhotoImageView addGestureRecognizer:tapGesture];
    
    [self.fmPhotoImageView addGestureRecognizer:longGesture];
    self.fmPhotoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.fmPhotoImageView.userInteractionEnabled = YES;
    self.chooseBtn.hidden = YES;
    
    
}


-(void)handleTapGesture:(UITapGestureRecognizer *)tap{
    if (self.fmDelegate) {
        if([self.fmDelegate respondsToSelector:@selector(FMPhotosCollectionViewCellDidChoose:)]){
            [self.fmDelegate FMPhotosCollectionViewCellDidChoose:self];
        }
    }
}

-(void)setState:(FMPhotosCollectionViewCellState)state{
    _state = state;
//    self.lockBtn.hidden = state;
//    self.maskLayer.hidden = state;
}


- (IBAction)chooseBtnClick:(id)sender {
    if (self.fmDelegate) {
        if ([self.fmDelegate respondsToSelector:@selector(FMPhotosCollectionViewCellDidChoose:)]) {
            [self.fmDelegate FMPhotosCollectionViewCellDidChoose:self];
        }
    }
}

-(void)setBtnHiddenWithAsset:(id<IDMPhoto>)asset{
    if ([asset isKindOfClass:[FMNASPhoto class]]) {
        if (!self.state) {
//            if(![((FMNASPhoto *)asset).permittedToShare boolValue]){
//                self.lockBtn.hidden = NO;
//                self.maskLayer.hidden = NO;
//            }
        }
    }
}

-(void)setAsset:(id<IDMPhoto>)asset{
    if (_asset) _asset.shouldRequestThumbnail = NO;
    _asset = asset;
    asset.shouldRequestThumbnail = YES;
    NSString * hash = [asset getPhotoHash];
    [self setBtnHiddenWithAsset:asset];
    @weaky(self);
//    self.fmPhotoImageView.image = [UIImage imageNamed:@"photo_placeholder"];
    FMGetThumbImageCompleteBlock _block = ^(UIImage *image, NSString * tag) {
        if (IsEquallString(tag, weak_self.imageTag)) {
            weak_self.fmPhotoImageView.image = image;
        }else{
            
        }
//         [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
    };
//       NSLog(@"%@😆%@",[asset class],hash);
    if (IsNilString(hash)) _imageTag = ((FMPhotoAsset *)asset).localId;
 
    else  _imageTag = hash; //有 digest
    [asset getThumbnailWithCompleteBlock:_block];
   
}


-(void)setIsChoose:(BOOL)isChoose{
    _isChoose = isChoose;
    self.chooseBtn.hidden = !isChoose;
    if (isChoose) {
//        [self.chooseBtn.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
        self.fmPhotoImageView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    }else{
        self.fmPhotoImageView.transform = CGAffineTransformIdentity;
    }
}

-(void)setChooseWithAnimation:(BOOL)isChoose{
    _isChoose = isChoose;
    self.chooseBtn.hidden = !isChoose;
    if (isChoose) {
        [self.chooseBtn.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
        self.fmPhotoImageView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    }else{
        self.fmPhotoImageView.transform = CGAffineTransformIdentity;
    }
}

- (void)handleLongGesture:(UILongPressGestureRecognizer * )gesture{
    if(gesture.state == UIGestureRecognizerStateBegan){
        if (self.fmDelegate) {
            if([self.fmDelegate respondsToSelector:@selector(FMPhotosCollectionViewCellDidLongPress:)]){
                [self.fmDelegate FMPhotosCollectionViewCellDidLongPress:self];
            }
        }
    }
}

@end
