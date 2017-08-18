//
//  StationPageControl.m
//  FruitMix
//
//  Created by wisnuc on 2017/8/15.
//  Copyright © 2017年 WinSun. All rights reserved.
//

#import "StationPageControl.h"

@implementation StationPageControl

- (void) setCurrentPage:(NSInteger)page {
    [super setCurrentPage:page];
//    if (page == self.currentPage) {
//        self.transform=CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
//    }
//    for (NSUInteger subviewIndex = 0; subviewIndex < [self.subviews count]; subviewIndex++) {
//        UIImageView* subview = [self.subviews objectAtIndex:subviewIndex];
//        CGSize currentPageSize;
//        currentPageSize.height = 5;
//        currentPageSize.width = 5;
//        
//        CGSize pageSize;
//        pageSize.height = 5;
//        pageSize.width = 5;
//
//        if (subviewIndex == self.currentPage) {
//            [subview setFrame:CGRectMake(subview.frame.origin.x, subview.frame.origin.y,
//                                         currentPageSize.width,currentPageSize.height)];
//        }else{
//            [subview setFrame:CGRectMake(subview.frame.origin.x, subview.frame.origin.y,
//                                         pageSize.width,pageSize.height)];
//        }
//    }
}

@end
