//
//  FMABManager.m
//  FruitMix
//
//  Created by 杨勇 on 16/10/25.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMABManager.h"
#import "APContact.h"
#import "APAddressBook.h"
#import "FMUploadFileAPI.h"

@interface FMABManager ()

@property (nonatomic, strong) APAddressBook *addressBook;

@end

@implementation FMABManager

+(instancetype)shareManager{
    static FMABManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

-(instancetype)init{
    if (self = [super init]) {
        self.addressBook = [[APAddressBook alloc] init];
        [self loadContacts];
        __weak typeof(self) weakSelf = self;
        [self.addressBook startObserveChangesWithCallback:^
         {
             [weakSelf loadContacts];
         }];
    }
    return self;
}

- (void)loadContacts
{
    //    [self.memoryStorage removeAllTableItems];
//    [self.activity startAnimating];
//    __weak __typeof(self) weakSelf = self;
    self.addressBook.fieldsMask = APContactFieldAll;
    self.addressBook.sortDescriptors = @[
                                         [NSSortDescriptor sortDescriptorWithKey:@"name.firstName" ascending:YES],
                                         [NSSortDescriptor sortDescriptorWithKey:@"name.lastName" ascending:YES]];
    self.addressBook.filterBlock = ^BOOL(APContact *contact)
    {
        return contact.phones.count > 0;
    };
    [self.addressBook loadContacts:^(NSArray<APContact *> *contacts, NSError *error) {
//        [weakSelf.activity stopAnimating];
        if (contacts)
        {
//            NSLog(@"%lu..%@",(unsigned long)contacts.count,[contacts yy_modelToJSONObject]);
//            
//            for (APContact * con in contacts) {
//                NSLog(@"...%@",[con yy_modelToJSONObject]);
//            }
//            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = [paths objectAtIndex:0];
            NSString *fileName = [NSString stringWithFormat:@"addressBook%f.txt",[NSDate new].timeIntervalSince1970];// 注意不是NSData!
            NSString *addressFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
            // 先删除已经存在的文件
//            NSFileManager *defaultManager = [NSFileManager defaultManager];
//            [defaultManager removeItemAtPath:logFilePath error:nil];
            
            [[NSFileManager defaultManager]createFileAtPath:addressFilePath contents:[contacts yy_modelToJSONData] attributes:nil];
            [FMUploadFileAPI uploadAddressFileWithFilePath:addressFilePath andCompleteBlock:^(BOOL success) {
                NSLog(@"上传 addressbook %@",success?@"成功":@"失败");
                [[NSFileManager defaultManager] removeItemAtPath:addressFilePath error:nil];
            }];
            
        }
        else if (error)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:error.localizedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }];
}


@end
