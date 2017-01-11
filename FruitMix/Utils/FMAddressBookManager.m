//
//  FMAddressBookManager.m
//  FruitMix
//
//  Created by 杨勇 on 16/10/24.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#import "FMAddressBookManager.h"

#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>


//name or title
NSString * const FMAddressBookManagerFirstName = @"firstname";
NSString * const FMAddressBookManagerLastName = @"lastname";
NSString * const FMAddressBookManagerMiddleName = @"middlename";
NSString * const FMAddressBookManagerPrefix = @"prefix";//前缀
NSString * const FMAddressBookManagerSuffix = @"suffix";
NSString * const FMAddressBookManagerFirstNamePhonetic = @"firstnamePhonetic";
NSString * const FMAddressBookManagerLastNamePhonetic = @"lastnamePhonetic";
NSString * const FMAddressBookManagerMiddleNamePhonetic = @"middlenamePhonetic";
NSString * const FMAddressBookManagerOrganizationName = @"organizationName";
NSString * const FMAddressBookManagerDepartmentName = @"departmentName";
NSString * const FMAddressBookManagerJobTitle = @"jobtitle";
NSString * const FMAddressBookManagerNickName = @"nickname";//昵称

//address
NSString * const FMAddressBookManagerAddressArr = @"addresses";//地址数组
NSString * const FMAddressBookManagerAddressLabel = @"addressLabel";//地址标记
NSString * const FMAddressBookManagerStreetKey = @"street";
NSString * const FMAddressBookManagerCityKey = @"city";
NSString * const FMAddressBookManagerStatekey = @"state";
NSString * const FMAddressBookManagerZIPKey = @"zip";
NSString * const FMAddressBookManagerCountryKey = @"country";
NSString * const FMAddressBookManagerCountryCodeKey = @"countryCode";

//电话
NSString * const FMAddressBookManagerPhoneNumbersArr = @"phonenumbers";//号码数组
NSString * const FMAddressBookManagerPhoneLabel = @"phoneLabel";//号码标记
NSString * const FMAddressBookManagerPhoneNumber = @"phonenumber";//电话号码

//邮件
NSString * const FMAddressBookManagerEmailsArr = @"emails";//邮箱数组
NSString * const FMAddressBookManagerEmailLabel = @"emailLabel";//邮箱标记
NSString * const FMAddressBookManagerEmail = @"email";//邮箱

//生日
NSString * const FMAddressBookManagerBirthDaysArr = @"birthdays";//生日数组
NSString * const FMAddressBookManagerBirthDayLabel = @"birthdayLabel";//生日标记
NSString * const FMAddressBookManagerBirthDay = @"birthday";//生日

//url
NSString * const FMAddressBookManagerURLArr = @"urls";//urls
NSString * const FMAddressBookManagerURLLabel = @"urlLabel";//url 标记
NSString * const FMAddressBookManagerURL = @"url";//url

//纪念日
NSString * const FMAddressBookManagerDateArr = @"dates";//纪念日数组
NSString * const FMAddressBookManagerDatelabel = @"dateLabel";//纪念日标记
NSString * const FMAddressBookManagerDate = @"date";//纪念日


NSString * const FMAddressBookManagerNote = @"note";//备注

//关联人
NSString * const FMAddressBookManagerRelatedNamesArr = @"relatednames";//关联人
NSString * const FMAddressBookManagerReletedNameLabel = @"relatednameLabel";
NSString * const FMAddressBookManagerReletedName = @"relatedname";

@interface FMAddressBookManager()

@property (nonatomic) BOOL isLaterThanIOS9;

@property (nonatomic) FMAddressBookStatus status;

@property (nonatomic) NSMutableArray * telsArr;

@end

@implementation FMAddressBookManager


+(instancetype)shareManager{
    static FMAddressBookManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FMAddressBookManager alloc]init];
    });
    return manager;
}

-(instancetype)init{
    if (self = [super init]) {
        [self checkAddressBookStatus];
    }
    return self;
}

-(void)checkAddressBookStatus{
    //判断是否为iOS9及以上
    _isLaterThanIOS9 = [[[UIDevice currentDevice] systemVersion] compare:@"9" options:NSNumericSearch] != NSOrderedAscending;
    if(_isLaterThanIOS9){
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status == CNAuthorizationStatusDenied) {
            _status = FMAddressBookStatusDenied;
        }else if (status == CNAuthorizationStatusAuthorized){
            _status = FMAddressBookStatusAllow;
        }else
            _status = FMAddressBookStatusUndefine;
    }else{//iOS 8
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if (status == kABAuthorizationStatusDenied) {
            _status = FMAddressBookStatusDenied;
        }else if (status == kABAuthorizationStatusAuthorized){
            _status = FMAddressBookStatusAllow;
        }else
            _status = FMAddressBookStatusUndefine;
    }
}

-(NSMutableArray *)telsArr{
    if (_telsArr) {
        _telsArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _telsArr;
}

//请求权限
-(void)applyForAuthorizedWith:(void(^)(BOOL isAuthoried))complete{
    if (_isLaterThanIOS9) {
        [[[CNContactStore alloc]init]requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted)
                _status = FMAddressBookStatusAllow;
            complete(granted);
        }];
    }else{
        CFErrorRef error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted)
                _status = FMAddressBookStatusAllow;
            complete(granted);
        });
        if (error == NULL) {
            CFRelease(addressBook);
        }
    }
}

