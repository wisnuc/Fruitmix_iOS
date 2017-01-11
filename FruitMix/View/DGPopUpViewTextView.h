//
//  DGPopUpViewTextView.h
//  DGPopUpViewController
//
//  Created by 段昊宇 on 16/6/18.
//  Copyright © 2016年 Desgard_Duan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGPopUpViewTextView : UIView
@property (weak, nonatomic) IBOutlet UITextField *textField;
- (instancetype) initWithName: (NSString *) name;
- (instancetype) initWithName: (NSString *) name andPlaceHolder:(NSString *)holderText;
@end
