//
//  NSData+JSON.m
//  Baochuan
//
//  Created by Zhong Jiawu on 13-6-5.
//  Copyright (c) 2013年 Baixing. All rights reserved.
//

#import "NSData+JSON.h"

@implementation NSData (JSON)

- (id)objectFromJSONData
{
    return [NSJSONSerialization JSONObjectWithData:self options:kNilOptions error:NULL];
}

- (id)objectFromJSONDataWithError:(NSError *__autoreleasing *)error
{
    return [NSJSONSerialization JSONObjectWithData:self options:kNilOptions error:error];
}

@end