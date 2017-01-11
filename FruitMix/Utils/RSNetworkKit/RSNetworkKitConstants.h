//
// RSNetworkKitConstants.h
// Copyright (c) 2016 Rushi Sangani
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import <Foundation/Foundation.h>


/********************** ENUMS ************************/

// RequestType enum

typedef NS_ENUM(NSInteger, RequestType) {
    GET,
    POST,
    PUT,
    DELETE,
    HEAD
};

// FileType enum

typedef NS_ENUM(NSInteger, FileType) {
    FileTypeImage,
    FileTypeAudio,
    FileTypeVideo,
    FileTypeDoc,
    FileTypePdf,
    FileTypeTxt
};



/********************** Error Codes ************************/

static NSInteger  kErrorCodeBadURL                   = -1000;
static NSInteger  kErrorCodeConnectionTimeout        = -1001;
static NSInteger  kErrorCodeNetworkConnectionLost    = -1005;
static NSInteger  kErrorCodeNoInternet               = -1009;
static NSInteger  kErrorCodeFileNotExists            = -1100;

static NSString *kErrorNoInternetConnection         = @"The connection failed because the device is not connected to the internet.";
static NSString *kErrorMalformedURL                 = @"The connection failed due to a malformed URL.";
static NSString *kErrorConnectionTimedout           = @"The connection timed out.";
static NSString *kErrorNetworkConnectionLost        = @"The connection failed because the network connection was lost.";
static NSString *kErrorFileNotExists                = @"The file operation failed because the file does not exist.";



/********************** Imports ************************/

//AFNetworking

#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"

//Networking

#import "RSNetworkManager.h"
#import "RSDownloadManager.h"
#import "RSUploadManager.h"

#import "NetworkClient.h"

@interface RSNetworkKitConstants : NSObject

@end