-(void)getTelsInIOS8AndBefore:(void(^)(NSArray * telsArr))complete{
    [self.telsArr removeAllObjects];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CFErrorRef error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
        NSArray * tempArr = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
        [tempArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ABRecordRef person = (__bridge ABRecordRef)(obj);
            NSMutableDictionary * persondic = [NSMutableDictionary dictionaryWithCapacity:0];
            //firstName
            NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            firstName = firstName != nil? firstName:@"";
            [persondic setObject:firstName forKey:FMAddressBookManagerFirstName];
            
            //middleName
            NSString *middleName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonMiddleNameProperty));
            middleName = middleName !=nil? middleName:@"";
            [persondic setObject:middleName forKey:FMAddressBookManagerMiddleName];
            
            //lastName
            NSString *lastName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
            lastName = lastName != nil? lastName:@"";
            [persondic setObject:lastName forKey:FMAddressBookManagerLastName];
            
            //名字前缀
            NSString *prefix = CFBridgingRelease(ABRecordCopyValue(person, kABPersonPrefixProperty));
            prefix = prefix != nil? prefix:@"";
            [persondic setObject:prefix forKey:FMAddressBookManagerPrefix];
            
            //名字后缀
            NSString *suffix = CFBridgingRelease(ABRecordCopyValue(person, kABPersonSuffixProperty));
            suffix = suffix != nil? suffix:@"";
            [persondic setObject:suffix forKey:FMAddressBookManagerSuffix];
            
            //姓氏发音
            NSString * firstNamePhonetic = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNamePhoneticProperty));
            firstNamePhonetic = firstNamePhonetic != nil? firstNamePhonetic:@"";
            [persondic setObject:firstNamePhonetic forKey:FMAddressBookManagerFirstNamePhonetic];
            
            //中间名发音
            NSString * middleNamePhonetic = CFBridgingRelease(ABRecordCopyValue(person, kABPersonMiddleNamePhoneticProperty));
            middleNamePhonetic = middleNamePhonetic != nil? middleNamePhonetic:@"";
            [persondic setObject:middleNamePhonetic forKey:FMAddressBookManagerMiddleNamePhonetic];
            
            //后名发音
            NSString * lastNamePhonetic = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNamePhoneticProperty));
            lastNamePhonetic = lastNamePhonetic != nil? lastNamePhonetic:@"";
            [persondic setObject:lastNamePhonetic forKey:FMAddressBookManagerLastNamePhonetic];
            
            //公司名
            NSString * organizationName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonOrganizationProperty));
            organizationName = organizationName != nil? organizationName:@"";
            [persondic setObject:organizationName forKey:FMAddressBookManagerOrganizationName];
            
            //部门名
            NSString * departmentName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonDepartmentProperty));
            departmentName = departmentName != nil? departmentName:@"";
            [persondic setObject:departmentName forKey:FMAddressBookManagerDepartmentName];
            
            //职位
            NSString * jobtitle = CFBridgingRelease(ABRecordCopyValue(person, kABPersonJobTitleProperty));
            jobtitle = jobtitle != nil? jobtitle:@"";
            [persondic setObject:jobtitle forKey:FMAddressBookManagerJobTitle];
            
            //昵称
            NSString * nickname = CFBridgingRelease(ABRecordCopyValue(person, kABPersonNicknameProperty));
            nickname = nickname != nil? nickname:@"";
            [persondic setObject:nickname forKey:FMAddressBookManagerNickName];
            
            
            //存储当前用户的号码dic
            NSMutableArray * phoneNumbersArr = [NSMutableArray arrayWithCapacity:0];
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,kABPersonPhoneProperty);
            
            for (int i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
                //号码标记
                NSString * phoneLabel = CFBridgingRelease(ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phoneNumbers, i)));
                phoneLabel = phoneLabel != nil? phoneLabel:@"";
                //号码
                NSString * phoneNumber = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
                phoneNumber = phoneNumber != nil? phoneNumber:@"";
                
                NSMutableDictionary * tempPhoneNumberDic = [NSMutableDictionary dictionaryWithCapacity:0];
                [tempPhoneNumberDic setObject:phoneLabel forKey:FMAddressBookManagerPhoneLabel];
                [tempPhoneNumberDic setObject:phoneNumber forKey:FMAddressBookManagerPhoneNumber];
                [phoneNumbersArr addObject:tempPhoneNumberDic];
                
            }
            [persondic setObject:phoneNumbersArr forKey:FMAddressBookManagerPhoneNumbersArr];
            CFRelease(phoneNumbers);
            
            //存储当前用户的邮箱
            NSMutableArray * emailsArr = [NSMutableArray arrayWithCapacity:0];
            ABMultiValueRef emails = ABRecordCopyValue(person,kABPersonEmailProperty);
            for (int i = 0; i < ABMultiValueGetCount(emails); i++) {
                NSString * emailLabel = CFBridgingRelease(ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(emails, i)));
                emailLabel = emailLabel != nil? emailLabel:@"";
                
                NSString * email = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emails, 0);
                email = email != nil? email:@"";
                
                //组成一个map
                NSMutableDictionary * tempEmail = [NSMutableDictionary dictionaryWithCapacity:0];
                [tempEmail setObject:emailLabel forKey:FMAddressBookManagerEmailLabel];
                [tempEmail setObject:email forKey:FMAddressBookManagerEmail];
                [emailsArr addObject:tempEmail];
            }
            [persondic setObject:emailsArr forKey:FMAddressBookManagerEmailsArr];
            CFRelease(emails);
            
            
//            NSMutableArray * addressesArr = [NSMutableArray arrayWithCapacity:0];
            ABMultiValueRef address = ABRecordCopyValue(person,kABPersonAddressProperty);
            for (int i = 0; i < ABMultiValueGetCount(address); i++) {
                
            }
            
            
        }];
    });
}

@end
