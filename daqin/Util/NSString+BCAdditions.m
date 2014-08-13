//
//  NSString+BCAdditions.m
//  Baochuan
//
//  Created by zengming on 13-8-7.
//  Copyright (c) 2013年 Baixing. All rights reserved.
//

#import "NSString+BCAdditions.h"

@implementation NSString (BCAdditions)

- (NSString *)encodeUrlString {
    NSString *sUrl = (NSString *)CFBridgingRelease
    (CFURLCreateStringByAddingPercentEscapes(
                                             kCFAllocatorDefault,
                                             (CFStringRef)[self copy],
                                             nil,
                                             nil,
                                             kCFStringEncodingUTF8)
     );
    return sUrl;
}

- (NSString *)md5 {
    const char *concat_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++) {
        [hash appendFormat:@"%02X", result[i]];
    }
    return [hash lowercaseString];
}


- (NSString*)sha1
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

@end
