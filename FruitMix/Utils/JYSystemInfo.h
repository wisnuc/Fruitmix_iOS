//
//  JYSystemInfo.h
//  
//
//  Created by 杨勇 on 16/5/26.
//
//

CGSize APP_ScreenSize();

CGFloat APP_Screen_Width();

CGFloat APP_Screen_Height();

CGFloat APP_WIDTH();

CGFloat APP_HEIGHT();

NSString *APP_Version();

NSString *APP_BuildVersion();

NSString *APP_BundleName();

NSString *APP_Identifier();
NSString *APP_BundleSeedID();
NSString *APP_SchemaWithName(NSString *name);
NSString *APP_Schema();

NSURL *APP_DocumentsURL();
NSString *APP_DocumentsPath();
NSURL *APP_CachesURL();

NSString *APP_CachesPath();

NSURL *APP_LibraryURL();

NSString *APP_LibraryPath();

int64_t APP_MemoryUsage();
float APP_CpuUsage();
