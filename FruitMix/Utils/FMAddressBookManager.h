//
//  FMAddressBookManager.h
//  FruitMix
//
//  Created by 杨勇 on 16/10/24.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    FMAddressBookStatusUndefine,
    FMAddressBookStatusAllow,
    FMAddressBookStatusDenied,
} FMAddressBookStatus;

@interface FMAddressBookManager : NSObject

@end

//name or title
FOUNDATION_EXPORT NSString * const FMAddressBookManagerFirstName;
FOUNDATION_EXPORT NSString * const FMAddressBookManagerLastName;
FOUNDATION_EXPORT NSString * const FMAddressBookManagerMiddleName;
FOUNDATION_EXPORT NSString * const FMAddressBookManagerPrefix;//前缀
FOUNDATION_EXPORT NSString * const FMAddressBookManagerSuffix;//后缀
FOUNDATION_EXPORT NSString * const FMAddressBookManagerFirstNamePhonetic;//发音 或 音标
FOUNDATION_EXPORT NSString * const FMAddressBookManagerLastNamePhonetic;
FOUNDATION_EXPORT NSString * const FMAddressBookManagerMiddleNamePhonetic;
FOUNDATION_EXPORT NSString * const FMAddressBookManagerOrganizationName;
FOUNDATION_EXPORT NSString * const FMAddressBookManagerDepartmentName;
FOUNDATION_EXPORT NSString * const FMAddressBookManagerJobTitle;
FOUNDATION_EXPORT NSString * const FMAddressBookManagerNickName;//昵称

//address
FOUNDATION_EXPORT NSString * const FMAddressBookManagerAddressArr;//地址数组
FOUNDATION_EXPORT NSString * const FMAddressBookManagerAddressLabel;//地址标记
FOUNDATION_EXPORT NSString * const FMAddressBookManagerStreetKey;
FOUNDATION_EXPORT NSString * const FMAddressBookManagerCityKey;
FOUNDATION_EXPORT NSString * const FMAddressBookManagerStatekey;
FOUNDATION_EXPORT NSString * const FMAddressBookManagerZIPKey;
FOUNDATION_EXPORT NSString * const FMAddressBookManagerCountryKey;
FOUNDATION_EXPORT NSString * const FMAddressBookManagerCountryCodeKey;

//电话
FOUNDATION_EXPORT NSString * const FMAddressBookManagerPhoneNumbersArr;//号码数组
FOUNDATION_EXPORT NSString * const FMAddressBookManagerPhoneLabel;//号码标记
FOUNDATION_EXPORT NSString * const FMAddressBookManagerPhoneNumber;//电话号码

//邮件
FOUNDATION_EXPORT NSString * const FMAddressBookManagerEmailsArr;//邮箱数组
FOUNDATION_EXPORT NSString * const FMAddressBookManagerEmailLabel;//邮箱标记
FOUNDATION_EXPORT NSString * const FMAddressBookManagerEmail;//邮箱

//生日
FOUNDATION_EXPORT NSString * const FMAddressBookManagerBirthDaysArr;//生日数组
FOUNDATION_EXPORT NSString * const FMAddressBookManagerBirthDayLabel;//生日标记
FOUNDATION_EXPORT NSString * const FMAddressBookManagerBirthDay;//生日

//url
FOUNDATION_EXPORT NSString * const FMAddressBookManagerURLArr;//urls
FOUNDATION_EXPORT NSString * const FMAddressBookManagerURLLabel;//url 标记
FOUNDATION_EXPORT NSString * const FMAddressBookManagerURL;//url

//纪念日
FOUNDATION_EXPORT NSString * const FMAddressBookManagerDateArr;//纪念日数组
FOUNDATION_EXPORT NSString * const FMAddressBookManagerDatelabel;//纪念日标记
FOUNDATION_EXPORT NSString * const FMAddressBookManagerDate;//纪念日


FOUNDATION_EXPORT NSString * const FMAddressBookManagerNote;//备注

//关联人
FOUNDATION_EXPORT NSString * const FMAddressBookManagerRelatedNamesArr;//关联人
FOUNDATION_EXPORT NSString * const FMAddressBookManagerReletedNameLabel;
FOUNDATION_EXPORT NSString * const FMAddressBookManagerReletedName;


