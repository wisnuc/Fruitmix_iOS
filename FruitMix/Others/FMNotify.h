//
//  FMNotify.h
//  FruitMix
//
//  Created by 杨勇 on 16/7/27.
//  Copyright © 2016年 WinSun. All rights reserved.
//

#ifndef FMNotify_h
#define FMNotify_h

#define ALBUM_UPDATE_NOTIFY @"ALBUM_UPDATE_NOTIFY"
#define SHARE_UPDATE_NOTIFY @"SHARE_UPDATE_NOTIFY"
#define CREATE_ALBUM_SUCCESS_NOTIFY  @"CREATE_ALBUM_SUCCESS_NOTIFY"
#define CREATE_NEW_COMMENT @"CREATE_NEW_COMMENT"
#define PHOTO_LIBRUARY_CHANGE_NOTIFY @"PHOTO_LIBRUARY_CHANGE_NOTIFY"

//#define MEDIASHARE_UPDATE_NOTIFY @"MEDIASHARE_UPDATE_NOTIFY"   //相互通知
#define APP_JUMP_TO_ALBUM_NOTIFY @"APP_JUMP_TO_ALBUM_NOTIFY"


#define FM_SHARE_UPDATE_NOTIFY @"FM_SHARE_UPDATE_NOTIFY"//share 更新

#define FM_NEED_UPDATE_UI_NOTIFY @"FM_NEED_UPDATE_UI_NOTIFY"

#define FM_NET_STATUS_WIFI_NOTIFY @"FM_NET_STATUS_WIFI_NOTIFY"
#define FM_NET_STATUS_NOT_WIFI_NOTIFY @"FM_NET_STATUS_NOT_WIFI_NOTIFY"

#define FM_USER_ISADMIN @"FM_USER_ISADMIN"

#define FM_CALCULATE_HASH_SUCCESS_NOTIFY @"FM_CALCULATE_HASH_SUCCESS_NOTIFY"

/******************************************************************/

//key for mediaShare

#define MaintainersKey @"maintainers"
#define ViewersKey @"viewers"
#define ALbumKey @"album"
#define ContentsKey @"contents"
#define DigestKey @"digest"
#define UUIDKey @"uuid"
#define AuthorKey @"author"
//album
#define TitleKey @"title"
#define TextKey @"text"


//file download dir

#define File_DownLoad_DIR [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"JYDownloadCache"]

#endif /* FMNotify_h */
