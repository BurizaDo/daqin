//
//  BXUtil.m
//  Baixing
//
//  Created by XuMengyi on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Util.h"


@implementation Util


+ (CGSize)scaleSize:(CGSize)size maxSize:(CGSize)maxSize
{
    if (size.width > maxSize.width && size.height > maxSize.height) {
        CGFloat widthScale = size.width/maxSize.width;
        CGFloat heightScale = size.height/maxSize.height;
        if (widthScale>heightScale) {
            size.width = maxSize.width;
            size.height = size.height/widthScale;
        }
        else{
            size.height = maxSize.height;
            size.width = size.width/heightScale;
        }
    }
    else if(size.width > maxSize.width)
    {
        CGFloat widthScale = size.width/maxSize.width;
        size.width = maxSize.width;
        size.height = size.height/widthScale;
    }
    else if(size.height > maxSize.height)
    {
        CGFloat heightScale = size.height/maxSize.height;
        size.height = maxSize.height;
        size.width = size.width/heightScale;
    }
    
    return size;
}

+ (NSString *) GUID
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuidStringRef];
    CFRelease(uuidStringRef);
    return uuid;
}

@end
