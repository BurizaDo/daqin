//
//  NSString+BCAdditions.h
//  Baochuan
//
//  Created by zengming on 13-8-7.
//  Copyright (c) 2013年 Baixing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (BCAdditions)

- (NSString *)encodeUrlString;

- (NSString *)md5;

- (NSString*)sha1;
@end
